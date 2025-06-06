#!/usr/bin/env bash
#-----------------------------------------------------------------------------------------------------------------
# Copyright (c) Zeritiq.
# Licensed under the MIT License.
#-----------------------------------------------------------------------------------------------------------------
#
# Docs: https://github.com/zeritiq/arch-devcontainer-features/tree/master/src/clone-repo/README.md
# Maintainer: Zeritiq

set -e

# shellcheck disable=SC2034
REPO_URL="${REPOURL:-}"
TARGET_DIR="${TARGETDIR:-/workspace}"
BRANCH="${BRANCH:-}"
USERNAME="${USERNAME:-"${_REMOTE_USER:-"automatic"}"}"

# **************************
# ** Utility functions **
# **************************
_UTILS_SETUP_SCRIPT=$(mktemp)
curl -sSL -o "$_UTILS_SETUP_SCRIPT" https://raw.githubusercontent.com/bartventer/arch-devcontainer-features/main/scripts/archlinux_util_setup.sh
sh "$_UTILS_SETUP_SCRIPT"
rm -f "$_UTILS_SETUP_SCRIPT"

# shellcheck disable=SC1091
# shellcheck source=scripts/archlinux_util.sh
. archlinux_util.sh

# Setup STDERR.
err() {
    echo "(!) $*" >&2
}

# Source /etc/os-release to get OS info
# shellcheck disable=SC1091
. /etc/os-release

# Run checks
check_root
check_system
check_pacman

# Determine the appropriate non-root user
if [ "${USERNAME}" = "auto" ] || [ "${USERNAME}" = "automatic" ]; then
    USERNAME=""
    POSSIBLE_USERS=("vscode" "node" "codespace" "$(awk -v val=1000 -F ":" '$3==val{print $1}' /etc/passwd)")
    for CURRENT_USER in "${POSSIBLE_USERS[@]}"; do
        if id -u "${CURRENT_USER}" >/dev/null 2>&1; then
            USERNAME=${CURRENT_USER}
            break
        fi
    done
    if [ "${USERNAME}" = "" ]; then
        USERNAME=root
    fi
elif [ "${USERNAME}" = "none" ] || ! id -u "${USERNAME}" >/dev/null 2>&1; then
    USERNAME=root
fi

# Function to run commands as the appropriate user
sudo_if() {
    COMMAND="$*"
    if [ "$(id -u)" -ne 0 ]; then
        sudo $COMMAND
    else
        $COMMAND
    fi
}

echo "Starting repository clone feature installation..."

if [ -z "$REPO_URL" ]; then
    echo "No repository URL provided, skipping clone..."
    exit 0
fi

echo "Repository URL: $REPO_URL"
echo "Target directory: $TARGET_DIR"
if [ -n "$BRANCH" ]; then
    echo "Branch: $BRANCH"
fi

# Ensure git is available
echo "Checking for git..."
check_and_install_packages git

# Create target directory if it doesn't exist
if [ ! -d "$TARGET_DIR" ]; then
    echo "Creating target directory: $TARGET_DIR"
    mkdir -p "$TARGET_DIR"
fi

# If target directory is not empty, back it up
if [ -d "$TARGET_DIR" ] && [ "$(ls -A $TARGET_DIR)" ]; then
    BACKUP_DIR="${TARGET_DIR}.backup.$(date +%s)"
    echo "Target directory is not empty, backing up to: $BACKUP_DIR"
    mv "$TARGET_DIR" "$BACKUP_DIR"
    mkdir -p "$TARGET_DIR"
fi

# Clone the repository
echo "Cloning repository..."
if [ -n "$BRANCH" ]; then
    echo "Cloning specific branch: $BRANCH"
    git clone --branch "$BRANCH" "$REPO_URL" "$TARGET_DIR" || {
        err "Failed to clone repository with branch $BRANCH"
        exit 1
    }
else
    git clone "$REPO_URL" "$TARGET_DIR" || {
        err "Failed to clone repository"
        exit 1
    }
fi

# Set proper ownership
echo "Setting ownership of cloned repository..."
if [ "$(id -u)" = "0" ] && [ "${USERNAME}" != "root" ]; then
    # Running as root, set ownership to the non-root user
    chown -R "${USERNAME}:${USERNAME}" "$TARGET_DIR"
    echo "Ownership set to ${USERNAME}:${USERNAME}"
elif [ "$(id -u)" != "0" ]; then
    # Running as non-root, ensure current user owns the content
    sudo_if chown -R "$(id -u):$(id -g)" "$TARGET_DIR"
    echo "Ownership set to $(id -un):$(id -gn)"
fi

echo "Repository cloned successfully to $TARGET_DIR"
echo "Clone repository feature installation completed!"
