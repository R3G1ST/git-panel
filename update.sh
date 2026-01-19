#!/bin/bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔄 Xferant VPN Update Script${NC}"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}❌ Please run as root: sudo ./update.sh${NC}"
    exit 1
fi

cd /opt/xferant-vpn

echo -e "${YELLOW}📥 Updating from GitHub...${NC}"

# Pull latest changes
if git pull origin main; then
    echo -e "${GREEN}✅ Repository updated successfully${NC}"
else
    echo -e "${RED}❌ Failed to update repository${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}🐳 Rebuilding Docker containers...${NC}"

# Stop and rebuild
docker compose down
docker compose build --no-cache
docker compose up -d

echo ""
echo -e "${GREEN}✅ Update completed!${NC}"
echo ""
echo -e "${BLUE}📊 Checking services status...${NC}"
sleep 10

docker compose ps

echo ""
echo -e "${GREEN}🎉 Xferant VPN successfully updated!${NC}"