#!/bin/bash

# Clear the console
clear

echo "============================="
echo "XreatLabs Panel Installation"
echo "============================="

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

log() {
    echo -e "${GREEN}[INFO] $(date +'%Y-%m-%d %H:%M:%S') - $1${NC}"
}

warn() {
    echo -e "${YELLOW}[WARN] $(date +'%Y-%m-%d %H:%M:%S') - $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $(date +'%Y-%m-%d %H:%M:%S') - $1${NC}"
}

success() {
    echo -e "${BLUE}[SUCCESS] $(date +'%Y-%m-%d %H:%M:%S') - $1${NC}"
}

debug() {
    echo -e "${MAGENTA}[DEBUG] $(date +'%Y-%m-%d %H:%M:%S') - $1${NC}"
}

INSTALLATION_TEMP_DIR="/tmp/xreatlabs_install"
MAX_RETRIES=3
CURRENT_RETRY=0
INSTALLATION_LOG="$INSTALLATION_TEMP_DIR/installation.log"

mkdir -p "$INSTALLATION_TEMP_DIR"
touch "$INSTALLATION_LOG"

trap 'handle_error $LINENO' ERR

handle_error() {
    local line=$1
    error "An error occurred on line $line. Installation failed."
    error "Check the installation log at $INSTALLATION_LOG for details."
    
    read -p "Do you want to (R)etry, (S)kip, or (Q)uit? [r/s/q]: " choice
    case "$choice" in
        r|R)
            if [ $CURRENT_RETRY -lt $MAX_RETRIES ]; then
                ((CURRENT_RETRY++))
                warn "Retrying installation (Attempt $CURRENT_RETRY/$MAX_RETRIES)..."
                return 1
            else
                error "Max retries reached. Exiting."
                exit 1
            fi
            ;;
        s|S)
            warn "Skipping this installation step."
            CURRENT_RETRY=0
            return 0
            ;;
        q|Q|*)
            error "Exiting installation."
            exit 1
            ;;
    esac
}

