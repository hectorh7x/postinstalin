#!/bin/bash

# Rocky Linux 9.5 Post-Install Script (Basic Version – no SSH or user creation)
# Must be run as root or using sudo

# Verificación de root
if [[ "$EUID" -ne 0 ]]; then
  echo "❌ Este script debe ejecutarse como root o usando sudo."
  exit 1
fi

echo "🔧 Updating the system..."
dnf update -y && dnf upgrade -y

echo "📦 Enabling CRB repository (CodeReady Builder)..."
# Enable the CodeReady Builder repository for additional packages
dnf config-manager --set-enabled crb

echo "🧰 Installing essential tools..."
dnf install -y epel-release
dnf install -y vim git curl wget htop net-tools unzip nano bash-completion nmap mc nc tcpdump mtr rsync zip unzip tree tar

echo "🧪 Installing hardware and diagnostic tools..."
dnf install -y lshw lm_sensors iproute pciutils usbutils smartmontools dmidecode util-linux procps-ng

echo "🔥 Configuring firewalld (SSH only)..."
systemctl enable firewalld --now
firewall-cmd --permanent --add-service=ssh
firewall-cmd --reload

echo "📊 Installing monitoring tools..."
dnf install -y sysstat
systemctl enable --now sysstat

echo "🧹 Cleaning up the system..."
dnf autoremove -y
dnf clean all

echo "✅ Basic post-install setup completed. Rocky Linux 9.5 is ready to use!"
