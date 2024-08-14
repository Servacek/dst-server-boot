#!/bin/bash

. constants.sh

# Send a c_shutdown() command to all shard screen sessions.
for SHARD_SCREEN_SESSION in ${SHARD_SCREEN_SESSIONS[@]}; do
    screen -S "$SHARD_SCREEN_SESSION" -X stuff "c_shutdown()^M"
done
