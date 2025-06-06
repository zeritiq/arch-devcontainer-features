#!/bin/bash

set -e

# Clone Repository Feature
# This feature clones a Git repository into the container workspace

REPO_URL="${REPOURL:-}"
TARGET_DIR="${TARGETDIR:-/workspace}"
BRANCH="${BRANCH:-}"

echo "Starting repository clone feature installation..."

if [ -z "$REPO_URL" ]; then
    echo "No repository URL provided, skipping clone..."
    exit 0
fi

echo "Repository URL: $REPO_URL"
echo "Target directory: $TARGET_DIR"

# Ensure git is available
if ! command -v git &> /dev/null; then
    echo "Git is not installed. Please ensure git is available in the container."
    exit 1
fi

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
        echo "Failed to clone repository with branch $BRANCH"
        exit 1
    }
else
    git clone "$REPO_URL" "$TARGET_DIR" || {
        echo "Failed to clone repository"
        exit 1
    }
fi

# Set proper ownership if we're not running as root
if [ "$(id -u)" != "0" ]; then
    echo "Setting ownership of cloned repository..."
    # If running as non-root, ensure the user owns the cloned content
    if command -v sudo &> /dev/null; then
        sudo chown -R "$(id -u):$(id -g)" "$TARGET_DIR"
    fi
fi

echo "Repository cloned successfully to $TARGET_DIR"
echo "Clone repository feature installation completed!"
