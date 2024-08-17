#!/bin/bash

. constants.sh

# We do not have to use "sudo -u ..." since this should be executed by systemctl
# where the service has already an user assigned (User=) to it which will be used instead of the caller.

# Find all screen sessions starting with the SHARD_SCREEN_SESSION_PREFIX and c_shutdown them all
# This is in order to cleanup some of the old sessions in case something goes wrong.
for SHARD_SCREEN_SESSION in $(screen -ls | grep -oP "\t\d+\.${SHARD_SCREEN_SESSION_PREFIX}\w*" | awk '{print $1}'); do
    echo "Shutting down shard screen session ${SHARD_SCREEN_SESSION}...";
    screen -S "$SHARD_SCREEN_SESSION" -X stuff "${SHUTDOWN_COMMAND}^M"
done
