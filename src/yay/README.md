# Yay AUR Helper (yay)

Installs yay - a popular AUR (Arch User Repository) helper for Arch Linux.

## Description

Yay is an AUR helper written in Go that allows easy installation of packages from the AUR. This feature automatically:

- Checks compatibility with Arch Linux
- Installs necessary dependencies (base-devel, git)
- Clones and builds yay from AUR
- Optionally installs additional AUR packages

## Usage

### Local Development
```json
{
    "features": {
        "./yay": {}
    }
}
```

### From GitHub Container Registry
```json
{
    "features": {
        "ghcr.io/zeritiq/arch-devcontainer-features/yay:1": {}
    }
}
```

### With Additional AUR Packages
```json
{
    "features": {
        "ghcr.io/zeritiq/arch-devcontainer-features/yay:1": {
            "installPackages": "visual-studio-code-bin,discord,google-chrome"
        }
    }
}
```

## Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `installPackages` | string | `""` | Comma-separated list of AUR packages to install |

## Compatibility

- **Architecture**: linux/amd64, linux/arm64
- **Operating System**: Arch Linux
- **Requirements**: base-devel, git (installed automatically if needed)

## Architecture

This feature uses a stable architecture with Git submodules:

- **Arch Linux Utilities**: Used through [bartventer/arch-devcontainer-features](https://github.com/bartventer/arch-devcontainer-features)
- **Stable Version**: Pinned to v1.24.5 via submodule
- **Reliability**: Local copy ensures operation without external service dependencies

## Notes

- Feature checks for existing yay installation and skips if already installed
- Installation occurs in a temporary directory that is cleaned up after completion
- Additional packages use `--noconfirm` flag for automatic confirmation
- Correctly handles permissions for both root and non-root users

## Troubleshooting

If you encounter installation issues:

1. Ensure the container is based on Arch Linux
2. Check package availability in AUR
3. Verify user has permissions to install packages
4. Check installation logs for specific errors

## Requirements

- Container must be running Arch Linux
- User must have appropriate permissions for package installation
- Internet connection for downloading packages from AUR
