#!/bin/bash
set -e

# Set non-interactive mode to avoid prompts
export DEBIAN_FRONTEND=noninteractive

# Update system and install WireGuard
apt-get update -y
apt-get install -y wireguard

# Install iptables-persistent without prompts
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | debconf-set-selections
apt-get install -y iptables-persistent

# Enable IP forwarding
echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
sysctl -p

# Create WireGuard directory
mkdir -p /etc/wireguard
chmod 700 /etc/wireguard

# Generate server keys
umask 077
wg genkey | tee /etc/wireguard/server_private.key | wg pubkey > /etc/wireguard/server_public.key

# Generate client keys
wg genkey | tee /etc/wireguard/client_private.key | wg pubkey > /etc/wireguard/client_public.key

# Read keys
SERVER_PRIVATE_KEY=$(cat /etc/wireguard/server_private.key)
SERVER_PUBLIC_KEY=$(cat /etc/wireguard/server_public.key)
CLIENT_PRIVATE_KEY=$(cat /etc/wireguard/client_private.key)
CLIENT_PUBLIC_KEY=$(cat /etc/wireguard/client_public.key)

# Get server public IP
SERVER_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

# Create WireGuard server configuration
cat > /etc/wireguard/wg0.conf << EOF
[Interface]
Address = 10.8.0.1/24
SaveConfig = false
PrivateKey = $SERVER_PRIVATE_KEY
ListenPort = 51820

# Enable NAT for VPN traffic
PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o %i -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -D FORWARD -o %i -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

[Peer]
PublicKey = $CLIENT_PUBLIC_KEY
AllowedIPs = 10.8.0.2/32
EOF

# Create client configuration using your template approach
cat > /etc/wireguard/client.conf << EOF
[Interface]
PrivateKey = $CLIENT_PRIVATE_KEY
Address = 10.8.0.2/32
DNS = 8.8.8.8, 8.8.4.4

[Peer]
PublicKey = $SERVER_PUBLIC_KEY
Endpoint = $SERVER_IP:51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
EOF

# Set permissions
chmod 600 /etc/wireguard/wg0.conf
chmod 600 /etc/wireguard/client.conf
chmod 600 /etc/wireguard/*_private.key

# Enable and start WireGuard
systemctl enable wg-quick@wg0
systemctl start wg-quick@wg0

# Save iptables rules
iptables-save > /etc/iptables/rules.v4

# Log completion
echo "$(date): WireGuard VPN setup completed" >> /var/log/wireguard-setup.log
echo "Client config available at: /etc/wireguard/client.conf" >> /var/log/wireguard-setup.log