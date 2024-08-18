#!/bin/bash

### COLORS
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

WORKING_DIRECTORY=$(dirname -- "${0}")

DEFAULT_CONFIG_FILE="config/default_config.sh"
CONFIG_FILE="config/config.sh"

DEFAULT_SCREEN_CONFIG_FILE="config/default_screen.conf"
SCREEN_CONFIG_FILE="config/screen.conf"

###########################################

echo "Loading configuration..."
if [ -f "$DEFAULT_CONFIG_FILE" ]; then
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "Copying $DEFAULT_CONFIG_FILE to $CONFIG_FILE..."
        cp "$DEFAULT_CONFIG_FILE" "$CONFIG_FILE"
    fi
else
    echo -e "${RED}[Error] Configuration failed to load: ${DEFAULT_CONFIG_FILE} not found. Try to redownload the script.${NC}"
    exit 1
    return
fi
echo "Configuration loaded."

. "$DEFAULT_CONFIG_FILE" # For compatibility with newer configurations not yet configured locally.
. "$CONFIG_FILE"

###########################################

CONFIG_PATH="${PERSISTENT_STORAGE_ROOT}/${CONF_DIR}"
CLUSTER_PATH="${CONFIG_PATH}/${CLUSTER}";
CLUSTER_TOKEN_PATH="${CLUSTER_PATH}/cluster_token.txt"

SHARD_SCREEN_SESSIONS=()
for SHARD in ${SHARDS[@]}; do
    SHARD_SCREEN_SESSIONS+=("${SHARD_SESSION_PREFIX}${SHARD}")
done

MASTER_SCREEN_SESSION="${SHARD_SCREEN_SESSIONS[0]}"

X32_MACHINE=$([ "$(uname -m)" = "i686" ] || [ "$(uname -m)" = "i386" ] && echo true || echo false)

###########################################

screen_exists() {
    screen -ls | grep -q "\b${1}[[:space:]]("
}

###########################################
