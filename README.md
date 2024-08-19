# Don't Starve Together Server Boot Script
Linux shell script for booting up and updating a DST Dedicated server with advanced options and easy configuration.

![image](https://github.com/user-attachments/assets/366580b1-11da-4879-ad57-0caab8cfb3d4)

## General Dependencies
- Linux
- git
- Bash 5.0+

## Installation
1. `git clone` this repository to the desired location on your system.
3. Run the `INSTALL.sh` file inside the newly downloaded directory and follow the instructions there.

## Features
- Centralized configuration from `config.sh`.
- Custom command aliases for selected group of users for easier management of the server.
- Ability to select specific core or core range for each of the cluster's shards.
- Updating of the game's files on boot and file validation without overriding the `dedicated_server_mods_setup.lua` file.
- Automatic adding of crontab jobs and sudoers rules any many more configurations were automatized!
- Restarting on-failure per shard process.

![image](https://github.com/user-attachments/assets/06f0a6a1-ec9f-4ad1-aae0-4c50fa20843e)

## Notes
- Tested only on Debian 5.10.149-2 x86_64

## References
- https://www.freedesktop.org/software/systemd/man/latest/systemd.exec.html
- https://www.gnu.org/software/screen/manual/html_node/index.html#SEC_Contents
- https://support.klei.com/hc/en-us/articles/360029556192-Dedicated-Server-Command-Line-Options-Guide
- https://forums.kleientertainment.com/forums/topic/64441-dedicated-server-quick-setup-guide-linux/
- https://forums.kleientertainment.com/forums/topic/64552-dedicated-server-settings-guide/
- https://man7.org/linux/man-pages/man1/taskset.1.html




