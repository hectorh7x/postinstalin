#!/bin/bash

# === Configuración por defecto ===
CONTENEDOR="contenedor.img"
NOMBRE_LOGICO="mi_contenedor"
PUNTO_MONTAJE="$HOME/contenedor_cifrado"

function crear_contenedor() {
    echo "Tamaño en MB del contenedor:"
    read TAMANIO_MB
    echo "[+] Creando archivo de $TAMANIO_MB MB..."
    dd if=/dev/zero of="$CONTENEDOR" bs=1M count=$TAMANIO_MB status=progress

    echo "[+] Cifrando con LUKS (te pedirá una contraseña)..."
    sudo cryptsetup luksFormat "$CONTENEDOR"

    echo "[+] Abriendo contenedor..."
    sudo cryptsetup open "$CONTENEDOR" "$NOMBRE_LOGICO"

    echo "[+] Formateando como ext4..."
    sudo mkfs.ext4 /dev/mapper/"$NOMBRE_LOGICO"

    mkdir -p "$PUNTO_MONTAJE"
    echo "[+] Montando en $PUNTO_MONTAJE..."
    sudo mount /dev/mapper/"$NOMBRE_LOGICO" "$PUNTO_MONTAJE"

    echo "[✔] Contenedor creado y montado en $PUNTO_MONTAJE"
}

function montar_contenedor() {
    if [ ! -f "$CONTENEDOR" ]; then
        echo "[!] Contenedor no encontrado: $CONTENEDOR"
        return
    fi

    echo "[+] Abriendo contenedor..."
    sudo cryptsetup open "$CONTENEDOR" "$NOMBRE_LOGICO"

    mkdir -p "$PUNTO_MONTAJE"
    echo "[+] Montando en $PUNTO_MONTAJE..."
    sudo mount /dev/mapper/"$NOMBRE_LOGICO" "$PUNTO_MONTAJE"

    echo "[✔] Contenedor montado en $PUNTO_MONTAJE"
}

function desmontar_contenedor() {
    echo "[+] Desmontando $PUNTO_MONTAJE..."
    sudo umount "$PUNTO_MONTAJE"
    sudo cryptsetup close "$NOMBRE_LOGICO"
    echo "[✔] Contenedor desmontado y cerrado."
}

function eliminar_contenedor() {
    read -p "¿Estás seguro de que quieres ELIMINAR el contenedor? (sí/no): " RESP
    if [ "$RESP" == "sí" ] || [ "$RESP" == "si" ]; then
        desmontar_contenedor
        rm -f "$CONTENEDOR"
        echo "[✔] Contenedor eliminado."
    else
        echo "[!] Cancelado."
    fi
}

function menu() {
    clear
    echo "===== Cerradura 🔐 ====="
    echo "1. Crear contenedor"
    echo "2. Montar contenedor"
    echo "3. Desmontar contenedor"
    echo "4. Eliminar contenedor"
    echo "5. Salir"
    echo "========================"
    read -p "Elige una opción: " OPCION

    case $OPCION in
        1) crear_contenedor ;;
        2) montar_contenedor ;;
        3) desmontar_contenedor ;;
        4) eliminar_contenedor ;;
        5) exit 0 ;;
        *) echo "Opción inválida" ;;
    esac
    echo ""
    read -p "Presiona ENTER para continuar..." TEMP
}

# === Bucle principal ===
while true; do
    menu
done
