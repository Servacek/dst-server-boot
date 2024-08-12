#!/bin/bash

####################### CZSK ADMIN #########################

# Group these changes should effect.
GROUP_NAME="czsk-admin"

# A wrapper around the built-in "alias" command.
add_alias() {
    alias ${1}="${2}"
    echo "   - ${1}     -> ${3}"
}

exit() {
   echo "Profile.d script exited prematurely."
}

# Check if the user belongs to the specific group
if groups $USER | grep -q "\b${GROUP_NAME}\b"; then
    echo "######################### CZSK SERVER #########################"
    BOOT_DIRECTORY="/home/steam/.klei/DoNotStarveTogether/.game/boot"
    cd $BOOT_DIRECTORY
    source "${BOOT_DIRECTORY}/constants.sh"
    echo ""
    echo "AVAILABLE ALIASES"

    add_alias "wmods" "cd ${GAMEDIR}/ugc_mods/${CLUSTER_NAME}/Master/content/${GAMEID}" "Change your pwd to the ${CLUSTER} server's ugc_mods directory storing newer workshop mods."
    add_alias "mods" "cd ${GAMEDIR}/mods" "Change your pwd to the ${CLUSTER} server's mods directory."
    add_alias "sboot" "cd ${GAMEDIR}/boot" "Change your pwd to the ${CLUSTER} server's boot directory."

    echo ""

    for SHARD in ${SHARDS[@]}; do
        add_alias "${SHARD,,}" "cd ${CLUSTER_PATH}/${CLUSTER}/${SHARD}" "Change your pwd to the ${CLUSTER} server's ${SHARD} shard directory."
        add_alias "c_${SHARD,,}" "screen -r ${SESSION_OWNER}/${SHARD_SESSION_PREFIX}${SHARD}" "Open the console for the ${SHARD} shard."
    done

    # TODO: Make this display only the server's processes.
    # alias pcores='for pid in $(ps -a -o pid=); do source_file=$(ps -p $pid -o args=); affinity=$(taskset -pc $pid 2>/dev/null); \
    #               echo "PID: $pid, Source File: $source_file, Affinity: $affinity"; done'

    echo ""
    add_alias "c_reload" "systemctl reload ${SERVICE}.service" "The same effect as c_reload() in game but is being executed by systemctl itself."
    add_alias "c_reboot" "systemctl restart ${SERVICE}.service" "The same effect as c_reboot() in game but is being executed by systemctl itself."
    add_alias "c_start" "systemctl start ${SERVICE}.service" "Updates the game and starts the shards. The same as running "systemctl start" on the server's service."
    add_alias "c_shutdown" "systemctl stop ${SERVICE}.service" "The same effect as c_shutdown() in game but is being executed by systemctl itself."
    echo ""
    #cat "${BOOT_DIR}/commands.motd" # Display our custom MOTD
    echo "###############################################################"
    cd ${CLUSTER_PATH}/${CLUSTER}
fi

###################################################
