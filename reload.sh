#!/bin/bash

. constants.sh

echo "Sending reload request to the master shard of the server..."
# Send a c_reload command to the master shard screen session.
# It should be automatically propagated to the slave shards.
screen -S "${MASTER_SCREEN_SESSION}" -X stuff "${RELOAD_COMMAND}^M"
