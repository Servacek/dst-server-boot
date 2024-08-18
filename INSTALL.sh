#!/bin/bash

safe_copy_file() { # src, dst
    COPYING=true
    if [[ -f "${2}" ]]; then
        while true; do
            read -p "File ${2} already exists. Overwrite it? [y/n] " yn
            case $yn in
                [Yy]* ) break;; # Continue
                [Nn]* ) COPYING=false; break;; # Exit program and open config file in edit mode
                * ) echo "Please answer yes or no.";;
            esac
        done
    fi

    if [[ $COPYING == true ]]; then
        echo "Copying ${1} to ${2}..."
        sudo cp "${1}" "${2}"
    fi
}

change_field () { # file, key, value
    sed -i "s|^${2}=.*|${2}=${3}|" "${1}"
}

apply_overrides() { # file, overrides
    for i in "${!${2}[@]}"; do
        KEY="${i}"
        VALUE="${${2}[$i]}"

        change_field "${1}" "${KEY}" "${VALUE}"
    done
}

####### CONFIGURATION #######

# This will ensure that the ${CONFIG_FILE} actually exists.
. constants.sh

while true; do
    read -p "Are you happy with the configurations in ${CONFIG_FILE}? (y/n)" yn
    case $yn in
        [Yy]* ) break;; # Continue
        [Nn]* ) nano ${CONFIG_FILE}; return;; # Exit program and open config file in edit mode
        * ) echo "Please answer yes or no.";;
    esac
done

####### DEPENDENCIES #######
# https://forums.kleientertainment.com/forums/topic/64441-dedicated-server-quick-setup-guide-linux/

echo "Installing dependencies..."

if [[ $X32_MACHINE == true ]]; then
    sudo apt-get install libstdc++6 libgcc1 libcurl4-gnutls-dev
else
    sudo apt-get install libstdc++6:i386 libgcc1:i386 libcurl4-gnutls-dev:i386
fi

if [[ ! -d "${STEAMCMD}" && ! -f "${STEAMCMD}" ]]; then
    echo "Installing steamcmd..."
    mkdir -p "${STEAMCMD}"
    if ! cd "${STEAMCMD}"; then
        break
    fi

    wget "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz"
    tar -xvzf steamcmd_linux.tar.gz

    STEAMCMD="${STEAMCMD}/steamcmd.sh"
fi

####### CLUSTER TOKEN #######

# Make sure the cluster folder structure exists so we have a place to put the token in.
mkdir -p "${CLUSTER_PATH}/${CLUSTER}"

if [[ ! -f "${CLUSTER_TOKEN_PATH}" ]]; then
    echo "No cluster token found in your ${CLUSTER_TOKEN_PATH}!"
    echo "Please visit https://accounts.klei.com/account/game/servers?game=DontStarveTogether login into it and get a token from your existing server ir create a new one via the Add New Server button at the bottom."
    while true; do
        read -p "Enter your newly generated token: " TOKEN
        # check if the token is valid
        if [[ ! -z "$TOKEN" ]]; then
            echo "$TOKEN" > "${CLUSTER_TOKEN_PATH}"
            echo "Cluster token saved to ${CLUSTER_TOKEN_PATH}"
            break
        else
            echo "Invalid token. Please try again."
        fi
    done
fi

####### SYSTEMD SERVICE #######

SERVICE_FILE_PATH="/etc/systemd/system/${SERVICE}.service"
LOCAL_SERVICE_FILE_PATH="dstserver.service"
declare -A SERVICE_OVERRIDES=(
    [User]="${SESSION_OWNER}"
    [Group]="${SESSION_OWNER_GROUP}"
    [WorkingDirectory]="${WORKING_DIRECTORY}"
)

apply_overrides "${LOCAL_SERVICE_FILE_PATH}" "${SERVICE_OVERRIDES}"
safe_copy_file "${LOCAL_SERVICE_FILE_PATH}" "${SERVICE_FILE_PATH}"

####### PROFILE.D #######

LOCAL_PROFILE_FILE_PATH="profile.d"
PROFILE_FILE_PATH="/etc/profile.d/${SESSION_OWNER_GROUP}.sh"
declare -A PROFILE_OVERRIDES=(
    [GROUP_NAME]="${SESSION_OWNER_GROUP}"
    [IGNORE_USERS]="${IGNORE_USERS[@]}"
    [BOOT_DIRECTORY]="${WORKING_DIRECTORY}"
)

apply_overrides "${LOCAL_PROFILE_FILE_PATH}" "${PROFILE_OVERRIDES}"
safe_copy_file "${LOCAL_PROFILE_FILE_PATH}" "${PROFILE_FILE_PATH}"

. "${PROFILE_FILE_PATH}"

####### DONE! #######

echo "Booting scripts successfully installed!"
echo "You can now start the server using the c_start command!"
