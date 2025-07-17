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
🖥️ Usage
After launching the script, you'll see an interactive menu:
==== XreatLabs Installation Menu ====
1) Install Node.js
2) Install Java (Temurin JDK)
3) Install McsManager
4) Install PufferPanel (no Docker)
5) Install Pterodactyl Panel (Official)
6) Install Pterodactyl Node (Official)
7) Install Jexactyl
8) Install Multiple Components
9) Exit
Select an option to begin installation. For multiple components, choose option 8 and select numbers separated by spaces (e.g., "1 3 5").```

⚙️ Configuration
Most panels will prompt for required configuration during installation. The script handles:

Dependency installation

Service configuration

Basic firewall rules (where needed)

Database setup (for some panels)

📊 Logging
All installation output is logged to:
/tmp/xreatlabs_install/installation.log
🛠️ Troubleshooting
Common issues and solutions:

Permission Denied Errors:

Run the script with sudo

Ensure your user has proper sudo privileges

Installation Failures:

Check the installation log

Verify internet connectivity

Retry the installation (the script supports automatic retries)

Missing Dependencies:

Run sudo apt update before using the installer

Ensure your system meets the minimum requirements
📜 License
This project is licensed under the MIT License - see the LICENSE file for details.

📧 Contact
For support or questions:

Email: support@xreatlabs.com

Discord: Join our server

Website: https://xreatlabs.com
Note: This installer is designed for fresh installations. Use on production systems with caution and always back up your data first.
