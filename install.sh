#!/bin/bash

set -e

echo "=========================================="
echo "     Xferant VPN Installer"
echo "=========================================="

# Проверка root
if [ "$EUID" -ne 0 ]; then
    echo "❌ Run as root: sudo ./install.sh"
    exit 1
fi

# Переходим в корень чтобы избежать проблем с директорией
cd /

# Удаляем старую установку если есть
rm -rf /opt/xferant-vpn

# Создаем директорию
mkdir -p /opt/xferant-vpn
cd /opt

# Клонируем репозиторий
echo "📥 Cloning repository..."
git clone https://github.com/R3G1ST/vpn-system.git xferant-vpn

cd xferant-vpn

# Запрашиваем данные
read -p "🌐 Enter domain (e.g., vpn.example.com): " DOMAIN
read -p "📧 Enter email: " EMAIL

# Генерируем пароли
POSTGRES_PASSWORD=$(openssl rand -base64 32 | tr -d '+/' | head -c 32)
JWT_SECRET=$(openssl rand -base64 64 | tr -d '+/' | head -c 64)
API_SECRET_KEY=$(openssl rand -base64 48 | tr -d '+/' | head -c 48)

# Создаем .env
cat > .env << EOF
DOMAIN=$DOMAIN
EMAIL=$EMAIL
POSTGRES_PASSWORD=$POSTGRES_PASSWORD
JWT_SECRET=$JWT_SECRET
API_SECRET_KEY=$API_SECRET_KEY
POSTGRES_DB=xferant_vpn
POSTGRES_USER=xferant_user
EOF

echo "✅ Environment created"

# Создаем SSL сертификаты
echo "🔐 Creating SSL certificates..."
mkdir -p data/ssl/{certs,private}
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout data/ssl/private/key.pem \
    -out data/ssl/certs/cert.pem \
    -subj "/C=US/ST=State/L=City/O=Xferant/CN=$DOMAIN"

# Запускаем Docker
echo "🐳 Starting Docker services..."
docker-compose build
docker-compose up -d

echo "⏳ Waiting for services to start..."
sleep 30

echo "=========================================="
echo "✅ Installation complete!"
echo ""
echo "🌐 Frontend: http://$DOMAIN"
echo "⚙️  Backend:  http://$DOMAIN:8080"
echo "🔐 VPN Port: 4443"
echo ""
echo "🔧 Commands:"
echo "   cd /opt/xferant-vpn"
echo "   docker-compose ps      # check status"
echo "   docker-compose logs    # view logs"
echo "   docker-compose restart # restart"
echo "=========================================="