#!/bin/bash

# ==============================================================================
# Ubuntu Server 24.04 Post-Install Script 
# Must be run as root or using sudo
# ==============================================================================

set -eo pipefail
export DEBIAN_FRONTEND=noninteractive

# Verificación de root
if [[ "$EUID" -ne 0 ]]; then
  echo "❌ Este script debe ejecutarse como root o usando sudo."
  exit 1
fi

echo "🔧 Actualizando el sistema..."
apt update -y && apt upgrade -y

# ------------------------------------------------------------------------------
# HERRAMIENTAS ESENCIALES Y DE RED (Instalación por defecto - Orden Alfabético)
# ------------------------------------------------------------------------------
# - bash-completion: Autocompletado avanzado para comandos en la terminal.
# - curl: Descarga de archivos y peticiones HTTP desde la línea de comandos.
# - dnsutils: Utilidades de consulta DNS esenciales (dig, nslookup).
# - git: Sistema de control de versiones.
# - htop: Monitor interactivo de procesos del sistema.
# - mc (Midnight Commander): Gestor de archivos visual en modo texto.
# - mtr: Diagnóstico de red que combina ping y traceroute.
# - nano: Editor de texto simple en terminal.
# - netcat: Herramienta multipropósito para redes y sockets TCP/UDP.
# - net-tools: Utilidades de red clásicas (netstat, ifconfig).
# - nmap: Escáner de puertos y auditoría de red.
# - rsync: Sincronización y copia rápida de archivos locales o remotos.
# - tar: Compresión y descompresión de archivos.
# - tree: Visualizador de directorios en formato de árbol.
# - unzip: Descompresión de archivos ZIP.
# - vim: Editor de texto avanzado en terminal.
# - wget: Descarga de archivos desde la web.
# - zip: Compresión de archivos en formato ZIP.
# - zstd: Algoritmo de compresión moderno y de ultra alto rendimiento.
echo "🧰 Instalando herramientas esenciales y de red..."
apt install -y bash-completion curl dnsutils git htop mc mtr nano netcat net-tools nmap rsync tar tree unzip vim wget zip zstd timeshift


# ------------------------------------------------------------------------------
# GRUPO 1: HERRAMIENTAS MODERNAS Y ADICIONALES (Opcional - Orden Alfabético)
# ------------------------------------------------------------------------------
echo ""
read -p "❓ ¿Deseas instalar el grupo de herramientas modernas y adicionales (bat, btop, eza, fd, etc.)? (s/n): " install_modern
if [[ "$install_modern" =~ ^[Ss]$ ]]; then
    # - bat: Reemplazo de 'cat' con resaltado de sintaxis e integración con Git.
    # - btop: Monitor de recursos moderno, detallado y visual con soporte de ratón.
    # - eza: Reemplazo moderno y colorido para el comando 'ls' (con soporte de Git).
    # - fd-find: Alternativa rápida, amigable e intuitiva al comando 'find'.
    # - fzf: Buscador difuso (fuzzy finder) interactivo para archivos e historial.
    # - inotify-tools: Utilidades para monitorear cambios en archivos en tiempo real.
    # - jq: Procesador liviano y flexible de archivos JSON.
    # - ncdu: Analizador visual de uso de disco en modo texto.
    # - ripgrep (rg): Herramienta de búsqueda de texto ultrarrápida.
    echo "🧰 Instalando herramientas modernas y adicionales..."
    apt install -y bat btop eza fd-find fzf inotify-tools jq ncdu ripgrep

    echo "🔗 Configurando enlaces simbólicos para comandos modernos..."
    if command -v fdfind &> /dev/null && [ ! -e /usr/local/bin/fd ]; then
        ln -s "$(which fdfind)" /usr/local/bin/fd
    fi
    if command -v batcat &> /dev/null && [ ! -e /usr/local/bin/bat ]; then
        ln -s "$(which batcat)" /usr/local/bin/bat
    fi
else
    echo "⏭️ Omitiendo herramientas modernas y adicionales."
fi