check_dependencies() {
    log "Checking essential dependencies..."
    local dependencies=("curl" "wget" "git" "tar" "unzip" "lsb_release" "php" "composer" "screen" "htop")
    local missing=()
    
    for dep in "${dependencies[@]}"; do
        if ! command -v "$dep" &>/dev/null; then
            warn "$dep is not installed."
            missing+=("$dep")
        else
            log "$dep is already installed."
        fi
    done
    
    if [ ${#missing[@]} -gt 0 ]; then
        warn "Missing dependencies detected. Installing now..."
        sudo apt-get update || return 1
        sudo apt-get install -y "${missing[@]}" || return 1
        success "All dependencies installed successfully."
    else
        success "All essential dependencies are already installed."
    fi
}

install_nodejs() {
    local version=${1:-22}
    CURRENT_RETRY=0
    
    while [ $CURRENT_RETRY -lt $MAX_RETRIES ]; do
        log "Installing Node.js v$version (Attempt $((CURRENT_RETRY+1))/$MAX_RETRIES..."
        
        if ! command -v nvm &>/dev/null; then
            log "Installing NVM..."
            curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash || return 1
            export NVM_DIR="$HOME/.nvm"
            [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        fi
        
        nvm install "$version" || return 1
        nvm use "$version" || return 1
        
        if node -v &>/dev/null && npm -v &>/dev/null; then
            success "Node.js v$version installed successfully."
            return 0
        fi
        
        ((CURRENT_RETRY++))
        warn "Node.js installation attempt $CURRENT_RETRY failed."
    done
    
    error "Failed to install Node.js after $MAX_RETRIES attempts."
    return 1
}

install_java() {
    local version=${1:-21}
    CURRENT_RETRY=0
    
    while [ $CURRENT_RETRY -lt $MAX_RETRIES ]; do
        log "Installing Java Temurin JDK $version (Attempt $((CURRENT_RETRY+1))/$MAX_RETRIES..."
        
        sudo apt install -y wget apt-transport-https gpg || return 1
        wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/adoptium.gpg > /dev/null || return 1
        echo "deb https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | sudo tee /etc/apt/sources.list.d/adoptium.list || return 1
        sudo apt update || return 1
        sudo apt install "temurin-${version}-jdk" -y || return 1
        
        if java -version 2>&1 | grep -q "temurin-$version"; then
            success "Java Temurin JDK $version installed successfully."
            return 0
        fi
        
        ((CURRENT_RETRY++))
        warn "Java installation attempt $CURRENT_RETRY failed."
    done
    
    error "Failed to install Java after $MAX_RETRIES attempts."
    return 1
}

install_mcsmanager() {
    CURRENT_RETRY=0
    local install_dir="/opt/mcsmanager"
    
    while [ $CURRENT_RETRY -lt $MAX_RETRIES ]; do
        log "Installing McsManager (Attempt $((CURRENT_RETRY+1))/$MAX_RETRIES..."
        
        sudo mkdir -p "$install_dir" || return 1
        sudo chown -R $USER:$USER "$install_dir" || return 1
        cd "$install_dir" || return 1
        
        wget -q https://github.com/MCSManager/MCSManager/releases/latest/download/mcsmanager_linux_release.tar.gz || return 1
        tar -zxf mcsmanager_linux_release.tar.gz || return 1
        
        cd mcsmanager || return 1
        
        log "Installing dependencies for daemon..."
        cd daemon && npm install --production || return 1
        cd ../web && npm install --production || return 1
        
        # Create systemd service
        log "Creating systemd service..."
        sudo tee /etc/systemd/system/mcsmanager-daemon.service > /dev/null <<EOL
[Unit]
Description=MCSManager Daemon
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$install_dir/mcsmanager/daemon
ExecStart=$(which node) app.js
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOL

        sudo tee /etc/systemd/system/mcsmanager-web.service > /dev/null <<EOL
[Unit]
Description=MCSManager Web
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$install_dir/mcsmanager/web
ExecStart=$(which node) app.js
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOL

        sudo systemctl daemon-reload || return 1
        sudo systemctl enable mcsmanager-daemon mcsmanager-web || return 1
        sudo systemctl start mcsmanager-daemon mcsmanager-web || return 1
        
        success "McsManager installed successfully. Services started and enabled."
        log "Web Interface: http://your-ip:23333"
        log "Daemon running on port 24444"
        return 0
    done
    
    error "Failed to install McsManager after $MAX_RETRIES attempts."
    return 1
}

install_pufferpanel_no_docker() {
    CURRENT_RETRY=0
    
    while [ $CURRENT_RETRY -lt $MAX_RETRIES ]; do
        log "Installing PufferPanel without Docker (Attempt $((CURRENT_RETRY+1))/$MAX_RETRIES..."
        
        curl -s https://raw.githubusercontent.com/PufferPanel/PufferPanel/main/deploy.sh | bash -s -- --no-docker || return 1
        
        if systemctl is-active --quiet pufferpanel; then
            success "PufferPanel installed successfully."
            log "Web Interface: http://your-ip:8080"
            return 0
        fi
        
        ((CURRENT_RETRY++))
        warn "PufferPanel installation attempt $CURRENT_RETRY failed."
    done
    
    error "Failed to install PufferPanel after $MAX_RETRIES attempts."
    return 1
}

install_pterodactyl_panel_official() {
    CURRENT_RETRY=0
    
    while [ $CURRENT_RETRY -lt $MAX_RETRIES ]; do
        log "Installing Pterodactyl Panel (Attempt $((CURRENT_RETRY+1))/$MAX_RETRIES..."
        
        # Check if MySQL is installed
        if ! command -v mysql &>/dev/null; then
            warn "MySQL is not installed. Installing now..."
            sudo apt install -y mariadb-server || return 1
        fi
        
        # Check if Redis is installed
        if ! command -v redis-server &>/dev/null; then
            warn "Redis is not installed. Installing now..."
            sudo apt install -y redis-server || return 1
        fi
        
        # Download and run installer
        curl -sSL https://get.pterodactyl.sh | sudo bash -s -- || return 1
        
        success "Pterodactyl Panel installed successfully."
        log "Web Interface: http://your-ip"
        log "Run 'cd /var/www/pterodactyl && php artisan p:user:make' to create admin user"
        return 0
    done
    
    error "Failed to install Pterodactyl Panel after $MAX_RETRIES attempts."
    return 1
}

install_pterodactyl_node_official() {
    CURRENT_RETRY=0
    
    while [ $CURRENT_RETRY -lt $MAX_RETRIES ]; do
        log "Installing Pterodactyl Node (Attempt $((CURRENT_RETRY+1))/$MAX_RETRIES..."
        
        # Check if Docker is installed
        if ! command -v docker &>/dev/null; then
            warn "Docker is not installed. Installing now..."
            curl -sSL https://get.docker.com | sh || return 1
            sudo usermod -aG docker $USER || return 1
        fi
        
        # Download and run installer
        curl -sSL https://get.pterodactyl.sh | sudo bash -s -- node || return 1
        
        success "Pterodactyl Node installed successfully."
        log "Run 'systemctl enable --now wings' to start the node"
        return 0
    done
    
    error "Failed to install Pterodactyl Node after $MAX_RETRIES attempts."
    return 1
}

install_jexactyl() {
    CURRENT_RETRY=0
    local install_dir="/var/www/jexactyl"
    
    while [ $CURRENT_RETRY -lt $MAX_RETRIES ]; do
        log "Installing Jexactyl (Attempt $((CURRENT_RETRY+1))/$MAX_RETRIES..."
        
        sudo mkdir -p "$install_dir" || return 1
        sudo chown -R $USER:$USER "$install_dir" || return 1
        cd "$install_dir" || return 1
        
        curl -Lo panel.tar.gz https://github.com/jexactyl/jexactyl/releases/latest/download/panel.tar.gz || return 1
        tar -xzvf panel.tar.gz || return 1
        chmod -R 755 storage/* bootstrap/cache/ || return 1
        
        composer install --no-dev --optimize-autoloader || return 1
        cp .env.example .env || return 1
        php artisan key:generate --force || return 1
        
        # Database setup
        log "Please create a MySQL database for Jexactyl and enter the details when prompted."
        php artisan p:environment:setup || return 1
        php artisan p:environment:database || return 1
        php artisan migrate --seed --force || return 1
        
        # Create admin user
        php artisan p:user:make || return 1
        
        # Set up cron job
        (crontab -l 2>/dev/null; echo "* * * * * php $install_dir/artisan schedule:run >> /dev/null 2>&1") | crontab - || return 1
        
        success "Jexactyl installed successfully."
        log "Web Interface: http://your-ip"
        return 0
    done
    
    error "Failed to install Jexactyl after $MAX_RETRIES attempts."
    return 1
}

# Function to install multiple components at once
install_multiple() {
    local choices=("$@")
    
    log "Starting installation of ${#choices[@]} components..."
    
    for choice in "${choices[@]}"; do
        case $choice in
            1) install_nodejs ;;
            2) install_java ;;
            3) install_mcsmanager ;;
            4) install_pufferpanel_no_docker ;;
            5) install_pterodactyl_panel_official ;;
            6) install_pterodactyl_node_official ;;
            7) install_jexactyl ;;
            *) warn "Invalid choice $choice skipped" ;;
        esac
        
        # Reset retry counter for next installation
        CURRENT_RETRY=0
    done
    
    success "Bulk installation completed."
}

# Main menu
show_menu() {
    while true; do
        echo -e "\n${YELLOW}==== XreatLabs Installation Menu ====${NC}"
        echo -e "${GREEN}1) Install Node.js"
        echo "2) Install Java (Temurin JDK)"
        echo "3) Install McsManager"
        echo "4) Install PufferPanel (no Docker)"
        echo "5) Install Pterodactyl Panel (Official)"
        echo "6) Install Pterodactyl Node (Official)"
        echo "7) Install Jexactyl"
        echo "8) Install Multiple Components"
        echo -e "9) Exit${NC}"
        
        read -p "Enter your choice [1-9]: " choice
        
        case $choice in
            1) install_nodejs ;;
            2) 
                read -p "Enter Java version to install (default: 21): " java_version
                install_java "${java_version:-21}"
                ;;
            3) install_mcsmanager ;;
            4) install_pufferpanel_no_docker ;;
            5) install_pterodactyl_panel_official ;;
            6) install_pterodactyl_node_official ;;
            7) install_jexactyl ;;
            8)
                echo -e "\n${YELLOW}Select multiple components to install (space-separated):${NC}"
                echo "1) Node.js"
                echo "2) Java"
                echo "3) McsManager"
                echo "4) PufferPanel"
                echo "5) Pterodactyl Panel"
                echo "6) Pterodactyl Node"
                echo "7) Jexactyl"
                read -p "Your choices (e.g., '1 3 5'): " -a multi_choices
                install_multiple "${multi_choices[@]}"
                ;;
            9) 
                log "Exiting script. Goodbye!"
                exit 0
                ;;
            *) 
                error "Invalid choice. Please try again."
                ;;
        esac
        
        # Reset retry counter after each menu selection
        CURRENT_RETRY=0
        
        read -p "Press Enter to continue..."
        clear
    done
}

# Initial checks
check_dependencies || {
    error "Failed to install required dependencies."
    exit 1
}

# Start the menu
show_menu
