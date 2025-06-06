# Clone Repository (clone-repo)

Automatically clones a Git repository into your devcontainer workspace during container creation.

## Description

This feature allows you to automatically clone a Git repository into a specified directory during devcontainer creation. Useful for:

- Automatically getting project source code
- Setting up workspace with required repositories
- Cloning specific branches for development

## Usage

### Local Development
```json
{
    "features": {
        "./clone-repo": {
            "repoUrl": "https://github.com/user/repo.git",
            "targetDir": "/workspace/my-project",
            "branch": "main"
        }
    }
}
```

### From GitHub Container Registry
```json
{
    "features": {
        "ghcr.io/zeritiq/arch-devcontainer-features/clone-repo:1": {
            "repoUrl": "https://github.com/user/repo.git",
            "targetDir": "/workspace/my-project",
            "branch": "main"
        }
    }
}
```

## Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `repoUrl` | string | `""` | Git repository URL to clone (required) |
| `targetDir` | string | `"/workspace"` | Target directory for cloning |
| `branch` | string | `""` | Specific branch to clone (optional) |

## Example Configurations

### Basic Usage
```json
{
    "features": {
        "ghcr.io/zeritiq/arch-devcontainer-features/clone-repo:1": {
            "repoUrl": "https://github.com/microsoft/vscode.git"
        }
    }
}
```

### Custom Target Directory
```json
{
    "features": {
        "ghcr.io/zeritiq/arch-devcontainer-features/clone-repo:1": {
            "repoUrl": "https://github.com/microsoft/vscode.git",
            "targetDir": "/workspace/vscode-source"
        }
    }
}
```

### Specific Branch
```json
{
    "features": {
        "ghcr.io/zeritiq/arch-devcontainer-features/clone-repo:1": {
            "repoUrl": "https://github.com/microsoft/vscode.git",
            "targetDir": "/workspace/vscode-dev",
            "branch": "development"
        }
    }
}
```

### Multiple Repositories
```json
{
    "features": {
        "ghcr.io/zeritiq/arch-devcontainer-features/clone-repo:1": {
            "repoUrl": "https://github.com/main-project/repo.git",
            "targetDir": "/workspace/main"
        },
        "ghcr.io/zeritiq/arch-devcontainer-features/clone-repo:2": {
            "repoUrl": "https://github.com/dependencies/repo.git",
            "targetDir": "/workspace/deps",
            "branch": "stable"
        }
    }
}
```

## Compatibility

- **Architecture**: linux/amd64, linux/arm64
- **Operating System**: Arch Linux (and other Linux distributions)
- **Requirements**: Git (installed automatically if needed)

## Installation Order

This feature installs after:
- **`ghcr.io/bartventer/arch-devcontainer-features/common-utils`** - Provides base Arch Linux utilities and ensures proper installation order

## Architecture

This feature uses a stable architecture with Git submodules:

- **Arch Linux Utilities**: Used through [bartventer/arch-devcontainer-features](https://github.com/bartventer/arch-devcontainer-features)
- **Stable Version**: Scripts downloaded from submodule commit hash (currently pinned to specific commit)
- **Dynamic URLs**: Install script dynamically determines submodule commit and downloads from correct version
- **Reliability**: Falls back to `main` branch if specific commit is not found

### Script Version Updates

The feature downloads utility scripts based on the current submodule commit hash. Script versions are only updated when:
1. The bartventer-features submodule is updated to a new commit/tag
2. Changes are committed to this repository
3. Features are republished to GHCR

**Note**: Scripts are not automatically updated - they follow the specific commit referenced by the submodule.

## Notes

- If target directory already exists and contains files, a timestamped backup is created
- Feature ensures proper file ownership for cloned files
- Git must be available in the container (usually installed in base image)
- If no repository URL is provided, feature skips cloning without errors
- Correctly handles permissions for both root and non-root users

## Troubleshooting

If you encounter cloning issues:

1. Ensure Git is installed in the container
2. Verify repository URL is correct
3. Check user has write permissions to target directory
4. Verify repository accessibility (private repositories require authentication)
5. Ensure specified branch exists in the repository

## Requirements

- Git must be installed in the container
- Container user must have write permissions to the target directory
- Repository access (private repositories may require SSH key or token setup)
