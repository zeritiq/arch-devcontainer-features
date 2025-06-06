# Clone Repository Feature

This feature automatically clones a Git repository into your devcontainer workspace during container creation.

## Usage

```json
{
    "features": {
        "ghcr.io/zeritiq/devcontainer-features/clone-repo:1": {
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
        "ghcr.io/zeritiq/devcontainer-features/clone-repo:1": {
            "repoUrl": "https://github.com/microsoft/vscode.git"
        }
    }
}
```

### Custom Target Directory
```json
{
    "features": {
        "ghcr.io/zeritiq/devcontainer-features/clone-repo:1": {
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
        "ghcr.io/zeritiq/devcontainer-features/clone-repo:1": {
            "repoUrl": "https://github.com/microsoft/vscode.git",
            "targetDir": "/workspace/vscode-dev",
            "branch": "main"
        }
    }
}
```

## Notes

- If the target directory already exists and contains files, it will be backed up with a timestamp suffix
- The feature ensures proper ownership of cloned files for the container user
- Git must be available in the container (typically installed in the base image)
- If no repository URL is provided, the feature will skip cloning without errors

## Requirements

- Git must be installed in the container
- The container user must have write permissions to the target directory
