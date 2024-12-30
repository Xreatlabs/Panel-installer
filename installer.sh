#!/bin/bash

# Clear the console
clear

# Simple logo or header
echo "============================="
echo "XreatLabs Panel Installation"
echo "============================="

# Color codes for better visuals
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Log functions
log() {
    echo -e "${GREEN}[INFO] $(date +'%Y-%m-%d %H:%M:%S') - $1${NC}"
}

warn() {
    echo -e "${YELLOW}[WARN] $(date +'%Y-%m-%d %H:%M:%S') - $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $(date +'%Y-%m-%d %H:%M:%S') - $1${NC}"
}

# Exit script on error
trap 'error "An unexpected error occurred. Exiting."; exit 1' ERR

# Function: Check and install essential tools
check_dependencies() {
    log "Checking essential dependencies..."
    local dependencies=("curl" "wget" "git" "tar" "unzip" "lsb_release" "php" "composer")
    for dep in "${dependencies[@]}"; do
        if ! command -v $dep &>/dev/null; then
            warn "$dep is not installed. Installing now..."
            sudo apt-get install -y $dep
        else
            log "$dep is already installed."
        fi
    done
    log "All essential dependencies are installed."
}

# Function: Install Node.js
install_nodejs() {
    log "Installing Node.js with nvm..."
    if ! command -v nvm &>/dev/null; then
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    fi
    nvm install 22
    node -v && npm -v && log "Node.js installed successfully."
}

# Function: Install Java (Temurin JDK 21)
install_java() {
    log "Installing Java (Temurin JDK 21)..."
    sudo apt install -y wget apt-transport-https gpg
    wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/adoptium.gpg > /dev/null
    echo "deb https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | sudo tee /etc/apt/sources.list.d/adoptium.list
    sudo apt update
    sudo apt install temurin-21-jdk -y
    log "Java (Temurin JDK 21) installation completed successfully."
}

# Function: Install McsManager
install_mcsmanager() {
    log "Installing McsManager..."
    wget https://github.com/MCSManager/MCSManager/releases/latest/download/mcsmanager_linux_release.tar.gz
    tar -zxf mcsmanager_linux_release.tar.gz
    cd mcsmanager
    log "Installing dependencies for daemon..."
    cd daemon && npm install
    cd ../web && npm install
    log "McsManager installation completed. Start it by running start-daemon.sh and start-web.sh."
}

# Function: Install PufferPanel without Docker
install_pufferpanel_no_docker() {
    log "Installing PufferPanel without Docker..."
    bash <(curl -s https://raw.githubusercontent.com/PufferPanel/PufferPanel/main/deploy.sh)
    log "PufferPanel installed successfully without Docker."
}

# Function: Install Ctrl Panel
install_ctrl_panel() {
    log "Installing Ctrl Panel..."
    sudo apt update && sudo apt install -y apache2 mysql-server php php-fpm
    git clone https://github.com/your-ctrl-panel-repo.git /opt/ctrlpanel
    cd /opt/ctrlpanel || exit
    ./install.sh
    log "Ctrl Panel installation completed."
}

# Function: Install Jexactyl
install_jexactyl() {
    log "Installing Jexactyl..."
    mkdir -p /var/www/jexactyl
    cd /var/www/jexactyl || exit
    curl -Lo panel.tar.gz https://github.com/jexactyl/jexactyl/releases/latest/download/panel.tar.gz
    tar -xzvf panel.tar.gz
    chmod -R 755 storage/* bootstrap/cache/
    composer install --no-dev --optimize-autoloader
    cp .env.example .env
    php artisan key:generate
    log "Jexactyl installation completed."
}

# Function: Install Pterodactyl Official Panel
install_pterodactyl_panel_official() {
    log "Installing Pterodactyl Official Panel..."
    bash <(curl -s https://pterodactyl-installer.se)
    log "Pterodactyl Official Panel installed."
}

# Function: Install Pterodactyl Official Node
install_pterodactyl_node_official() {
    log "Installing Pterodactyl Official Node..."
    bash <(curl -s https://pterodactyl-installer.se/node.sh)
    log "Pterodactyl Official Node installed."
}

# Function: Install Skyport Panel
install_skyport_panel() {
    log "Installing Skyport Panel..."
    git clone https://github.com/achul123/panel5.git /opt/skyport-panel
    cd /opt/skyport-panel || exit
    ./install.sh
    log "Skyport Panel installation completed."
}

# Function: Install Skyport Daemon
install_skyport_daemon() {
    log "Installing Skyport Daemon..."
    git clone https://github.com/achul123/skyportd.git /opt/skyport-daemon
    cd /opt/skyport-daemon || exit
    ./install.sh
    log "Skyport Daemon installation completed."
}

# Function: Install Airlink Panel
install_airlink_panel() {
    log "Installing Airlink Panel..."
    git clone https://github.com/airlinklabs/panel.git /opt/airlink-panel
    cd /opt/airlink-panel || exit
    ./install.sh
    log "Airlink Panel installation completed."
}

# Function: Install Airlink Daemon
install_airlink_daemon() {
    log "Installing Airlink Daemon..."
    git clone https://github.com/airlinklabs/daemon.git /opt/airlink-daemon
    cd /opt/airlink-daemon || exit
    ./install.sh
    log "Airlink Daemon installation completed."
}

# Menu options
while true; do
    echo -e "\n${YELLOW}Please select an option:${NC}"
    echo "1) Install Node.js"
    echo "2) Install Java (Temurin JDK 21)"
    echo "3) Install McsManager"
    echo "4) Install PufferPanel without Docker"
    echo "5) Install Ctrl Panel"
    echo "6) Install Jexactyl"
    echo "7) Install Pterodactyl Official Panel"
    echo "8) Install Pterodactyl Official Node"
    echo "9) Install Skyport Panel"
    echo "10) Install Skyport Daemon"
    echo "11) Install Airlink Panel"
    echo "12) Install Airlink Daemon"
    echo "13) Exit"
    read -p "Enter your choice [1-13]: " choice

    case $choice in
    1) install_nodejs ;;
    2) install_java ;;
    3) install_mcsmanager ;;
    4) install_pufferpanel_no_docker ;;
    5) install_ctrl_panel ;;
    6) install_jexactyl ;;
    7) install_pterodactyl_panel_official ;;
    8) install_pterodactyl_node_official ;;
    9) install_skyport_panel ;;
    10) install_skyport_daemon ;;
    11) install_airlink_panel ;;
    12) install_airlink_daemon ;;
    13) log "Exiting script. Goodbye!"; exit 0 ;;
    *) error "Invalid choice. Please try again." ;;
    esac
done
