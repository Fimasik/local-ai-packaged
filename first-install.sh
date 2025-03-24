#!/bin/bash

set -e

# === Variables ===
PROJECT_DIR="/opt/local-ai-packaged"
DOMAIN_EMAIL="efimchikd@gmail.com"   # <-- UPDATE THIS!
GIT_REPO="https://github.com/Fimasik/local-ai-packaged.git"

# === System Update ===
echo "[+] Updating system..."
apt update && apt upgrade -y

# === Install Required Packages ===
echo "[+] Installing Docker & dependencies..."
apt install -y docker.io docker-compose git python3 python3-pip ufw

# === Enable Docker ===
systemctl enable docker

# === Clone Project ===
echo "[+] Cloning project..."
rm -rf "$PROJECT_DIR"
git clone "$GIT_REPO" "$PROJECT_DIR"
cd "$PROJECT_DIR"

# === Configure Firewall ===
echo "[+] Setting up UFW..."
ufw allow OpenSSH
ufw allow 80
ufw allow 443
ufw allow 5678   # n8n
ufw allow 3000   # Open WebUI
ufw allow 3001   # Flowise
ufw allow 8000   # Supabase Studio
ufw allow 8080   # SearXNG
ufw --force enable

# === .env Setup ===
echo "[+] Creating .env..."
cp .env.example .env

# Auto-fill minimal safe values (replace with secure ones manually later)
sed -i "s|N8N_ENCRYPTION_KEY=|N8N_ENCRYPTION_KEY=$(openssl rand -hex 32)|" .env
sed -i "s|N8N_USER_MANAGEMENT_JWT_SECRET=|N8N_USER_MANAGEMENT_JWT_SECRET=$(openssl rand -hex 32)|" .env
sed -i "s|POSTGRES_PASSWORD=|POSTGRES_PASSWORD=$(openssl rand -hex 16)|" .env
sed -i "s|JWT_SECRET=|JWT_SECRET=$(openssl rand -hex 32)|" .env
sed -i "s|ANON_KEY=|ANON_KEY=$(openssl rand -hex 32)|" .env
sed -i "s|SERVICE_ROLE_KEY=|SERVICE_ROLE_KEY=$(openssl rand -hex 32)|" .env
sed -i "s|DASHBOARD_USERNAME=|DASHBOARD_USERNAME=admin|" .env
sed -i "s|DASHBOARD_PASSWORD=|DASHBOARD_PASSWORD=$(openssl rand -hex 16)|" .env
sed -i "s|POOLER_TENANT_ID=|POOLER_TENANT_ID=$(openssl rand -hex 12)|" .env
sed -i "s|LETSENCRYPT_EMAIL=your-email-address|LETSENCRYPT_EMAIL=$DOMAIN_EMAIL|" .env

# === Launch Services ===
echo "[+] Starting services with CPU profile (Ollama runs elsewhere)..."
python3 start_services.py --profile none

echo "[✔] All services are running!"
echo "n8n:          http://<your-ip>:5678"
echo "Open WebUI:   http://<your-ip>:3000"
echo "Flowise:      http://<your-ip>:3001"
echo "Supabase:     http://<your-ip>:8000"
echo "SearXNG:      http://<your-ip>:8080"
echo ""
echo "[⚠] For production:"
echo "- Update .env with real domain names and secure values."
echo "- Set DNS A records."
echo "- Reboot containers for HTTPS via Caddy to work."
echo "- Replace 'your@example.com' in this script with your real email."
echo ""
echo "Done ✅"
