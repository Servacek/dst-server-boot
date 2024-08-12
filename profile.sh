
####################### CZSK ADMIN #########################

BOOT_DIRECTORY="/home/steam/.klei/DoNotStarveTogether/.game/boot"
source "${BOOT_DIRECTORY}/constants.sh"

# Group these changes should effect.
GROUP_NAME="czsk-admin"

# A wrapper around the built-in "alias" command.
add_alias() {
    alias ${1}="${2}"
    echo "   - ${1}\t-> ${3}"
}

# Check if the user belongs to the specific group
if groups $USER | grep -q "\b${GROUP_NAME}\b"; then
    echo "######################### CZSK SERVER #########################"

    add_alias "mods" "cd ${GAMEDIR}/mods" "Change your pwd to the ${CLUSTER} server's mods directory."
    add_alias "wmods" "cd ${GAMEDIR}/ugc_mods/${CLUSTER_NAME}/Master/content/${GAMEID}" "Change your pwd to the ${CLUSTER} server's ugc_mods directory storing newer workshop mods."
    add_alias "mods" "cd ${GAMEDIR}/mods" "Change your pwd to the ${CLUSTER} server's mods directory."
    add_alias "sboot" "cd ${GAMEDIR}/boot" "Change your pwd to the ${CLUSTER} server's boot directory."

    for SHARD in ${SHARDS[@]}; do
        add_alias "${SHARD,,}" "cd ${CLUSTER_PATH}/${SHARD}" "Change your pwd to the ${CLUSTER} server's ${SHARD} shard directory."
        add_alias "c_${SHARD,,}" "screen -r ${SESSION_OWNER}/${SHARD_SESSION_PREFIX}${SHARD}" "Open the console for the ${SHARD} shard."

    # TODO: Make this display only the server's processes.
    alias pcores='for pid in $(ps -a -o pid=); do source_file=$(ps -p $pid -o args=); affinity=$(taskset -pc $pid 2>/dev/null); \
                  echo "PID: $pid, Source File: $source_file, Affinity: $affinity"; done'

    #cat "${BOOT_DIR}/commands.motd" # Display our custom MOTD
    echo "###############################################################"
fi

###################################################
