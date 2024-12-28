#!/bin/bash

# Clear the console
clear

# XreatLabs ASCII Logo function with custom symbols
xreatlabs_logo() {
  clear
  echo "============================="
  echo "  ____  _____ _______ ______"
  echo " |  __ \\|  __ \\__   __/ ____|"
  echo " | |__) | |  | | | | | (___  "
  echo " |  ___/| |  | | | |  \\___ \\ "
  echo " | |    | |__| | | |  ____) |"
  echo " |_|    |_____/  |_| |_____/ "
  echo "   ____  __   __ _____ ____  "
  echo "  / __ \\ \\ \\ / / ____/ __ \\ "
  echo " | |  | | \\ V / (___| |  | |"
  echo " | |  | | | |  \\___ \\ |  | |"
  echo " | |__| | | |  ____) | |__| |"
  echo "  \\____/  |_| |_____/ \\____/ "
  echo "============================="
}

# Call the logo function
xreatlabs_logo

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
    local dependencies=("curl" "wget" "git" "tar" "unzip" "lsb_release")
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

# Function: Confirm user action
confirm_action() {
    read -p "$1 (y/n): " choice
    case "$choice" in
        y|Y ) log "Proceeding...";;
        n|N ) log "Operation canceled by user."; exit 0;;
        * ) error "Invalid input. Exiting."; exit 1;;
    esac
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

# Section 3: Install McsManager
install_mcsmanager() {
    log "Installing McsManager..."
    wget https://github.com/MCSManager/MCSManager/releases/latest/download/mcsmanager_linux_release.tar.gz
    tar -zxf mcsmanager_linux_release.tar.gz
    cd /mcsmanager

    log "Installing dependencies for daemon..."
    cd /mcsmanager/daemon
    npm install

    log "Installing dependencies for web..."
    cd /mcsmanager/web
    npm install

    log "McsManager installation completed. Follow the instructions below:"
    echo -e "\n#######################################"
    echo "# To start McsManager:                #"
    echo "# 1. Open Terminal 1 and run:         #"
    echo "#    cd /mcsmanager                   #"
    echo "#    ./start-daemon.sh                #"
    echo "#                                     #"
    echo "# 2. Open Terminal 2 and run:         #"
    echo "#    cd /mcsmanager                   #"
    echo "#    ./start-web.sh                   #"
    echo "#                                     #"
    echo "# Then access the panel in your browser. It will be on localhost:23333 and the daemon will be localhost:24444"
    echo "#######################################"
}

# Section 5: Install PufferPanel without Docker
install_pufferpanel_no_docker() {
    log "Installing PufferPanel without Docker..."
    bash <(curl -s https://raw.githubusercontent.com/PufferPanel/PufferPanel/main/deploy.sh)
    log "PufferPanel installed successfully without Docker."
}

# Section 6: Install Ctrl Panel
install_ctrl_panel() {
    log "Installing Ctrl Panel..."
    sudo apt update && sudo apt install -y apache2 mysql-server php php-fpm
    git clone https://github.com/your-ctrl-panel-repo.git /opt/ctrlpanel
    cd /opt/ctrlpanel || exit
    ./install.sh
    log "Ctrl Panel installation completed."
}

# Section 7: Install Jexactyl
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

# Section 8: Install Pterodactyl Official Panel
install_pterodactyl_panel_official() {
    log "Installing Pterodactyl Official Panel..."
    bash <(curl -s https://pterodactyl-installer.se)
    log "Pterodactyl Official Panel installed."
}

# Section 9: Install Pterodactyl Official Node
install_pterodactyl_node_official() {
    log "Installing Pterodactyl Official Node..."
    bash <(curl -s https://pterodactyl-installer.se/node.sh)
    log "Pterodactyl Official Node installed."
}

# Menu options
while true; do
    echo -e "\n${YELLOW}Please select an option:${NC}"
    echo "1) Install Node.js"
    echo "2) Install Java (Temurin JDK 21)"
    echo "3) Install McsManager"
    echo "4) Install PufferPanel with Docker"
    echo "5) Install PufferPanel without Docker"
    echo "6) Install Ctrl Panel"
    echo "7) Install Jexactyl"
    echo "8) Install Pterodactyl Official Panel"
    echo "9) Install Pterodactyl Official Node"
    echo "10) Exit"
    read -p "Enter your choice [1-10]: " choice

    case $choice in
    1) install_nodejs ;;
    2) install_java ;;
    3) install_mcsmanager ;;
    4) install_pufferpanel_docker ;;
    5) install_pufferpanel_no_docker ;;
    6) install_ctrl_panel ;;
    7) install_jexactyl ;;
    8) install_pterodactyl_panel_official ;;
    9) install_pterodactyl_node_official ;;
    10) log "Exiting script. Goodbye!"; exit 0 ;;
    *) error "Invalid choice. Please try again." ;;
    esac
done
