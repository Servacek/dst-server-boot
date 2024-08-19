# Tasks use the same boot directory as their working directory.

. "constants.sh"

screen -S ${SHARD_SESSION_PREFIX}${SHARDS[${MASTER_SHARD_INDEX}]} -X stuff 'c_announce(\"The server will be automatically restarted in 1 minute for regular maintenance.\")^M'
sleep 57
screen -S ${SHARD_SESSION_PREFIX}${SHARDS[${MASTER_SHARD_INDEX}]} -X stuff 'c_announce(\"Restarting the server...\")^M'
sleep 3
sudo systemctl restart ${SERVICE}.service
