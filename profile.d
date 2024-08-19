#!/bin/bash

GROUP_NAME="steam"
if ! $(groups $USER | grep -q "\b${GROUP_NAME}\b"); then
    return; # Ignore other users outside the group
fi

IGNORE_USERS=()
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
BOOT_DIRECTORY="~/.klei/DoNotStarveTogether/.game/boot"
cd $BOOT_DIRECTORY
source "${BOOT_DIRECTORY}/constants.sh"

if [[ $OVERRIDE_DEFAULT_MOTD == true ]]; then
    clear
else
    echo ""
fi

if [[ -s "${BANNER_PATH}" ]]; then
    cat "${BANNER_PATH}"
else
    echo "######################### ${CLUSTER} SERVER #########################"
fi
echo -n "Version: "
cat "${VERSION_PATH}"
echo -e "${BOLD}NOTES"
echo -e "\tTo use"
echo ""
echo -e "${BOLD}CUSTOM COMMAND LINE OPTIONS"

ALIASES=()

# A wrapper around the built-in "alias" command.
add_alias() {
    alias ${1}="${2}"
    ALIASES+=(${1})
    echo -e "   ${BOLD}${1}${NC}\t ${3}"
}

add_alias "wmods" "cd ${GAMEDIR}/ugc_mods/${CLUSTER}/Master/content/${GAMEID}" "Change your pwd to the ${CLUSTER} server's ugc_mods directory storing newer workshop mods."
add_alias "mods" "cd ${GAMEDIR}/mods" "Change your pwd to the ${CLUSTER} server's mods directory."
add_alias "sboot" "cd ${GAMEDIR}/boot" "Change your pwd to the ${CLUSTER} server's boot directory."
add_alias "blogs" "sudo journalctl -u ${SERVICE}.service -f -q --line=50" "Shows the journal logs of the server's boot process, following new changes."
add_alias "slogs" "if [[ -f server_log.txt ]]; then nano server_log.txt; else nano ${CLUSTER_PATH}/${SHARDS[0]}/server_log.txt; fi" "Shows the logs from the server_log.txt file of shard directory or logs from the Master shard by default."
add_alias "screens" "sudo ls -laR /var/run/screen/" "Displays all active screen sessions on this machine. Useful for debugging."
add_alias "ports" ' \
for session in ${SHARD_SCREEN_SESSIONS[@]}; do \
    screen_pid=$(sudo -u "${SESSION_OWNER}" screen -ls | grep "${session}" | awk "{print $1}" | cut -d. -f1 | sed "s/^[ \t]*//;s/[ \t]*$//"); \
    pid=$(_deepest="$screen_pid"; while [[ (! -z "$_deepest") && $(pgrep -P "$_deepest") ]]; do _deepest=$(pgrep -P "$_deepest"); done; echo "$_deepest"); \
    if [[ ! -z "$pid" ]]; then \
        echo "${session}:"; \
        sudo netstat -tulnp | grep ${pid}; \
        echo ""; \
    else \
        echo -e "$session:\t${RED}inactive${NC}"; \
    fi; \
done' "Displays the ports currently used by the server shard process(es)."
add_alias "status" ' \
for session in ${SHARD_SCREEN_SESSIONS[@]}; do \
    screen_pid=$(sudo -u "${SESSION_OWNER}" screen -ls | grep "${session}" | awk "{print $1}" | cut -d. -f1 | sed "s/^[ \t]*//;s/[ \t]*$//"); \
    pid=$(_deepest="$screen_pid"; while [[ (! -z "$_deepest") && $(pgrep -P "$_deepest") ]]; do _deepest=$(pgrep -P "$_deepest"); done; echo "$_deepest"); \
    pname=$(if [[ ! -z "$pid" ]]; then echo $(ps -p "$pid" -o comm=); fi); \
    if [[ "$pname" != "$DST_SERVER_PROCESS_NAME" ]]; then \
        echo -e "$session:\t${RED}inactive${NC}"; \
    else \
        cpu_affinity=$(taskset -pc "$pid" 2>/dev/null | sed -n "s/.*: \(.*\)/\1/p"); \
        cpu_usage=$(ps -p $pid -o %cpu --no-headers); \
        mem_usage=$(ps -p $pid -o %mem --no-headers); \
        echo -e "$session:\t${GREEN}active${NC},\tCPU core(s): $cpu_affinity,\tCPU usage: $cpu_usage%,\tMemory usage: $mem_usage%\tPID: $pid"; \
    fi; \
done' "Displays the state and additional info of the shard screen sessions and server processes for the ${CLUSTER} cluster."

echo ""
for SHARD in ${SHARDS[@]}; do
    add_alias "${SHARD,,}" "cd ${CLUSTER_PATH}/${SHARD}" "Change your pwd to the ${CLUSTER} server's ${SHARD} shard directory."
    add_alias "c_${SHARD,,}" "screen -r ${SESSION_OWNER}/${SHARD_SESSION_PREFIX}${SHARD}" "Open the console for the ${SHARD} shard."
done

echo ""
add_alias "c_reload" "sudo systemctl reload ${SERVICE}.service" "The same effect as c_reload() in game but is being executed by systemctl itself."
add_alias "c_reboot" "sudo systemctl restart ${SERVICE}.service" "The same effect as c_reboot() in game but is being executed by systemctl itself."
add_alias "c_start" "sudo systemctl start ${SERVICE}.service" "Updates the game and starts the shards. The same as running \"systemctl start\" on the server's service."
add_alias "c_shutdown" "sudo systemctl stop ${SERVICE}.service" "The same effect as c_shutdown() in game but is being executed by systemctl itself."
echo ""
echo "###############################################################"
echo ""

# We do not want to have a password prompt at login
if [[ $ADD_ALIASES_TO_SUDOERS == true ]]; then
    sudo status
fi

cd "${CLUSTER_PATH}"
