#!/bin/bash

. constants.sh

###########################################

# Make sure no other session created by this script are currently running
for SHARD in ${SHARDS[@]}; do
    SESSION="${SHARD_SESSION_PREFIX}${SHARD}"
    if screen_exists "$SESSION"; then
        echo "Cannot start the server screen sessions because the session \"${SESSION}\" already exists.\nClose all already running sessions and try again.s"
        exit 1
    fi
done

if [[ $VALIDATE == true && -f "$MODS_SETUP_FILE_PATH" ]]; then
    # Backup the mods setup file since it's being overridden by validation.
    echo "Backing up the mods setup file..."
    mv "$MODS_SETUP_FILE_PATH" "$MODS_SETUP_FILE_BACKUP_PATH"
fi

echo "Starting the server update process..."
# Wait until the process finishes and also print out the output to the console.
${STEAMCMD} \
    +force_install_dir ${GAMEDIR} \
    +login ${LOGIN} \
    +app_update ${GAMESERVERID} \
    $(if [[ $VALIDATE == true ]]; then echo "validate"; fi) \
    +quit

if [ -f "$MODS_SETUP_FILE_BACKUP_PATH" ]; then
    echo "Restoring the mods setup file..."
    mv "$MODS_SETUP_FILE_BACKUP_PATH" "$MODS_SETUP_FILE_PATH"
fi

if [[ $? -ne 0 ]]; then
    echo "Updating server proccess failed! Status: $?"
    exit 1
else
    echo "Updating server proccess finished successfully."
fi

echo "Starting up the shards..."
for INDEX in ${!SHARDS[@]}; do
    SHARD_NAME=${SHARDS[$INDEX]} # Should always have an value, since names are required.
    SESSION=${SHARD_SESSION_PREFIX}${SHARDS[$INDEX]}

    # Optional
    CPU_CORE=${CPUCORES[$INDEX]}
    PORT=${PORTS[$INDEX]}

    echo "Starting ${SHARD_NAME}..."
    taskset -c $(if [[ -n "$CPU_CORE" ]]; then echo "$CPU_CORE"; else echo "0-$(($(nproc)-1))"; fi) \
        screen -c ${SCREEN_CONFIG_FILE} -m -d -U -t "$SHARD_NAME" -S "${SESSION}" bash -c 'while ! ('"$DST_BIN"' \
            -persistent_storage_root '"$PERSISTENT_STORAGE_ROOT"' \
            -conf_dir '"$CONF_DIR"' \
            -cluster '"$CLUSTER"' \
            -shard '"$SHARD_NAME"' \
            -backup_log_count '"$BACKUP_LOG_COUNT"' \
            -only_update_server_mods '"$ONLY_UPDATE_SERVER_MODS"' \
            -skip_update_server_mods '"$SKIP_UPDATE_SERVER_MODS"' \
            -bind_ip '"$BIND_IP"' \
            -tick '"$TICK"' \
            $(if [[ '"$PORT"' != "" ]]; then echo "-port '"${PORT}"'"; fi)
        ); do
            echo "Looks like the server has crashed! Restarting in '${TIME_UNTIL_AUTO_RESTART}' seconds...";
            sleep '${TIME_UNTIL_AUTO_RESTART}';
        done'

    if screen_exists "$SESSION"; then
        echo "Started ${SHARD_NAME}!"
    else
        echo "Failed to start ${SHARD_NAME}! Status: $?"
    fi

    # Give the Master shard some time to initialize before the slave shards.
    sleep $TIME_BETWEEN_SHARDS
done
