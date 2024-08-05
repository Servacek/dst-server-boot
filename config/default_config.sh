
################## COMMAND LINE OPTIONS #################

# https://support.klei.com/hc/en-us/articles/360029556192-Dedicated-Server-Command-Line-Options-Guide

# Set the name of the cluster directory that this server will use.
# The server will expect to find the cluster.ini file in the following location:
# <persistent_storage_root>/<conf_dir>/<cluster>/cluster.ini,
# where <persistent_storage_root> and <conf_dir> are the values
# set by the -persistent_storage_root and -conf_dir options. The default is "Cluster_1".
CLUSTER="MyDediServer"

# Change the name of your configuration directory.
# This name should not contain any slashes.
# The full path to your files will be <persistent_storage_root>/<conf_dir>
# where <persistent_storage_root> is the value set by the -persistent_storage_root option.
# The default is: "DoNotStarveTogether".
CONF_DIR="DoNotStarveTogether"

# Change the directory that your configuration directory resides in.
# This must be an absolute path.
# The full path to your files will be <persistent_storage_root>/<conf_dir>/
# where <conf_dir> is the value set by -conf_dir.
# The default for this option depends on the platform:
#   Windows: <Your documents folder>/Klei
#   Mac OSX: <Your home folder>/Documents/Klei
#   Linux: ~/.klei
PERSISTENT_STORAGE_ROOT="~/.klei"

# Updates server mods listed in the dedicated_server_mods_setup.lua file but does not launch a server.
ONLY_UPDATE_SERVER_MODS=false

# Skips mod updates.
SKIP_UPDATE_SERVER_MODS=false

# Create a backup of the previous log files each time the server is run.
# The backups will be stored in a directory called "backup" in the same directory as server.ini.
BACKUP_LOG_COUNT=128

# Valid values: 15 .. 60
# This is the number of times per-second that the server sends updates to clients.
# Increasing this may improve precision, but will result in more network traffic.
# This option overrides the [NETWORK] / tick_rate setting in cluster.ini.
# It is recommended to leave this at the default value of 15.
# If you do change this option, it is recommended that you do so only for LAN games,
# and use a number evenly divisible into 60 (15, 20, 30).
TICK=15

# Valid values: 1..64
# Set the maximum number of players that will be allowed to join the game.
# This option overrides the [GAMEPLAY] / max_players setting in cluster.ini.
PLAYERS=6

# Change the address that the server binds to when listening for player connections.
# This is an advanced feature that most people will not need to use.
BIND_IP="127.0.0.1"

################## CONFIGURATION #################

VALIDATE=true;
GAMEID=343050;
STEAMCMD="/usr/games/steamcmd";
LOGIN="anonymous";
# Directory where you Don't Starve Together Dedicated Server lives
# This is by default in your STEAMCMD directory.
GAMEDIR="${STEAMCMD}/steamapps/common/Don't Starve Together Dedicated Server";
MODS_SETUP_FILE_PATH="${GAMEDIR}/mods/dedicated_server_mods_setup.lua";
MODS_SETUP_FILE_BACKUP_PATH=$MODS_SETUP_FILE_PATH.bak;
X64=true;
DST_BIN="${GAMEDIR}/$(if [[ $X64 == true ]]; then echo "bin64"; else echo "bin"; fi)/dontstarve_dedicated_server_nullrenderer$(if [[ $X64 == true ]]; then echo "_x64"; fi)"
IGNORE_UPDATEM_FAILURE=false;

################## SHARDS #################

# Folder names for the individual shards this server has.
# At least one shard is required.
SHARDS=("Master" "Caves")
# Assign CPU cores to shards. The first number in this array is assigned
# to the first shard in the SHARDS array and so on.
# Only one CPU core is needed per shard since DST doesn't know how to work with multiple cores anyway.
# If you keep this empty, all available shards will be set as assigned so it will
# leave this task on your task scheduler to choose the best core for this process.
CPUCORES=()
# Explicitly assign ports to shards, this is the same as the "server_port" config in each
# of the shard's server.ini files.
# Ports are assigned in the order of the SHARDS array.
# If you keep this empty, the configuration from the server.ini files will be used instead.
PORTS=()

# The CPU core the Master shard should run on, i.e. the first one from the CPUCORES array.
# It is assumed this core is not used by another process.
# This is used by the server updating process as well before the server itself starts.
MAIN_CPUCORE=${CPUCORES[0]}

################## SESSIONS #################

SCREEN_SESSIONS=({$SHARDS[@]} + "Update")

#############################################
