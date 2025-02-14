#!/bin/bash

GROUP_NAME="steam"
if ! $(groups $USER | grep -q "\b${GROUP_NAME}\b"); then
    return; # Ignore other users outside the group
fi

IGNORE_USERS=('steam')
for user in "${IGNORE_USERS[@]}"; do
    if [[ $user == $USER ]]; then
        return
    fi
done

# Has to be defined before sourcing constants.sh
exit() {
   echo "Profile.d script exited prematurely."
}

echo ""
BOOT_DIRECTORY="/home/steam/.klei/DoNotStarveTogether/.game/boot"
PADDING="    "
cd $BOOT_DIRECTORY
source "${BOOT_DIRECTORY}/constants.sh"

if [[ $OVERRIDE_DEFAULT_MOTD == true ]]; then
    clear
else
    echo ""
fi

if [[ -s "${BANNER_PATH}" ]]; then
    echo -ne "${ORANGE}"
    cat "${BANNER_PATH}"
    echo -ne "${NC}"
else
    echo "######################### ${CLUSTER} SERVER #########################"
fi
echo -n "${PADDING}Version: "
echo -ne "${ORANGE}"
cat "${VERSION_PATH}"
echo -ne "${NC}"
#echo -e "\n"
#echo -e "${BOLD}NOTES${NC}"
#echo -e "${PADDING}"
echo ""
echo -e "${BOLD}CUSTOM COMMAND LINE OPTIONS"

ALIASES=()

# A wrapper around the built-in "alias" command.
add_alias() { # alias_name, command, description, add_to_sudoers
    alias ${1}="${2}"
    if [[ ${4} == true ]]; then
        ALIASES+=("${2}")
    fi

    echo -e "${PADDING}${BOLD}${1}${NC}\t${3}"
}

add_alias "wmods" "cd ${GAMEDIR}/ugc_mods/${CLUSTER}/Master/content/${GAMEID}" "Change your pwd to the ${CLUSTER} server's ugc_mods directory storing newer workshop mods."
add_alias "imods" "nano ${MODS_SETUP_FILE_PATH}" "Opens the appropriate \"dedicated_server_mods_setup.lua\" in edit mode."
add_alias "sboot" "cd ${GAMEDIR}/boot" "Change your pwd to the ${CLUSTER} server's boot directory."
add_alias "blogs" "sudo journalctl -u ${SERVICE}.service -f -q --line=50" "Shows the journal logs of the server's boot process, following new changes."
add_alias "slogs" "if [[ -f server_log.txt ]]; then nano server_log.txt; else nano ${CLUSTER_PATH}/${SHARDS[0]}/server_log.txt; fi" "Shows the logs from the server_log.txt file of shard directory or logs from the Master shard by default."
add_alias "screens" "sudo ls -laR /var/run/screen/" "Displays all active screen sessions on this machine. Useful for debugging."
add_alias "ports" ' \
for session in ${SHARD_SCREEN_SESSIONS[@]}; do \
    screen_pid=$(screen -ls ${SESSION_OWNER}/ | grep "${session}" | awk "{print $1}" | cut -d. -f1 | sed "s/^[ \t]*//;s/[ \t]*$//"); \
    pid=$(_deepest="$screen_pid"; while [[ (! -z "$_deepest") && $(pgrep -P "$_deepest") ]]; do _deepest=$(pgrep -P "$_deepest"); done; echo "$_deepest"); \
    if [[ ! -z "$pid" ]]; then \
        echo "${BOLD}$session${NC}"; \
        sudo netstat -tulnp | grep ${pid}; \
        echo ""; \
    else \
        echo -e "${PADDING}${BOLD}$session${NC}\t${UNDERLINE}State${NC} ${RED}inactive${NC}"; \
    fi; \
done' "Displays the ports currently used by the server shard process(es)."
add_alias "status" ' \
for session in ${SHARD_SCREEN_SESSIONS[@]}; do \
    screen_pid=$(screen -ls ${SESSION_OWNER}/ | grep "${session}" | awk "{print $1}" | cut -d. -f1 | sed "s/^[ \t]*//;s/[ \t]*$//"); \
    pid=$(_deepest="$screen_pid"; while [[ (! -z "$_deepest") && $(pgrep -P "$_deepest") ]]; do _deepest=$(pgrep -P "$_deepest"); done; echo "$_deepest"); \
    pname=$(if [[ ! -z "$pid" ]]; then echo $(ps -p "$pid" -o comm=); fi); \
    if [[ "$pname" != "$DST_SERVER_PROCESS_NAME" ]]; then \
        echo -e "${PADDING}${BOLD}$session${NC}\n\t\t${UNDERLINE}State${NC} ${RED}inactive${NC}"; \
    else \
        cpu_affinity=$(taskset -pc "$pid" 2>/dev/null | sed -n "s/.*: \(.*\)/\1/p"); \
        cpu_usage=$(ps -p $pid -o %cpu --no-headers); \
        mem_usage=$(ps -p $pid -o %mem --no-headers); \
        echo -e "${PADDING}${BOLD}$session${NC}\n\t\t${UNDERLINE}State${NC} ${GREEN}active${NC}\t${UNDERLINE}CPU core(s)${NC} $cpu_affinity\t${UNDERLINE}CPU usage${NC} $cpu_usage%\t${UNDERLINE}Memory usage${NC} $mem_usage%\t${UNDERLINE}PID${NC} $pid"; \
    fi; \
done' "Displays the state and additional info of the shard screen sessions and server processes for the ${CLUSTER} cluster."

echo ""
for SHARD in ${SHARDS[@]}; do
    add_alias "${SHARD,,}" "cd ${CLUSTER_PATH}/${SHARD}" "Change your pwd to the ${CLUSTER} server's ${SHARD} shard directory."
    add_alias "c_${SHARD,,}" "screen -r ${SESSION_OWNER}/${SHARD_SESSION_PREFIX}${SHARD}" "Open the console for the ${SHARD} shard."
done

echo ""
add_alias "c_reload" "sudo /bin/systemctl reload ${SERVICE}.service" "The same effect as c_reload() in game but is being executed by systemctl itself." true
add_alias "c_reboot" "sudo /bin/systemctl restart ${SERVICE}.service" "The same effect as c_reboot() in game but is being executed by systemctl itself." true
add_alias "c_start" "sudo /bin/systemctl start ${SERVICE}.service" "Updates the game and starts the shards. The same as running \"systemctl start\" on the server's service." true
add_alias "c_shutdown" "sudo /bin/systemctl stop ${SERVICE}.service" "The same effect as c_shutdown() in game but is being executed by systemctl itself." true

# Ensure the alias is recognized in the current shell
shopt -s expand_aliases

# We do not want to have a password prompt at login
if [[ $ADD_ALIASES_TO_SUDOERS == true ]]; then
    echo -e "\n${BOLD}SERVER STATUS${NC}"
    status
fi

echo ""
#echo "###############################################################"
echo ""

cd "${CLUSTER_PATH}"
