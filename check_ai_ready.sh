#!/bin/bash

# Enhanced AI Readiness Hardware Check Script
# Evaluates CPU, RAM, swap, all partitions, GPU, OS, AVX, Docker

if [[ "$EUID" -ne 0 ]]; then
  echo "❌ This script must be run as root (use sudo)."
  exit 1
fi

clear
echo "====================================="
echo "🤖 AI HARDWARE READINESS CHECK"
echo "====================================="

# CPU Info
echo -e "\n🧠 CPU Info:"
lscpu | grep -E "Model name|Architecture|CPU\(s\)|Thread|Core"

# AVX Instruction Set Support
echo -e "\n✅ AVX Instruction Set Support:"
grep -o 'avx[^ ]*' /proc/cpuinfo | sort -u | uniq

# RAM Info
echo -e "\n📦 Memory (RAM):"
free -h | grep -i mem

# SWAP Info
echo -e "\n🔁 Swap:"
free -h | grep -i swap

# Disk Space - All partitions
echo -e "\n💽 Disk Space (ALL PARTITIONS):"
df -hT | grep -vE '^tmpfs|^devtmpfs'

# GPU Info
echo -e "\n🎮 GPU (Graphics Card):"
if command -v lshw &> /dev/null; then
  lshw -C display | grep -E "product|vendor|configuration"
else
  lspci | grep -i --color 'vga\|3d\|2d'
fi

# OS Info
echo -e "\n🖥️ OS and Kernel:"
cat /etc/os-release | grep PRETTY_NAME
uname -r

# Docker Check
echo -e "\n🐳 Docker Installation:"
if command -v docker &> /dev/null; then
  docker --version
  echo "✅ Docker is installed."
else
  echo "❌ Docker is NOT installed."
fi

# Basic Capability Summary
CPU_CORES=$(nproc)
RAM_TOTAL=$(free -g | awk '/Mem:/ {print $2}')
DISK_FREE=$(df / | awk 'NR==2 {print $4}')

echo -e "\n📊 Summary Recommendation:"
if [[ $CPU_CORES -ge 4 && $RAM_TOTAL -ge 8 ]]; then
  echo "🟢 System is suitable for running local AI models and automation."
elif [[ $CPU_CORES -ge 2 && $RAM_TOTAL -ge 4 ]]; then
  echo "🟡 System is limited but can run lightweight AI models and n8n."
else
  echo "🔴 System is not recommended for AI workloads."
fi

echo -e "\n✅ Hardware readiness check complete."
