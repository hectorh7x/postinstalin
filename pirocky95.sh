#!/bin/bash

# Rocky Linux 9.5 Post-Install Script (Basic Version – no SSH or user creation)
# Must be run as root or using sudo
# This script performs essential system setup after a fresh Rocky Linux 9.5 installation.

echo "🔧 Updating the system..."
# Update and upgrade all existing packages
dnf update -y && dnf upgrade -y

echo "🧰 Installing essential tools..."
# Install commonly used tools and utilities
dnf install -y epel-release
dnf install -y vim git curl wget htop net-tools unzip nano bash-completion nmap mc nc tcpdump mtr rsync zip unzip tree

echo "🔥 Configuring firewalld (SSH only)..."
# Enable and start firewalld, and allow SSH traffic
systemctl enable firewalld --now
firewall-cmd --permanent --add-service=ssh
firewall-cmd --reload

echo "📦 Enabling CRB repository (CodeReady Builder)..."
# Enable the CodeReady Builder repository for additional packages required by some tools
dnf config-manager --set-enabled crb

echo "📊 Installing monitoring tools..."
# Install and enable sysstat for performance and resource monitoring
dnf install -y sysstat
systemctl enable --now sysstat

echo "🧹 Cleaning up the system..."
# Remove unused packages and clean the package cache
dnf autoremove -y
dnf clean all

echo "✅ Basic post-install setup completed. Rocky Linux 9.5 is ready to use!"
