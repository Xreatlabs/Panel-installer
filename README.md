# XreatLabs Installer Script

This script is designed to simplify the installation process for several server management panels, including **McsManager**, **PufferPanel**, **Ctrl Panel**, **Jexactyl**, and **Pterodactyl**. It also includes essential tools like **Node.js** and **Java (Temurin JDK 21)**.

## Features

- Easy installation of the following panels:
  - McsManager
  - PufferPanel (with and without Docker)
  - Ctrl Panel
  - Jexactyl
  - Pterodactyl Official Panel and Node
- Installs required dependencies like **curl**, **wget**, **git**, **Node.js**, and **Java (Temurin JDK 21)**.
- Clean and organized logging for easier debugging and monitoring.
- ASCII logo display for XreatLabs branding.

## Prerequisites

Before running the script, make sure you have a **Linux-based** server (preferably Ubuntu) with `sudo` access.

The following tools must be installed:
- **curl**
- **wget**
- **git**
- **tar**
- **unzip**
- **lsb_release**

These tools are required for downloading, extracting, and installing the necessary components. The script will attempt to install missing dependencies automatically.

## Usage

### 1. Clone the repository or download the script
```bash
git clone https://github.com/Xreatlabs/Panel-installer
cd xreatlabs-installer

2. Make the script executable

chmod +x install.sh

3. Run the script

./install.sh

You will be presented with a menu of options. Choose the desired installation option by entering the corresponding number:

1) Install Node.js
2) Install Java (Temurin JDK 21)
3) Install McsManager
4) Install PufferPanel with Docker
5) Install PufferPanel without Docker
6) Install Ctrl Panel
7) Install Jexactyl
8) Install Pterodactyl Official Panel
9) Install Pterodactyl Official Node
10) Exit

4. Follow on-screen instructions

Each installation option will provide additional instructions after it completes. For example, for McsManager, you will be told to start the daemon and web servers in separate terminals.

Troubleshooting

Missing dependencies: If the script encounters missing dependencies during installation, it will attempt to install them automatically. If this fails, you may need to manually install missing packages.

Permissions issues: Make sure you have sudo privileges to install the necessary software. If you're running the script as a non-root user, you may need to prefix commands with sudo.


License

This script is open-source and available under the MIT License.

Support

For issues, suggestions, or questions, feel free to open an issue in the GitHub repository or contact us at support@xreatlabs.com.
