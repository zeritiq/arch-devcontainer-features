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

# Function to get submodule commit hash
get_submodule_commit() {
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local feature_root="$(cd "${script_dir}/../.." && pwd)"
    
    # Check if we're in a git repository
    if ! git -C "$feature_root" rev-parse --git-dir >/dev/null 2>&1; then
        echo "main" # fallback to main branch
        return
    fi
    
    # Get commit hash of submodule
    local commit_hash
    commit_hash=$(git -C "$feature_root" ls-tree HEAD vendor/bartventer-features 2>/dev/null | awk '{print $3}')
    
    if [ -n "$commit_hash" ]; then
        echo "$commit_hash"
    else
        echo "main" # fallback to main branch
    fi
}

# Get bartventer commit and setup utils
echo "Determining bartventer-features version..."
BARTVENTER_COMMIT=$(get_submodule_commit)
echo "Using bartventer-features commit: $BARTVENTER_COMMIT"

_UTILS_SETUP_SCRIPT=$(mktemp)
UTILS_URL="https://raw.githubusercontent.com/bartventer/arch-devcontainer-features/${BARTVENTER_COMMIT}/scripts/archlinux_util_setup.sh"
echo "Downloading utils from: $UTILS_URL"

curl -sSL -o "$_UTILS_SETUP_SCRIPT" "$UTILS_URL" || {
    echo "Failed to download from commit $BARTVENTER_COMMIT, trying main branch..."
    curl -sSL -o "$_UTILS_SETUP_SCRIPT" "https://raw.githubusercontent.com/bartventer/arch-devcontainer-features/main/scripts/archlinux_util_setup.sh"
}

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

# Ensure git is available
echo "Checking for git..."
check_and_install_packages git

# Prepare directory structure with proper permissions (like yay does)
if [ -n "$TARGET_DIR" ] && [ "$TARGET_DIR" != "/" ]; then
    echo "Preparing target directory structure: $TARGET_DIR"
    
    # Create parent directories
    PARENT_DIR=$(dirname "$TARGET_DIR")
    if [ "$PARENT_DIR" != "/" ] && [ "$PARENT_DIR" != "." ]; then
        mkdir -p "$PARENT_DIR"
        
        # Set ownership to the determined user
        if [ "${USERNAME}" != "root" ]; then
            chown "${USERNAME}:${USERNAME}" "$PARENT_DIR"
            chmod 755 "$PARENT_DIR"
            echo "Set ownership of $PARENT_DIR to ${USERNAME}:${USERNAME}"
        fi
    fi
fi

# Create configuration file for the clone script
CLONE_CONFIG_FILE="/usr/local/etc/clone-repo-config"
echo "Creating clone configuration file: $CLONE_CONFIG_FILE"

cat > "$CLONE_CONFIG_FILE" << EOF
# Clone repository configuration
REPO_URL="$REPO_URL"
TARGET_DIR="$TARGET_DIR"
BRANCH="$BRANCH"
USERNAME="$USERNAME"
EOF

# Create the clone script to be executed in postCreateCommand
CLONE_SCRIPT="/usr/local/bin/clone-repo-ssh"
echo "Creating clone script: $CLONE_SCRIPT"

cat > "$CLONE_SCRIPT" << 'EOF'
#!/usr/bin/env bash
#-----------------------------------------------------------------------------------------------------------------
# Clone Repository SSH Script
# This script is executed during postCreateCommand to clone repositories with SSH support
#-----------------------------------------------------------------------------------------------------------------

set -e

# Load configuration
CONFIG_FILE="/usr/local/etc/clone-repo-config"
if [ -f "$CONFIG_FILE" ]; then
    # shellcheck disable=SC1090
    . "$CONFIG_FILE"
else
    echo "Configuration file not found: $CONFIG_FILE"
    exit 1
fi

# Function to print errors
err() {
    echo "(!) $*" >&2
}

echo "Starting repository clone from postCreateCommand..."

if [ -z "$REPO_URL" ]; then
    echo "No repository URL provided, skipping clone..."
    exit 0
fi

echo "Repository URL: $REPO_URL"
echo "Target directory: $TARGET_DIR"
if [ -n "$BRANCH" ]; then
    echo "Branch: $BRANCH"
fi

# Check if git is available
if ! command -v git >/dev/null 2>&1; then
    err "Git is not installed"
    exit 1
fi

# Create target directory if it doesn't exist (should already be prepared by install.sh)
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

# Configure git to use SSH if available and URL is SSH
if [[ "$REPO_URL" == git@* ]]; then
    echo "SSH URL detected, checking SSH configuration..."
    
    # Check if SSH agent is running
    if [ -z "$SSH_AUTH_SOCK" ]; then
        echo "SSH agent not running, attempting to start..."
        eval "$(ssh-agent -s)"
    fi
    
    # Check if we have SSH keys
    if [ ! -d "$HOME/.ssh" ] || [ -z "$(ls -A $HOME/.ssh/id_* 2>/dev/null)" ]; then
        echo "Warning: No SSH keys found in $HOME/.ssh/"
        echo "SSH clone may fail. Consider setting up SSH keys or using HTTPS URL."
    fi
fi

# Clone the repository
echo "Cloning repository..."
if [ -n "$BRANCH" ]; then
    echo "Cloning specific branch: $BRANCH"
    if git clone --branch "$BRANCH" "$REPO_URL" "$TARGET_DIR"; then
        echo "Successfully cloned branch $BRANCH"
    else
        err "Failed to clone repository with branch $BRANCH"
        
        # If SSH failed and URL is SSH, suggest HTTPS alternative
        if [[ "$REPO_URL" == git@* ]]; then
            echo "SSH clone failed. Consider using HTTPS URL instead."
            # Try to convert SSH URL to HTTPS
            HTTPS_URL=$(echo "$REPO_URL" | sed 's|git@github.com:|https://github.com/|' | sed 's|git@gitlab.com:|https://gitlab.com/|' | sed 's|git@bitbucket.org:|https://bitbucket.org/|')
            echo "HTTPS equivalent would be: $HTTPS_URL"
        fi
        exit 1
    fi
else
    if git clone "$REPO_URL" "$TARGET_DIR"; then
        echo "Successfully cloned repository"
    else
        err "Failed to clone repository"
        
        # If SSH failed and URL is SSH, suggest HTTPS alternative
        if [[ "$REPO_URL" == git@* ]]; then
            echo "SSH clone failed. Consider using HTTPS URL instead."
            # Try to convert SSH URL to HTTPS
            HTTPS_URL=$(echo "$REPO_URL" | sed 's|git@github.com:|https://github.com/|' | sed 's|git@gitlab.com:|https://gitlab.com/|' | sed 's|git@bitbucket.org:|https://bitbucket.org/|')
            echo "HTTPS equivalent would be: $HTTPS_URL"
        fi
        exit 1
    fi
fi

echo "Repository cloned successfully to $TARGET_DIR"
echo "Clone repository feature completed successfully!"

# Clean up the config file after successful clone
rm -f "$CONFIG_FILE"
EOF

# Make the clone script executable
chmod +x "$CLONE_SCRIPT"

echo "Clone repository feature installation completed!"
echo "Repository will be cloned automatically via postCreateCommand when container starts."
