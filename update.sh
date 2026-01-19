#!/bin/bash

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
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
echo -e "${BLUE}║                 Xferant VPN Update Script                   ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}❌ Please run as root: sudo ./update.sh${NC}"
    exit 1
fi

log_info() { echo -e "${GREEN}✅ [INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}⚠️ [WARN]${NC} $1"; }
log_error() { echo -e "${RED}❌ [ERROR]${NC} $1"; }

# Go to project directory
cd /opt/xferant-vpn 2>/dev/null || {
    log_error "Directory /opt/xferant-vpn not found"
    exit 1
}

log_info "Starting Xferant VPN update..."

# Step 1: Backup current configuration
log_info "Creating backup..."
BACKUP_DIR="backups/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"
cp .env "$BACKUP_DIR/" 2>/dev/null || true
cp docker-compose.yml "$BACKUP_DIR/" 2>/dev/null || true
cp config/nginx.conf "$BACKUP_DIR/" 2>/dev/null || true
log_info "Backup created in: $BACKUP_DIR"

# Step 2: Update from GitHub
log_info "Updating from GitHub..."
if git pull origin main; then
    log_info "Repository updated successfully"
    
    # Show recent changes
    echo ""
    echo -e "${YELLOW}📋 Recent changes:${NC}"
    git log --oneline -5
    echo ""
else
    log_warn "Failed to update via git pull, trying alternative..."
    git fetch origin
    git reset --hard origin/main
    log_info "Repository reset to latest version"
fi

# Step 3: Rebuild Docker containers
log_info "Rebuilding Docker containers..."

# Stop containers
log_info "Stopping containers..."
docker compose down 2>/dev/null || docker-compose down 2>/dev/null || {
    log_warn "No containers to stop"
}

# Rebuild
log_info "Building containers..."
if ! docker compose build --no-cache 2>/dev/null; then
    log_warn "Using docker-compose instead of docker compose"
    docker-compose build --no-cache
fi

# Start
log_info "Starting containers..."
if ! docker compose up -d 2>/dev/null; then
    log_warn "Using docker-compose instead of docker compose"
    docker-compose up -d
fi

# Step 4: Wait for startup
log_info "Waiting for services to start (30 seconds)..."
sleep 30

# Step 5: Check status
log_info "Checking services status..."
if docker compose ps 2>/dev/null | grep -q "Up"; then
    log_info "All services are running"
    docker compose ps
else
    log_warn "Some services may need attention"
    docker compose ps 2>/dev/null || true
fi

# Step 6: Health checks
echo ""
echo -e "${YELLOW}🔍 Health checks:${NC}"

# Check backend
if curl -s -f http://localhost:8080/health > /dev/null 2>&1 || \
   curl -s -f http://localhost:8080/api/v1/health > /dev/null 2>&1; then
    echo -e "${GREEN}  ✅ Backend is healthy${NC}"
else
    echo -e "${RED}  ❌ Backend health check failed${NC}"
fi

# Check nginx
if curl -s -k -f https://localhost/health > /dev/null 2>&1; then
    echo -e "${GREEN}  ✅ Nginx is healthy (HTTPS)${NC}"
elif curl -s -f http://localhost/health > /dev/null 2>&1; then
    echo -e "${GREEN}  ✅ Nginx is healthy (HTTP)${NC}"
else
    echo -e "${YELLOW}  ⚠️ Nginx health check failed${NC}"
fi

# Check PostgreSQL
if docker compose exec -T postgres pg_isready -U xferant_user > /dev/null 2>&1; then
    echo -e "${GREEN}  ✅ PostgreSQL is healthy${NC}"
else
    echo -e "${YELLOW}  ⚠️ PostgreSQL health check failed${NC}"
fi

# Check Xray
if docker compose ps 2>/dev/null | grep xray | grep -q "Up"; then
    echo -e "${GREEN}  ✅ Xray is running${NC}"
else
    echo -e "${YELLOW}  ⚠️ Xray is not running${NC}"
fi

# Step 7: Final message
echo ""
echo -e "${GREEN}🎉 Xferant VPN successfully updated!${NC}"
echo ""
echo -e "${BLUE}🔗 Access URLs:${NC}"
echo -e "   Control Panel: https://$(hostname)"
echo -e "   API Server: https://$(hostname)/api"
echo -e "   VPN Server: $(hostname):4443"
echo ""
echo -e "${YELLOW}🔧 Management Commands:${NC}"
echo -e "   Status: docker compose ps"
echo -e "   Logs: docker compose logs -f"
echo -e "   Stop: docker compose stop"
echo -e "   Start: docker compose start"
echo -e "   Restart: docker compose restart"
echo ""
echo -e "${PURPLE}📁 Backup location: $BACKUP_DIR${NC}"
echo ""

exit 0