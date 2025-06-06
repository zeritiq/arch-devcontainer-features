# Arch Linux DevContainer Features

A collection of DevContainer features for Arch Linux, providing stable and reliable development container experiences.

## 🚀 Available Features

### 📦 [Yay AUR Helper](src/yay/README.md)
Installs yay - a popular AUR helper for easy installation of packages from the Arch User Repository.

```json
{
    "features": {
        "ghcr.io/zeritiq/arch-devcontainer-features/yay:1": {
            "installPackages": "visual-studio-code-bin,discord"
        }
    }
}
```

### 📁 [Clone Repository](src/clone-repo/README.md)
Automatically clones a Git repository into your devcontainer workspace during container creation.

```json
{
    "features": {
        "ghcr.io/zeritiq/arch-devcontainer-features/clone-repo:1": {
            "repoUrl": "https://github.com/user/repo.git",
            "targetDir": "/workspace/project"
        }
    }
}
```

## 🏗️ Architecture

### Stable Dependency on bartventer/arch-devcontainer-features

This project uses a Git submodules architecture for stability:

```
arch-devcontainer-features/
├── src/                     # Our features
│   ├── yay/
│   └── clone-repo/
└── vendor/                  # Dependencies
    └── bartventer-features/ # Git submodule v1.24.5
        └── scripts/
            └── archlinux_util_setup.sh
```

### Architecture Benefits

- ✅ **Stability**: Dependency version pinned to v1.24.5
- ✅ **Reliability**: Works without external service dependencies
- ✅ **Controlled updates**: Updates only after testing
- ✅ **Offline capability**: All necessary scripts available locally

## 🚀 Quick Start

### 1. Creating devcontainer.json

```json
{
    "name": "Arch Linux DevContainer",
    "image": "archlinux:latest",
    "features": {
        "ghcr.io/zeritiq/arch-devcontainer-features/yay:1": {
            "installPackages": "git,vim,curl"
        },
        "ghcr.io/zeritiq/arch-devcontainer-features/clone-repo:1": {
            "repoUrl": "https://github.com/your-org/your-project.git",
            "targetDir": "/workspace"
        }
    },
    "postCreateCommand": "yay -Sy --noconfirm && echo 'DevContainer ready!'"
}
```

### 2. Local Development

For using local features:

```json
{
    "features": {
        "./src/yay": {},
        "./src/clone-repo": {
            "repoUrl": "https://github.com/your-org/project.git"
        }
    }
}
```

## 🔧 Development

### Updating Dependencies

```bash
# Check available versions
cd vendor/bartventer-features
git fetch --tags
git tag --sort=-version:refname | head -10

# Update to new version
git checkout v1.25.0
cd ../..
git add vendor/bartventer-features
git commit -m "Update bartventer-features to v1.25.0"
```

### Testing

1. **Local Testing**:
   ```bash
   # Use local features in devcontainer.json
   ./test/test-features.sh
   ```

2. **GitHub Container Registry Testing**:
   ```bash
   # After publishing to GHCR
   docker run --rm -it ghcr.io/zeritiq/arch-devcontainer-features/yay:latest
   ```

### Project Structure

```
├── .devcontainer/           # DevContainer configuration for development
├── src/                     # DevContainer features
│   ├── yay/                # Yay AUR helper feature
│   │   ├── devcontainer-feature.json
│   │   ├── install.sh
│   │   └── README.md
│   └── clone-repo/         # Clone repository feature
│       ├── devcontainer-feature.json
│       ├── install.sh
│       └── README.md
├── vendor/                 # Git submodule dependencies
│   └── bartventer-features/
├── test/                   # Feature tests
└── README.md              # This file
```

## 📋 Compatibility

### Supported Architectures
- `linux/amd64`
- `linux/arm64`

### Supported Systems
- **Primary**: Arch Linux
- **Secondary**: Other Linux distributions (for clone-repo)

### Requirements
- Docker or Podman
- Visual Studio Code with Dev Containers extension
- Git (for cloning features)

## 🔄 CI/CD

### GitHub Actions

The project includes automated processes:

- **Testing**: Automated tests for all features
- **Publishing**: Publication to GitHub Container Registry
- **Versioning**: Semantic versioning
- **Documentation**: Automatic documentation updates

### Publication

Features are automatically published to:
- `ghcr.io/zeritiq/arch-devcontainer-features/yay`
- `ghcr.io/zeritiq/arch-devcontainer-features/clone-repo`

## 📖 Documentation

- [Yay AUR Helper](src/yay/README.md) - Detailed yay feature documentation
- [Clone Repository](src/clone-repo/README.md) - Clone-repo feature documentation
- [DevContainers Specification](https://containers.dev/implementors/features/) - Official specification

## 🤝 Contributing

1. **Fork** the repository
2. Create a **feature branch**: `git checkout -b feature/amazing-feature`
3. **Commit** your changes: `git commit -m 'Add amazing feature'`
4. **Push** to the branch: `git push origin feature/amazing-feature`
5. Open a **Pull Request**

### Development Guidelines

- All features should work on Arch Linux
- Add tests for new features
- Update documentation
- Follow existing code style
- Use semantic versioning

## 📄 License

This project is licensed under the [MIT License](LICENSE).

## 🙏 Acknowledgments

This project uses code from:

- [bartventer/arch-devcontainer-features](https://github.com/bartventer/arch-devcontainer-features) - Arch Linux utilities
- [devcontainers/features](https://github.com/devcontainers/features) - Templates and examples

Thanks to the authors for their contributions to the DevContainers ecosystem!

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/zeritiq/arch-devcontainer-features/issues)
- **Discussions**: [GitHub Discussions](https://github.com/zeritiq/arch-devcontainer-features/discussions)
- **Documentation**: [DevContainers.dev](https://containers.dev/)

---

⭐ If this project was helpful, please give it a star!
