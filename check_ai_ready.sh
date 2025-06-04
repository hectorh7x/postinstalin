#!/bin/bash

# Enhanced AI Readiness Hardware Check Script for Ubuntu or Rocky Linux
# Evaluates CPU, RAM, swap, all partitions, GPU, OS, AVX, Docker

if [[ "$EUID" -ne 0 ]]; then
  echo "❌ This script must be run as root (use sudo)."
  exit 1
fi

# Detección de Sistema Operativo
if [ -f /etc/os-release ]; then
  . /etc/os-release
  OS=$ID
  VER=$VERSION_ID
else
  echo "❌ Unable to detect operating system."
  exit 1
fi

clear
echo "====================================="
echo "🤖 AI HARDWARE READINESS CHECK"
echo "OS detected: $PRETTY_NAME"
echo "====================================="

# CPU Info
echo -e "\n🧠 CPU Info:"
if command -v lscpu &> /dev/null; then
  lscpu | grep -E "Model name|Architecture|CPU\(s\)|Thread|Core"
else
  echo "lscpu not found."
fi

# AVX Instruction Set Support
echo -e "\n✅ AVX Instruction Set Support:"
if grep -q avx /proc/cpuinfo; then
  grep -o 'avx[^ ]*' /proc/cpuinfo | sort -u | uniq
else
  echo "AVX not supported or /proc/cpuinfo not found."
fi

# RAM Info
echo -e "\n📦 Memory (RAM):"
if command -v free &> /dev/null; then
  free -h | grep -i mem
else
  echo "free not found."
fi

# SWAP Info
echo -e "\n🔁 Swap:"
if command -v free &> /dev/null; then
  free -h | grep -i swap
else
  echo "free not found."
fi

# Disk Space - All partitions
echo -e "\n💽 Disk Space (ALL PARTITIONS):"
if command -v df &> /dev/null; then
  df -hT | grep -vE '^tmpfs|^devtmpfs'
else
  echo "df not found."
fi

# GPU Info
echo -e "\n🎮 GPU (Graphics Card):"
if command -v lshw &> /dev/null; then
  lshw -C display | grep -E "product|vendor|configuration"
elif command -v lspci &> /dev/null; then
  lspci | grep -i --color 'vga\|3d\|2d'
else
  echo "Neither lshw nor lspci found. Install lshw or pciutils."
fi

# OS Info
echo -e "\n🖥️ OS and Kernel:"
if [ -f /etc/os-release ]; then
  cat /etc/os-release | grep PRETTY_NAME
else
  echo "OS info not found."
fi
uname -r

# Docker Check
echo -e "\n🐳 Docker Installation:"
if command -v docker &> /dev/null; then
  docker --version
  echo "✅ Docker is installed."
else
  echo "❌ Docker is NOT installed."
  if [[ "$OS" == "ubuntu" ]]; then
    echo "To install Docker on Ubuntu: sudo apt update && sudo apt install -y docker.io"
  elif [[ "$OS" == "rocky" || "$OS" == "rocky-linux" ]]; then
    echo "To install Docker on Rocky Linux: sudo dnf install -y docker"
  fi
fi

# Basic Capability Summary
if command -v nproc &> /dev/null; then
  CPU_CORES=$(nproc)
else
  CPU_CORES="?"
fi

if command -v free &> /dev/null; then
  RAM_TOTAL=$(free -g | awk '/Mem:/ {print $2}')
else
  RAM_TOTAL="?"
fi

if command -v df &> /dev/null; then
  DISK_FREE=$(df / | awk 'NR==2 {print $4}')
else
  DISK_FREE="?"
fi

echo -e "\n📊 Summary Recommendation:"
if [[ "$CPU_CORES" != "?" && "$RAM_TOTAL" != "?" ]]; then
  if [[ $CPU_CORES -ge 4 && $RAM_TOTAL -ge 8 ]]; then
    echo "🟢 System is suitable for running local AI models and automation."
  elif [[ $CPU_CORES -ge 2 && $RAM_TOTAL -ge 4 ]]; then
    echo "🟡 System is limited but can run lightweight AI models and n8n."
  else
    echo "🔴 System is not recommended for AI workloads."
  fi
else
  echo "Could not determine full system capability."
fi

echo -e "\n✅ Hardware readiness check complete."
