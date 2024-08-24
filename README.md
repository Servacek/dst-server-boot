# Don't Starve Together Dedicated Server Boot Script
Linux shell script for booting up, updating and managing a Don't Starve Together Dedicated Server with multiple shards on Linux CLI systems with advanced options and easy configuration, installation and updates.

![image](https://github.com/user-attachments/assets/366580b1-11da-4879-ad57-0caab8cfb3d4)

## General Dependencies
- Linux
- git
- Bash 5.0+

## Supported Systems
- Debian 5 (64-bit) (the only system this was tested on so far)

## Installation
1. `git clone` this repository to the desired location on your system.
3. Run the `INSTALL.sh` file inside the newly downloaded directory and follow the instructions there.

![image](https://github.com/user-attachments/assets/d64f4b9b-048f-411a-a3f8-6af7bd5dfe26)

*The first part of the installation process after running [`./INSTALL.sh`](https://github.com/Servacek/dst-server-boot/blob/main/INSTALL.sh). You will be prompted on all possibly destructive changes.*

## Features
- Each shard runs in it's own separate interactive screen.
- Server is managed as a [systemd forking service](https://www.freedesktop.org/software/systemd/man/latest/systemd.service.html#Type=) which allows much easier control over it's processes.
- Restarting on-failure per shard process.
- Registering custom crontab jobs for the server's process right from `config.sh`.
- Support for all documented (and even some undocumented) configuration options for the server's process.
- Custom MOTD override for user's in the management group displaying the list of custom commands and the current state of the server.
- Interactive and easy installation and updating process using the [`INSTALL.sh`](https://github.com/Servacek/dst-server-boot/blob/main/INSTALL.sh) and [`UPDATE.sh`](https://github.com/Servacek/dst-server-boot/blob/main/UPDATE.sh) files.
- Centralized configuration from `config.sh` and `screen.conf`.
- Custom command aliases for selected group of users for easier management of the server.
- Ability to select specific core or core range for each of the cluster's shards.
- Updating of the game's files on boot and file validation without overriding the `dedicated_server_mods_setup.lua` file.

![image](https://github.com/user-attachments/assets/06f0a6a1-ec9f-4ad1-aae0-4c50fa20843e)
*Output of the custom `status` command alias displaying the current state of the server and it's load on the system's resources.*

## Script Specific Configurations
You can find those at the bottom of your `config/config.sh` file in the root directory of this repository which is created
right after you run INSTALL.sh or UPDATE.sh as a copy of [`/config/default_config.sh`](https://github.com/Servacek/dst-server-boot/blob/main/config/default_config.sh). The same goes for the

For the default values please refer to [`/config/default_config.sh`](https://github.com/Servacek/dst-server-boot/blob/main/config/default_config.sh).

| Name  | Description | Type |
| ------------- | ------------- | ------------- |
| x64  | Whether to use the 64-bit binaries or the default 32 bit ones.  | boolean |
| SESSION_OWNER | The user allowed to manage the server. Or the user this server should run as. | string |
| SESSION_OWNER_GROUP | The name of the group for users allowed to manage the server. | string |
| IGNORE_USERS | List of users that should be ignore even though they are in the desired group. | array of strings |
| SERVICE | The name of the service for this server that should be created and used for managing the server's processes. | string |
| GAMEDIR | Directory where you Don't Starve Together Dedicated Server lives. This is by default in your STEAMCMD directory. | string |
| TIME_UNTIL_AUTO_RESTART | Seconds to wait after the server exists with a non-zero status. | integer |
| TIME_BETWEEN_SHARDS | Time before starting the next shard. Note that the Master shard of the server will always start first. | integer |
| SHUTDOWN_TIMEOUT | Seconds to wait for the server to gracefully shutdown before forcefully killing the processes. | integer |
| SHUTDOWN_COMMAND | The Lua command sent to each of the server's shard processes for gracefull shutdown. | string |
| RELOAD_COMMAND | The Lua command sent to the Master shard process for gracefull reloading of the shard. | string |
| ADD_ALIASES | Whether to add our custom aliases using the add_alias bash command or not. | boolean |
| ENSURE_DEPENDENCIES | Support for alternative dependencies for the server binaries. If this is set to true (default) you will be acknowledged about what default dependencies are going to be installed on your system and can decide whether you want them or not. | boolean |
| OVERRIDE_DEFAULT_MOTD | Whether to use our custom MOTD with the command list and server status instead of the built in one for the users in the management group (`$SESSION_OWNER_GROUP`) | boolean |
ADD_ALIASES_TO_SUDOERS | Whether to add alias commands to a sudoers file so you do not have to provide a password when running "sudo $alias" as a user of the `$SESSION_OWNER_GROUP` group or the user `$SESSION_OWNER`. | boolean |

## Server Tasks
This allows you to configure crontab jobs for your server process (for example for maintenace).
The configuration file is installed upon executing INSTALL.sh or [`UPDATE.sh`](https://github.com/Servacek/dst-server-boot/blob/main/UPDATE.sh). So after each change to these configurations, do not forget to run one of those files.
| Name  | Description | Type |
| ------------- | ------------- | ------------- |
| CRON_TASK_SCHEDULES | An array of crontab compatible schedule expressions | array of strings |
| CRON_TASK_COMMANDS | Commands to run on the specific schedules above (indexes match). These commands will run under your /bin/bash and inside this repositories root directory. | array of strings |
| CRON_ENABLE | Whether to enable the crontab jobs and install them to your `/etc/cron.d` directory as a cron configuration file named after `$SESSION_OWNER` | boolean |

## Customizing The Screen Sessions
Customization of the screen sessions created by this script is managed by the `config/screen.conf` file created as a copy of the [`config/default_screen.conf`](https://github.com/Servacek/dst-server-boot/blob/main/config/default_screen.conf) file after installation or update.

You can read more about the options you have in the [official documentation of GNU screen](https://www.gnu.org/software/screen/manual/screen.html#Startup-Files)

## References
- https://www.freedesktop.org/software/systemd/man/latest/systemd.exec.html
- https://www.gnu.org/software/screen/manual/html_node/index.html#SEC_Contents
- https://support.klei.com/hc/en-us/articles/360029556192-Dedicated-Server-Command-Line-Options-Guide
- https://forums.kleientertainment.com/forums/topic/64441-dedicated-server-quick-setup-guide-linux/
- https://forums.kleientertainment.com/forums/topic/64552-dedicated-server-settings-guide/
- https://man7.org/linux/man-pages/man1/taskset.1.html
- https://www.gnu.org/software/screen/manual/screen.html
- https://www.freedesktop.org/software/systemd/man/latest/systemd.service.html
- https://www.digitalocean.com/community/tutorials/how-to-edit-the-sudoers-file
- https://www.linuxfromscratch.org/blfs/view/11.0/postlfs/profile.html
