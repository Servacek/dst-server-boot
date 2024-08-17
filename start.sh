#!/bin/bash

. constants.sh

###########################################

# Make sure no other session created by this script are currently running
for SHARD_SCREEN_SESSION in ${SHARD_SCREEN_SESSIONS[@]}; do
    if screen_exists "$SHARD_SCREEN_SESSION"; then
        echo "${RED}[Error] Cannot start the server screen sessions because the session \"${SHARD_SCREEN_SESSION}\" already exists.\nRun the stop command first and then try again.${NC}"
        exit 1
        return
    fi
done

if [[ $VALIDATE == true && -f "$MODS_SETUP_FILE_PATH" ]]; then
    # Backup the mods setup file since it's being overridden by validation.
    echo "Backing up the mods setup file..."
    mv "$MODS_SETUP_FILE_PATH" "$MODS_SETUP_FILE_BACKUP_PATH"
fi

echo "Starting the server update process..."
# Wait until the process finishes and also print out the output to the console.
"${STEAMCMD}" \
    +force_install_dir "${GAMEDIR}" \
    +login "${LOGIN}" \
    +app_update "${GAMESERVERID}" \
    $(if [[ $VALIDATE == true ]]; then echo "validate"; fi) \
    +quit &

echo "PID: $!"
netstat -tulnp | grep "$!"

if [ -f "$MODS_SETUP_FILE_BACKUP_PATH" ]; then
    echo "Restoring the mods setup file..."
    mv "$MODS_SETUP_FILE_BACKUP_PATH" "$MODS_SETUP_FILE_PATH"
fi

if [[ $? -ne 0 ]]; then
    echo "${RED}[Error] Updating server proccess failed! Status: $?${NC}"
    exit 1
    return
else
    echo "${GREEN}Updating server proccess finished successfully.${NC}"
fi

# Make sure we have a screen configuration file.
# But it's totally OK to not have one.
if [ -f "$DEFAULT_SCREEN_CONFIG_FILE" ]; then
    if [ ! -f "$SCREEN_CONFIG_FILE" ]; then
        echo "Copying $DEFAULT_SCREEN_CONFIG_FILE to $SCREEN_CONFIG_FILE..."
        cp "$DEFAULT_SCREEN_CONFIG_FILE" "$SCREEN_CONFIG_FILE"
    fi
else
    echo "[Warn] Screen configuration files not found."
fi

exit 0

echo "Starting up the shards..."
for INDEX in ${!SHARDS[@]}; do
    SHARD_NAME=${SHARDS[$INDEX]} # Should always have an value, since names are required.
    SESSION=${SHARD_SESSION_PREFIX}${SHARDS[$INDEX]}

    # Optional
    CPU_CORE=${CPUCORES[$INDEX]}
    PORT=${PORTS[$INDEX]}
    STEAM_MASTER_SERVER_PORT=${STEAM_MASTER_SERVER_PORTS[$INDEX]}
    STEAM_AUTHENTICATION_PORT=${STEAM_AUTHENTICATION_PORTS[$INDEX]}

    echo "Starting shard ${SHARD_NAME}..."
    taskset -c $(if [[ -n "$CPU_CORE" ]]; then echo "$CPU_CORE"; else echo "0-$(($(nproc)-1))"; fi) \
        screen -c ${SCREEN_CONFIG_FILE} -m -d -U -t "$SHARD_NAME" -S "${SESSION}" bash -c 'while ! ('"$DST_BIN"' \
            $(if [[ ! -z '"$PERSISTENT_STORAGE_ROOT"' ]]; then echo "-persistent_storage_root '"${PERSISTENT_STORAGE_ROOT}"'"; fi) \
            $(if [[ ! -z '"$CONF_DIR"' ]]; then echo "-conf_dir '"${CONF_DIR}"'"; fi) \
            $(if [[ ! -z '"$CLUSTER"' ]]; then echo "-cluster '"${CLUSTER}"'"; fi) \
            $(if [[ ! -z '"$SHARD_NAME"' ]]; then echo "-shard '"${SHARD_NAME}"'"; fi) \
            $(if [[ ! -z '"$BACKUP_LOG_COUNT"' ]]; then echo "-backup_log_count '"${BACKUP_LOG_COUNT}"'"; fi) \
            $(if [[ ! -z '"$ONLY_UPDATE_SERVER_MODS"' ]]; then echo "-only_update_server_mods '"${ONLY_UPDATE_SERVER_MODS}"'"; fi) \
            $(if [[ ! -z '"$SKIP_UPDATE_SERVER_MODS"' ]]; then echo "-skip_update_server_mods '"${SKIP_UPDATE_SERVER_MODS}"'"; fi) \
            $(if [[ ! -z '"$BIND_IP"' ]]; then echo "-bind_ip '"${BIND_IP}"'"; fi) \
            $(if [[ ! -z '"$TICK"' ]]; then echo "-tick '"${TICK}"'"; fi) \
            $(if [[ ! -z '"$PLAYERS"' ]]; then echo "-players '"${PLAYERS}"'"; fi) \
            $(if [[ ! -z '"$PORT"' ]]; then echo "-port '"${PORT}"'"; fi) \
            $(if [[ ! -z '"$STEAM_MASTER_SERVER_PORT"' ]]; then echo "-steam_master_server_port '"${STEAM_MASTER_SERVER_PORT}"'"; fi) \
            $(if [[ ! -z '"$STEAM_AUTHENTICATION_PORT"' ]]; then echo "-steam_authentication_port '"${STEAM_AUTHENTICATION_PORT}"'"; fi) \
            $(if [[ ! -z '"$MONITOR_PARENT_PROCESS"' ]]; then echo "-monitor_parent_process '"${MONITOR_PARENT_PROCESS}"'"; fi) \
            $(if [[ '"$OFFLINE"' == true ]]; then echo "-offline"; fi) \
            $(if [[ '"$DISABLEDATACOLLECTION"' == true ]]; then echo "-disabledatacollection"; fi) \
            $(if [[ '"$CLOUDSERVER"' == true && '"$INDEX"' == '"$MASTER_SHARD_INDEX"' ]]; then echo "-cloudserver"; fi)
        ); do
            echo "'${RED}'[Error] Looks like the server has crashed! Restarting in '${TIME_UNTIL_AUTO_RESTART}' seconds...'${NC}'";
            sleep '${TIME_UNTIL_AUTO_RESTART}';
        done'

    if screen_exists "${SHARD_SCREEN_SESSIONS[$INDEX]}"; then
        echo "${GREEN}Process for shard ${SHARD_NAME} has successfully started!${NC}"
    else
        echo "${RED}[Error] Failed to start ${SHARD_NAME}! Status: $?${NC}"
    fi

    # Give the Master shard some time to initialize before the slave shards.
    sleep $TIME_BETWEEN_SHARDS
done
