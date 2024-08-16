#!/bin/bash

DEFAULT_CONFIG_FILE="config/default_config.sh"
CONFIG_FILE="config/config.sh"
SCREEN_CONFIG_FILE="config/screen.conf"

UPDATE_LOG_FILE="update.log"

###########################################

echo "Loading configuration..."
if [ -f "$DEFAULT_CONFIG_FILE" ]; then
    if [ ! -f "$CONFIG_FILE" ]; then
        cp "$DEFAULT_CONFIG_FILE" "$CONFIG_FILE"
    fi
else
    echo "Configuration failed to load: ${DEFAULT_CONFIG_FILE} not found. Try to redownload the script."
    exit 1
    return
fi

. "$DEFAULT_CONFIG_FILE" # For compatibility with newer configurations not yet configured locally.
. "$CONFIG_FILE"

CONFIG_PATH="${PERSISTENT_STORAGE_ROOT}/${CONF_DIR}"
CLUSTER_PATH="${CONFIG_PATH}/${CLUSTER_NAME}";

SHARD_SCREEN_SESSIONS=()
for SHARD in ${SHARDS[@]}; do
    SHARD_SCREEN_SESSIONS+=("${SHARD_SESSION_PREFIX}${SHARD}")
done

MASTER_SCREEN_SESSION="${SHARD_SCREEN_SESSIONS[${MASTER_SHARD_INDEX}]}"

###########################################

screen_exists() {
    screen -ls | grep -q "\b${1}[[:space:]]("
}

###########################################
