# Values that are not overridable in cluster.ini or server.ini have their default values here.

################## COMMAND LINE OPTIONS #################

# https://support.klei.com/hc/en-us/articles/360029556192-Dedicated-Server-Command-Line-Options-Guide

# Set the name of the cluster directory that this server will use.
# The server will expect to find the cluster.ini file in the following location:
# <persistent_storage_root>/<conf_dir>/<cluster>/cluster.ini,
# where <persistent_storage_root> and <conf_dir> are the values
# set by the -persistent_storage_root and -conf_dir options.
# The default is "Cluster_1".
CLUSTER="Cluster_1"

# Change the name of your configuration directory.
# This name should not contain any slashes.
# The full path to your files will be <persistent_storage_root>/<conf_dir>
# where <persistent_storage_root> is the value set by the -persistent_storage_root option.
# The default is: "DoNotStarveTogether".
CONF_DIR="DoNotStaveTogether"

# Start the server in offline mode. In offline mode, the server will not be listed publicly,
# only players on the local network will be able to join, and any steam-related functionality will not work.
# Default value: false
OFFLINE=""

# Disable data collection for the server.
# We require the collection of user data to provide online services.
# Servers with disabled data collection will only have access to play in offline mode.
# For more details on our privacy policy and how we use the data we collect,
# please see our official privacy policy. https://klei.com/privacy-policy
# Default value: false
DISABLEDATACOLLECTION=""

# https://forums.kleientertainment.com/forums/topic/118972-unix-python-web-portal-for-dedicated-dst-server/?do=findComment&comment=1344090
# Default value: false
CLOUDSERVER=""

# Change the directory that your configuration directory resides in.
# This must be an absolute path.
# The full path to your files will be <persistent_storage_root>/<conf_dir>/
# where <conf_dir> is the value set by -conf_dir.
# The default for this option depends on the platform:
#   Windows: <Your documents folder>/Klei
#   Mac OSX: <Your home folder>/Documents/Klei
#   Linux: ~/.klei
# Default value: "~/.klei"
PERSISTENT_STORAGE_ROOT="~/.klei"

# Updates server mods listed in the dedicated_server_mods_setup.lua file but does not launch a server.
# Default value: false
ONLY_UPDATE_SERVER_MODS=""

# Skips mod updates.
# Default value: false
SKIP_UPDATE_SERVER_MODS=""

# Create a backup of the previous log files each time the server is run.
# The backups will be stored in a directory called "backup" in the same directory as server.ini.
# This option overrides the [MISC] / max_snapshots setting in cluster.ini.
# Default value: 128
BACKUP_LOG_COUNT=""

# Valid values: 15 .. 60
# This is the number of times per-second that the server sends updates to clients.
# Increasing this may improve precision, but will result in more network traffic.
# This option overrides the [NETWORK] / tick_rate setting in cluster.ini.
# It is recommended to leave this at the default value of 15.
# If you do change this option, it is recommended that you do so only for LAN games,
# and use a number evenly divisible into 60 (15, 20, 30).
# Default value: 15
TICK=""

# Monitors the parent process whose PID you provide.
# When this process exists, the server will exit as well.
MONITOR_PARENT_PROCESS=""

# Valid values: 1..64
# Set the maximum number of players that will be allowed to join the game.
# This option overrides the [GAMEPLAY] / max_players setting in cluster.ini.
# Default value: 6
PLAYERS=""

# Change the address that the server binds to when listening for player connections.
# This is an advanced feature that most people will not need to use.
# This option overrides the [SHARD] / bind_ip setting in cluster.ini.
# Default value: 0.0.0.0
BIND_IP=""

# Set the name of the shard directory that this server will use.
# The server will expect to find the server.ini file in the following location:
# <persistent_storage_root>/<conf_dir>/<cluster>/<shard>/server.ini,
# where <persistent_storage_root>, <conf_dir>, and <cluster> are the values
# set by the -persistent_storage_root, -conf_dir, and -cluster options.
# The default is "Master".
SHARDS=("Master")
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

# Valid values: 1..65535
# Internal port used by steam.
# This option overrides the [STEAM] / authentication_port setting in server.ini.
# Make sure that this is different for each server you run on the same machine.
# Default value: randomly chooses an available port for each shard
STEAM_AUTHENTICATION_PORTS=()

# Valid values: 1..65535
# Internal port used by steam.
# This option overrides the [STEAM] / master_server_port setting in server.ini.
# Make sure that this is different for each server you run on the same machine.
# Default value: randomly chooses an available port for each shard
STEAM_MASTER_SERVER_PORTS=()

################## CONFIGURATION #################

VALIDATE=true;
GAMESERVERID=343050
GAMEID=322330;
STEAMCMD="/usr/games/steamcmd";
LOGIN="anonymous";
# Directory where you Don't Starve Together Dedicated Server lives
# This is by default in your STEAMCMD directory.
GAMEDIR="${STEAMCMD}/steamapps/common/Don't Starve Together Dedicated Server";
MODS_SETUP_FILE_PATH="${GAMEDIR}/mods/dedicated_server_mods_setup.lua";
MODS_SETUP_FILE_BACKUP_PATH="${MODS_SETUP_FILE_PATH}.bak";
X64=true;
DST_BIN="${GAMEDIR}/$(if [[ $X64 == true ]]; then echo "bin64"; else echo "bin"; fi)/dontstarve_dedicated_server_nullrenderer$(if [[ $X64 == true ]]; then echo "_x64"; fi)"

SHARD_SESSION_PREFIX="${GAMESERVERID}_${CLUSTER}_"
SESSION_OWNER="steam"

SERVICE="dstserver"
DST_SERVER_PROCESS_NAME="dontstarve_dedi"

MASTER_SHARD_INDEX=0

TIME_UNTIL_AUTO_RESTART=60 # Seconds
TIME_BETWEEN_SHARDS=10 # Seconds

SHUTDOWN_COMMAND="c_shutdown(true)"
RELOAD_COMMAND="c_reset()"

LOG_FILE="${GAMEDIR}/boot/startup.log"

#############################################
