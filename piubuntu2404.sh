#!/bin/bash

# Ubuntu Server 24.04 Post-Install Script (Fully Unattended)
# Must be run as root or using sudo

export DEBIAN_FRONTEND=noninteractive

# Verificación de root
if [[ "$EUID" -ne 0 ]]; then
  echo "❌ Este script debe ejecutarse como root o usando sudo."
  exit 1
fi

echo "🔧 Actualizando el sistema..."
apt update -y && apt upgrade -y

echo "🧰 Instalando herramientas esenciales..."
apt install -y vim git curl wget htop net-tools unzip nano bash-completion nmap mc netcat tcpdump mtr rsync zip tree tar

echo "🧪 Instalando herramientas de hardware y diagnóstico..."
apt install -y lshw lm-sensors iproute2 pciutils usbutils smartmontools dmidecode util-linux procps

echo "🔥 Configurando UFW (SSH solamente)..."
apt install -y ufw
ufw allow OpenSSH
ufw --force enable

echo "📊 Instalando herramientas de monitoreo..."
apt install -y sysstat
systemctl enable --now sysstat

echo "🧹 Limpiando el sistema..."
apt autoremove -y
apt clean

echo "✅ Configuración post-instalación básica completada. ¡Ubuntu Server 24.04 está listo para usar!"
