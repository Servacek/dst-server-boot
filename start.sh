#!/bin/bash

. constants.sh

###########################################

# Make sure no other session created by this script are currently running
for SHARD_SCREEN_SESSION in ${SHARD_SCREEN_SESSIONS[@]}; do
    if screen_exists "$SHARD_SCREEN_SESSION"; then
        echo -e "${RED}[Error] Cannot start the server screen sessions because the session \"${SHARD_SCREEN_SESSION}\" already exists.\nRun the stop command first and then try again.${NC}"
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
# We do not care about steamcmd's ports because that should be centralized anyway
# and the ports are static as far as I know.
"${STEAMCMD}" \
    +force_install_dir "${GAMEDIR}" \
    +login "${LOGIN}" \
    +app_update "${GAMESERVERID}" \
    $(if [[ $VALIDATE == true ]]; then echo "validate"; fi) \
    +quit

if [ -f "$MODS_SETUP_FILE_BACKUP_PATH" ]; then
    echo "Restoring the mods setup file..."
    mv "$MODS_SETUP_FILE_BACKUP_PATH" "$MODS_SETUP_FILE_PATH"
fi

if [[ $? -ne 0 ]]; then
    echo -e "${RED}[Error] Updating server proccess failed! Status: $?${NC}"
    exit 1
    return
else
    echo -e "${GREEN}Updating server proccess finished successfully.${NC}"
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

echo "Starting up the shards..."
for i in ${!SHARDS[@]}; do
    SHARD_NAME=${SHARDS[$i]} # Should always have an value, since names are required.
    SESSION=${SHARD_SESSION_PREFIX}${SHARDS[$i]}

    # Optional
    CPU_CORE=${CPUCORES[$i]}
    PORT=${PORTS[$i]}
    STEAM_MASTER_SERVER_PORT=${STEAM_MASTER_SERVER_PORTS[$i]}
    STEAM_AUTHENTICATION_PORT=${STEAM_AUTHENTICATION_PORTS[$i]}

    echo "Starting shard ${SHARD_NAME}..."
    taskset -c $(if [[ -n "$CPU_CORE" ]]; then echo "$CPU_CORE"; else echo "0-$(($(nproc)-1))"; fi) \
        screen -c "${SCREEN_CONFIG_FILE}" -m -d -U -t "${SHARD_NAME}" -S "${SESSION}" bash -c '
        CURRENT_START_RETRY_ATTEMPTS=0;
        while ! ('"$DST_BIN"' \
            $(if [[ -n "'"${PERSISTENT_STORAGE_ROOT}"'" ]]; then echo "-persistent_storage_root '"${PERSISTENT_STORAGE_ROOT}"'"; fi) \
            $(if [[ -n "'"${CONF_DIR}"'" ]]; then echo "-conf_dir '"${CONF_DIR}"'"; fi) \
            $(if [[ -n "'"${CLUSTER}"'" ]]; then echo "-cluster '"${CLUSTER}"'"; fi) \
            $(if [[ -n "'"${SHARD_NAME}"'" ]]; then echo "-shard '"${SHARD_NAME}"'"; fi) \
            $(if [[ -n "'"${BACKUP_LOG_COUNT}"'" ]]; then echo "-backup_log_count '"${BACKUP_LOG_COUNT}"'"; fi) \
            $(if [[ -n "'"${ONLY_UPDATE_SERVER_MODS}"'" ]]; then echo "-only_update_server_mods '"${ONLY_UPDATE_SERVER_MODS}"'"; fi) \
            $(if [[ -n "'"${SKIP_UPDATE_SERVER_MODS}"'" ]]; then echo "-skip_update_server_mods '"${SKIP_UPDATE_SERVER_MODS}"'"; fi) \
            $(if [[ -n "'"${BIND_IP}"'" ]]; then echo "-bind_ip '"${BIND_IP}"'"; fi) \
            $(if [[ -n "'"${TICK}"'" ]]; then echo "-tick '"${TICK}"'"; fi) \
            $(if [[ -n "'"${PLAYERS}"'" ]]; then echo "-players '"${PLAYERS}"'"; fi) \
            $(if [[ -n "'"${PORT}"'" ]]; then echo "-port '"${PORT}"'"; fi) \
            $(if [[ -n "'"${STEAM_MASTER_SERVER_PORT}"'" ]]; then echo "-steam_master_server_port '"${STEAM_MASTER_SERVER_PORT}"'"; fi) \
            $(if [[ -n "'"${STEAM_AUTHENTICATION_PORT}"'" ]]; then echo "-steam_authentication_port '"${STEAM_AUTHENTICATION_PORT}"'"; fi) \
            $(if [[ -n "'"${MONITOR_PARENT_PROCESS}"'" ]]; then echo "-monitor_parent_process '"${MONITOR_PARENT_PROCESS}"'"; fi) \
            $(if [[ "'"${OFFLINE}"'" == true ]]; then echo "-offline"; fi) \
            $(if [[ "'"${DISABLEDATACOLLECTION}"'" == true ]]; then echo "-disabledatacollection"; fi) \
            $(if [[ "'"${CLOUDSERVER}"'" == true && '"$i"' == '"$MASTER_SHARD_INDEX"' ]]; then echo "-cloudserver"; fi)
        ); do
            if [[ "'"${RESTART_INDIVIDUAL_SHARDS_ON_FAILURE}"'" == true ]]; then
                if [[ ${CURRENT_START_RETRY_ATTEMPTS} -ge "'"${MAX_START_RETRY_ATTEMPTS}"'" ]]; then
                    echo -e "'"${RED}"'[Error] Server has crashed and we were unable to revive it even after '"${MAX_START_RETRY_ATTEMPTS}"' attempts! Exiting...'"${NC}"'";
                    break;
                fi

                CURRENT_START_RETRY_ATTEMPTS=$((CURRENT_START_RETRY_ATTEMPTS+1));
                echo -e "'"${RED}"'[Error] Looks like the shard \"'"${SHARD_NAME}"'\" has crashed! Restarting it in '"${TIME_UNTIL_AUTO_RESTART}"' seconds...'"${NC}"'";
                sleep '"${TIME_UNTIL_AUTO_RESTART}"';
            else
                echo -e "'"${RED}"'[Error] Looks like the shard \"'"${SHARD_NAME}"'\" has crashed! Restarting the WHOLE server in '"${TIME_UNTIL_AUTO_RESTART}"' seconds...'"${NC}"'";
                sleep '"${TIME_UNTIL_AUTO_RESTART}"';
                sudo /bin/systemctl restart '"${SERVICE}"'.service;
                exit 0;
            fi
        done'

    if screen_exists "${SHARD_SCREEN_SESSIONS[$i]}"; then
        echo -e "${GREEN}Process for shard ${SHARD_NAME} has successfully started!${NC}"
    else
        echo -e "${RED}[Error] Failed to start ${SHARD_NAME}! Status: $?${NC}"
    fi

    # Give the Master shard some time to initialize before the slave shards.
    sleep $TIME_BETWEEN_SHARDS
done
