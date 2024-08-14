#!/bin/bash

. constants.sh

# Send a c_reload command to the master shard screen session.
# It should be automatically propagated to the slave shards.
screen -S "${MASTER_SCREEN_SESSION}" -X stuff "c_reset()^M"
