# XreatLabs Panel Installer

<p align="center">
  <img src="https://raw.githubusercontent.com/Xreatlabs/.github/main/profile/xreatlabs-logo-dark.png" alt="XreatLabs Logo" width="300">
</p>

*A powerful, multi-panel installation script for game server management*

## 📝 Description

The XreatLabs Panel Installer is an advanced bash script that simplifies the installation of various game server control panels and their dependencies. This tool is designed for Linux system administrators and hosting providers who need to quickly deploy management panels for game servers.

## 🌟 Features

- **Multiple Panel Support**: Install various popular game server control panels
- **Dependency Management**: Automatically handles required dependencies
- **Retry Logic**: Automatically retries failed installations
- **Bulk Installation**: Install multiple components in one operation
- **Detailed Logging**: Comprehensive installation logs for troubleshooting
- **User-Friendly Menu**: Interactive console interface
- **Service Integration**: Proper systemd service setup where applicable

## 📋 Supported Panels & Components

1. **Node.js** (with NVM)
2. **Java** (Temurin JDK)
3. **MCSManager** (Minecraft Server Manager)
4. **PufferPanel** (without Docker)
5. **Pterodactyl Panel** (Official)
6. **Pterodactyl Node** (Official)
7. **Jexactyl** (Pterodactyl fork)

## 🚀 Installation

### Prerequisites
- Ubuntu/Debian based Linux system (recommended)
- sudo privileges
- Internet connection

### Quick Start
```bash
git clone https://github.com/Xreatlabs/Panel-installer.git
cd Panel-installer
chmod +x installer.sh
sudo ./installer.sh