# ------------------------------------------------------------------------------
# GRUPO 2: ENTORNO DE CONTENEDORES - DOCKER (Opcional)
# ------------------------------------------------------------------------------
echo ""
read -p "❓ ¿Deseas instalar Docker y Docker Compose? (s/n): " install_docker
if [[ "$install_docker" =~ ^[Ss]$ ]]; then
    # - docker.io: Motor de contenedores para crear y ejecutar contenedores.
    # - docker-compose-v2: Herramienta de orquestación para aplicaciones multi-contenedor.
    echo "🐳 Instalando Docker y Docker Compose..."
    apt install -y ca-certificates gnupg
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    chmod a+r /etc/apt/keyrings/docker.gpg

    echo \
      "deb [arch=\"$(dpkg --print-architecture)\" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      \"$(. /etc/os-release && echo "$VERSION_CODENAME")\" stable" | \
      tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    apt update -y
    apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    systemctl enable --now docker
    echo "✅ Docker instalado y activo correctamente."
else
    echo "⏭️ Omitiendo la instalación de Docker."
fi


# ------------------------------------------------------------------------------
# GRUPO 3: AUDITORÍA DE SEGURIDAD, HARDENING Y VULNERABILIDADES (Opcional - Orden Alfabético)
# ------------------------------------------------------------------------------
echo ""
read -p "❓ ¿Deseas instalar herramientas de auditoría, OpenSCAP y Trivy? (s/n): " install_audit
if [[ "$install_audit" =~ ^[Ss]$ ]]; then
    # - auditd: Sistema de auditoría y registro de llamadas al sistema a nivel de kernel.
    # - audispd-plugins: Complementos de reenvío y plugins para el servicio auditd.
    # - fail2ban: Prevención de ataques de fuerza bruta (bloqueo automático de IPs).
    # - libopenscap8: Motor de evaluación y perfiles SCAP de cumplimiento normativo.
    # - lynis: Auditoría de seguridad y análisis heurístico de configuraciones.
    # - scap-security-guide: Guías de seguridad y perfiles de cumplimiento normativo.
    # - trivy: Escáner integral para detección de vulnerabilidades (CVEs) y archivos.
    echo "🛡️ Instalando OpenSCAP, Trivy y herramientas de hardening..."
    apt install -y auditd audispd-plugins fail2ban libopenscap8 lynis scap-security-guide trivy
    systemctl enable --now fail2ban
    echo "✅ Herramientas de auditoría, OpenSCAP y Trivy instaladas correctamente."
else
    echo "⏭️ Omitiendo herramientas de auditoría."
fi


# ------------------------------------------------------------------------------
# HERRAMIENTAS DE HARDWARE Y DIAGNÓSTICO (Instalación por defecto - Orden Alfabético)
# ------------------------------------------------------------------------------
# - dmidecode: Extrae información del hardware del sistema desde la tabla DMI/SMBIOS.
# - iotop: Monitor de uso de E/S (I/O) de disco en tiempo real por proceso.
# - iproute2: Herramientas modernas de gestión de red.
# - lm-sensors: Monitorea temperaturas de la CPU, voltajes y ventiladores.
# - lshw: Muestra información detallada sobre la configuración de hardware.
# - pciutils: Listan dispositivos PCI conectados al sistema.
# - procps: Utilidades básicas del núcleo y gestión de procesos del sistema.
# - smartmontools: Monitorea el estado de salud de discos duros/SSD (S.M.A.R.T.).
# - usbutils: Listan dispositivos USB conectados al sistema.
# - util-linux: Utilidades básicas del sistema y particionado.
echo "🧪 Instalando herramientas de hardware y diagnóstico..."
apt install -y dmidecode iotop iproute2 lm-sensors lshw pciutils procps smartmontools usbutils util-linux

# ------------------------------------------------------------------------------
# SEGURIDAD Y CORTAFUEGOS (UFW)
# ------------------------------------------------------------------------------
# - ufw: Interfaz simplificada para gestionar el cortafuegos.
echo "🔥 Configurando UFW (SSH solamente)..."
apt install -y ufw
ufw allow OpenSSH
ufw --force enable

# ------------------------------------------------------------------------------
# MONITOREO Y RENDIMIENTO HISTÓRICO
# ------------------------------------------------------------------------------
# - sysstat: Recopila métricas históricas de rendimiento (CPU, I/O de disco, memoria).
echo "📊 Instalando herramientas de monitoreo..."
apt install -y sysstat
systemctl enable --now sysstat

echo "🧹 Limpiando el sistema..."
apt autoremove -y
apt clean

echo "✅ Configuración post-instalación completada. ¡Ubuntu Server 24.04 está listo!"
