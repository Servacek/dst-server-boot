#!/bin/bash

DEFAULT_CONFIG_FILE="config/default_config.sh"
CONFIG_FILE="config/config.sh"
SCREEN_CONFIG_FILE="config/screen_config.sh"

UPDATE_LOG_FILE="update.log"

echo "Loading configuration..."
if [ -f "$DEFAULT_CONFIG_FILE" ]; then
    if [ ! -f $CONFIG_FILE ]; then
        cp "$DEFAULT_CONFIG_FILE" "$CONFIG_FILE"
    fi
else
    echo "Configuration failed to load: ${DEFAULT_CONFIG_FILE} not found. Try to redownload the script."
    exit 1
fi

source "$DEFAULT_CONFIG_FILE" # For compatibility with newer configurations not yet configured locally.
source "$CONFIG_FILE"

###########################################

# Make sure no other session created by this script are currently running
for SESSION_TYPE in ${SCREEN_SESSIONS[@]}; do
    SESSION="${CLUSTER}_${SESSION_TYPE}"
    if [ screen -ls | grep -q "\.${SESSION}[[:space:]]" ] then
        echo "Cannot start the server screen sessions because the session \"${SESSION}\" already exists."
        exit 1
    fi
done

if [[ $VALIDATE == true ]]; then
    # Backup the mods setup file since it's being overridden by validation.
    echo "Backing up the mods setup file..."
    mv "$MODS_SETUP_FILE_PATH" "$MODS_SETUP_FILE_BACKUP_PATH"
fi

# Start up the updating process but do not fork, we want to wait until it finishes.
echo "Starting the server update process..."
taskset -c ${MAIN_CPUCORE} \
    screen -c ${SCREEN_CONFIG_FILE} -m -U -D -S ${CLUSTER}_Update \
        bash -c "${STEAMCMD} \
            +force_install_dir ${GAMEDIR} \
            +login ${LOGIN} \
            +app_update ${GAMEID} \
            $(if [[ $VALIDATE == true ]]; then echo "validate"; fi) \
            +quit 2>&1 \
        | tee -a ${UPDATE_LOG_FILE}"

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

    # Optional
    CPU_CORE=${CPUCORES[$INDEX]}
    PORT=${PORTS[$INDEX]}

    echo "Starting ${SHARD_NAME}..."
    taskset -c $(if [[ -n "$CPU_CORE" ]]; then echo "$CPU_CORE"; else echo "0-$(($(nproc)-1))"; fi) \
        screen -c ${SCREEN_CONFIG_FILE} -m -d -U -t "$SHARD_NAME" -S "${CLUSTER}_${SHARD_NAME}" "$DST_BIN" \
            -persistent_storage_root "$PERSISTENT_STORAGE_ROOT" \
            -conf_dir "$CONF_DIR" \
            -cluster "$CLUSTER" \
            -shard "$SHARD_NAME" \
            -backup_log_count "$BACKUP_LOG_COUNT" \
            -only_update_server_mods "$ONLY_UPDATE_SERVER_MODS" \
            -skip_update_server_mods "$SKIP_UPDATE_SERVER_MODS" \
            -bind_ip "$BIND_IP" \
            -tick "$TICK" \
            $(if [[ "$PORT" != "" ]]; then echo "-port ${PORT}"; fi) \

    if [[ $? -ne 0 ]]; then
        echo "Failed to start ${SHARD_NAME}! Status: $?"
    else
        echo "Started ${SHARD_NAME}!"
    fi
done
