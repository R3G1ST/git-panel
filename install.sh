#!/bin/bash

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Xferant VPN ASCII Art
echo -e "${PURPLE}"
cat << "EOF"
__  __ ______ _______ _____   _   _ _______ 
\ \/ /|  ____|__   __|  __ \ | \ | |__   __|
 \  / | |__     | |  | |__) ||  \| |  | |   
 /  \ |  __|    | |  |  _  / | . ` |  | |   
/ /\ \| |____   | |  | | \ \ | |\  |  | |   
/_/  \_\______|  |_|  |_|  \_\|_| \_|  |_|   
EOF
echo -e "${NC}"

echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                 Xferant VPN Installer                       ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if running in non-interactive mode (pipe)
if [ ! -t 0 ]; then
    echo -e "${RED}❌ NON-INTERACTIVE MODE DETECTED${NC}"
    echo ""
    echo -e "${YELLOW}⚠️  Please download and run the script locally:${NC}"
    echo ""
    echo -e "${CYAN}curl -fsSL https://raw.githubusercontent.com/R3G1ST/vpn-system/main/install.sh -o install.sh${NC}"
    echo -e "${CYAN}chmod +x install.sh${NC}"
    echo -e "${CYAN}sudo ./install.sh${NC}"
    echo ""
    echo -e "${GREEN}Or use parameters:${NC}"
    echo -e "${CYAN}curl -fsSL https://raw.githubusercontent.com/R3G1ST/vpn-system/main/install.sh | sudo bash -s -- yourdomain.com your@email.com${NC}"
    exit 1
fi

# Check root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}❌ Please run as root: sudo ./install.sh${NC}"
    exit 1
fi

# Variables
INSTALL_DIR="/opt/xferant-vpn"
REPO_URL="https://github.com/R3G1ST/vpn-system.git"

log_info() { echo -e "${GREEN}✅ [INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}⚠️ [WARN]${NC} $1"; }
log_error() { echo -e "${RED}❌ [ERROR]${NC} $1"; }

# Check if parameters provided
if [ $# -eq 2 ]; then
    DOMAIN="$1"
    EMAIL="$2"
    AUTO_MODE=true
else
    AUTO_MODE=false
fi

main() {
    log_info "Starting Xferant VPN automated installation..."
    
    if [ "$AUTO_MODE" = false ]; then
        get_user_input
    else
        log_info "Auto mode: Domain=$DOMAIN, Email=$EMAIL"
    fi
    
    # Installation steps
    check_system
    install_dependencies
    clone_repository
    setup_environment
    setup_ssl
    start_services
    finalize_installation
    
    log_info "🎉 Xferant VPN installed successfully!"
    show_success_message
}

get_user_input() {
    echo -e "${CYAN}📝 Configuration Setup${NC}"
    echo ""
    
    # Domain input
    while [ -z "$DOMAIN" ]; do
        echo -n "🌐 Enter your domain (e.g., vpn.yourdomain.com): "
        read DOMAIN
        if [ -z "$DOMAIN" ]; then
            log_error "Domain name cannot be empty"
        fi
    done
    
    # Email input
    while [ -z "$EMAIL" ]; do
        echo -n "📧 Enter your email (for SSL certificates): "
        read EMAIL
        if [ -z "$EMAIL" ]; then
            log_error "Email cannot be empty"
        elif [[ ! "$EMAIL" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
            log_error "Please enter a valid email address"
            EMAIL=""
        fi
    done
    
    # Confirmation
    echo ""
    echo -e "${YELLOW}📋 Installation Summary${NC}"
    echo "   Domain: https://$DOMAIN"
    echo "   Email: $EMAIL"
    echo "   Directory: $INSTALL_DIR"
    echo ""
    echo -n "Proceed with installation? (y/N): "
    read confirmation
    if [ "$confirmation" != "y" ] && [ "$confirmation" != "Y" ]; then
        log_info "Installation cancelled by user"
        exit 0
    fi
}

check_system() {
    log_info "Checking system compatibility..."
    
    # Check OS
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS_NAME=$NAME
        OS_VERSION=$VERSION_ID
    else
        log_error "Cannot determine operating system"
        exit 1
    fi
    
    # Supported OS check
    case $ID in
        ubuntu|debian|centos|rocky|almalinux)
            log_info "Supported OS detected: $OS_NAME $OS_VERSION"
            ;;
        *)
            log_error "Unsupported OS: $OS_NAME"
            exit 1
            ;;
    esac
    
    # Check architecture
    ARCH=$(uname -m)
    if [ "$ARCH" != "x86_64" ]; then
        log_error "Unsupported architecture: $ARCH"
        exit 1
    fi
    
    # Check memory
    MEM_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    MEM_GB=$((MEM_KB / 1024 / 1024))
    if [ $MEM_GB -lt 2 ]; then
        log_warn "Low memory detected: ${MEM_GB}GB (recommended: 2GB+)"
    fi
}

install_dependencies() {
    log_info "Installing system dependencies..."
    
    # Update package manager
    case $ID in
        ubuntu|debian)
            apt-get update
            apt-get install -y curl wget git openssl
            ;;
        centos|rocky|almalinux)
            dnf update -y
            dnf install -y curl wget git openssl
            ;;
    esac
    
    # Install Docker
    if ! command -v docker &> /dev/null; then
        log_info "Installing Docker..."
        curl -fsSL https://get.docker.com -o get-docker.sh
        sh get-docker.sh
        rm get-docker.sh
        
        systemctl enable docker
        systemctl start docker
        usermod -aG docker $SUDO_USER
    else
        log_info "Docker is already installed"
    fi
    
    # Install Docker Compose
    if ! command -v docker-compose &> /dev/null; then
        log_info "Installing Docker Compose..."
        DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep tag_name | cut -d'"' -f4)
        curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        chmod +x /usr/local/bin/docker-compose
    else
        log_info "Docker Compose is already installed"
    fi
}

clone_repository() {
    log_info "Cloning Xferant VPN repository..."
    
    # Clean up previous installation
    rm -rf $INSTALL_DIR
    
    # Clone repository
    git clone $REPO_URL $INSTALL_DIR
    cd $INSTALL_DIR
}

setup_environment() {
    log_info "Setting up environment..."
    
    # Create .env file
    cat > .env << EOF
# Xferant VPN Configuration
DOMAIN=$DOMAIN
EMAIL=$EMAIL

# Database
POSTGRES_DB=xferant_vpn
POSTGRES_USER=xferant_user
POSTGRES_PASSWORD=$(openssl rand -base64 32)

# Security
JWT_SECRET=$(openssl rand -base64 64)
API_SECRET_KEY=$(openssl rand -base64 48)

# Xray-core
XRAY_CONFIG_DIR=/etc/xray

# SSL
SSL_EMAIL=$EMAIL
SSL_DOMAIN=$DOMAIN
EOF

    log_info "Environment configuration created"
}

setup_ssl() {
    log_info "Setting up SSL certificates..."
    
    # Create SSL directories
    mkdir -p $INSTALL_DIR/data/ssl/{certs,private}
    
    # Generate self-signed certificate for initial setup
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout $INSTALL_DIR/data/ssl/private/key.pem \
        -out $INSTALL_DIR/data/ssl/certs/cert.pem \
        -subj "/C=US/ST=State/L=City/O=Xferant/CN=$DOMAIN"
    
    log_info "SSL certificates generated"
}

start_services() {
    log_info "Starting Xferant VPN services..."
    
    cd $INSTALL_DIR
    
    # Update nginx config with domain
    if [ -f config/nginx.conf ]; then
        sed -i "s/server_name _;/server_name $DOMAIN;/g" config/nginx.conf
    fi
    
    # Start services
    docker-compose up -d
    
    # Wait for services to start
    sleep 30
    
    # Check if services are running
    if docker-compose ps | grep -q "Up"; then
        log_info "All services are running"
    else
        log_warn "Some services may need attention - check logs with: docker-compose logs"
    fi
}

finalize_installation() {
    log_info "Finalizing installation..."
    
    # Create startup script
    cat > /usr/local/bin/xferant-vpn << EOF
#!/bin/bash
cd $INSTALL_DIR
docker-compose "\$@"
EOF
    chmod +x /usr/local/bin/xferant-vpn
    
    # Create systemd service
    cat > /etc/systemd/system/xferant-vpn.service << EOF
[Unit]
Description=Xferant VPN Service
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=$INSTALL_DIR
ExecStart=/usr/local/bin/docker-compose up -d
ExecStop=/usr/local/bin/docker-compose down
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
EOF
    
    systemctl daemon-reload
    systemctl enable xferant-vpn.service
    
    # Setup firewall
    case $ID in
        ubuntu|debian)
            ufw allow 80/tcp
            ufw allow 443/tcp
            ;;
        centos|rocky|almalinux)
            firewall-cmd --permanent --add-port=80/tcp
            firewall-cmd --permanent --add-port=443/tcp
            firewall-cmd --reload
            ;;
    esac
    
    log_info "Installation finalized"
}

show_success_message() {
    echo ""
    echo -e "${GREEN}🎉 Xferant VPN successfully installed!${NC}"
    echo ""
    echo -e "${CYAN}🔗 Access URLs:${NC}"
    echo -e "   Control Panel: https://$DOMAIN"
    echo -e "   API Server: https://$DOMAIN/api"
    echo -e "   Service Status: docker-compose ps"
    echo ""
    echo -e "${YELLOW}🔧 Management Commands:${NC}"
    echo -e "   Start: systemctl start xferant-vpn"
    echo -e "   Stop: systemctl stop xferant-vpn"
    echo -e "   Logs: docker-compose logs -f"
    echo -e "   Backup: $INSTALL_DIR/scripts/backup.sh"
    echo ""
    echo -e "${BLUE}📚 Documentation:${NC}"
    echo -e "   GitHub: https://github.com/R3G1ST/vpn-system"
    echo -e "   Docs: $INSTALL_DIR/docs/"
    echo ""
    echo -e "${PURPLE}⚠️ Important next steps:${NC}"
    echo -e "   1. Configure DNS for domain $DOMAIN"
    echo -e "   2. Access panel and create first user"
    echo -e "   3. Configure payment systems in admin panel"
    echo -e "   4. Integrate Telegram bot"
    echo ""
}

# Error handling
trap 'log_error "Installation failed at line $LINENO"; exit 1' ERR

# Run main function
main "$@"
