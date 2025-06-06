
# Clone Repository (clone-repo)

Clones a Git repository into the container workspace

## Example Usage

```json
"features": {
    "ghcr.io/zeritiq/arch-devcontainer-features/clone-repo:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| repoUrl | Git repository URL to clone (required) | string | - |
| targetDir | Target directory for cloning (default: /workspace) | string | /workspace |
| branch | Specific branch to clone (optional) | string | - |



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/zeritiq/arch-devcontainer-features/blob/main/src/clone-repo/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
