#!/bin/bash

# Minimal AI Readiness Checker for Linux
# Checks if the machine has the minimum requirements to run local AI models

if [[ "$EUID" -ne 0 ]]; then
  echo "❌ Run this script as root or with sudo to access all system details."
  exit 1
fi

echo "====================================="
echo "🤖 AI HARDWARE READINESS CHECK"
echo "====================================="

# CPU Info
echo -e "\n🧠 CPU Info:"
lscpu | grep -E "Model name|Architecture|CPU\(s\)|Thread|Core"

# Check for AVX instructions
echo -e "\n✅ AVX Instruction Set Support:"
grep -o 'avx[^ ]*' /proc/cpuinfo | sort -u | uniq

# RAM Info
echo -e "\n📦 Memory (RAM):"
free -h | grep -i mem

# SWAP Info
echo -e "\n🔁 Swap:"
free -h | grep -i swap

# Disk Space
echo -e "\n💽 Disk Space (on /):"
df -h / | tail -1

# GPU Info
echo -e "\n🎮 GPU (Graphics Card):"
lspci | grep -i --color 'vga\|3d\|2d'

# OS Info
echo -e "\n🖥️ OS and Kernel:"
cat /etc/os-release | grep PRETTY_NAME
uname -r

echo -e "\n✅ Basic AI readiness check complete."
