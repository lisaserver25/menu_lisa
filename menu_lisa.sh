#!/bin/bash

# ==============================================================================
# Script de Menú para Gestión de Servidores (Estilo Consola)
# Autor: Generado por IA para el usuario
# Versión: 6.3 (Título actualizado)
# ==============================================================================

# --- DEFINICIÓN DE COLORES ---
ROJO="\e[31m"
VERDE="\e[32m"
AMARILLO="\e[33m"
CYAN="\e[36m"
GRIS="\e[90m"
BLANCO_BRILLANTE="\e[97m"
MAGENTA="\e[35m"
FIN="\e[0m"

# --- FUNCIÓN PARA COMPROBAR DEPENDENCIAS (OPTIMIZADA) ---
check_dependencies() {
    echo -e "${CYAN}› Comprobando dependencias...${FIN}"
    declare -a deps_to_check=("git" "python3" "curl" "jp2a" "rsvg-convert" "convert")
    local missing_deps=()

    for dep in "${deps_to_check[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing_deps+=("$dep")
        fi
    done

    if [ ${#missing_deps[@]} -gt 0 ]; then
        echo -e "${AMARILLO}› Se instalarán las siguientes dependencias: ${missing_deps[*]}.${FIN}"
        if command -v apt-get &>/dev/null; then apt-get update -qq 2>/dev/null; fi
        
        for dep in "${missing_deps[@]}"; do
            echo -e "${CYAN}  - Instalando '${dep}'...${FIN}"; local pkg_name="$dep"
            case "$dep" in "rsvg-convert") if command -v apt-get &>/dev/null; then pkg_name="librsvg2-bin"; else pkg_name="librsvg2-tools"; fi;; "convert") pkg_name="imagemagick";; esac
            
            if command -v apt-get &>/dev/null; then apt-get install -y -qq "$pkg_name" 2>/dev/null
            elif command -v dnf &>/dev/null; then if [[ "$pkg_name" == "jp2a" || "$pkg_name" == "imagemagick" ]]; then dnf install -y -q epel-release 2>/dev/null; fi; dnf install -y -q "$pkg_name" 2>/dev/null
            elif command -v yum &>/dev/null; then if [[ "$pkg_name" == "jp2a" || "$pkg_name" == "imagemagick" ]]; then yum install -y -q epel-release 2>/dev/null; fi; yum install -y -q "$pkg_name" 2>/dev/null; fi
            
            if ! command -v "$dep" &>/dev/null; then echo -e "${ROJO}› Error Crítico: Fallo al instalar '${dep}'.${FIN}"; exit 1; fi
        done
    fi
    echo -e "${VERDE}› Entorno listo.${FIN}"; sleep 1
}

# --- FUNCIÓN #1: FORZAR INSTALACIÓN / ACTUALIZACIÓN ---
force_install() {
    local script_final_name="$1"; local repo_url="$2"; local interpreter="${3:-bash}"
    local script_path="/root/${script_final_name}";
    
    echo -e "\n${CYAN}› Descargando la última versión de '${script_final_name}'...${FIN}"
    local tmp_dir=$(mktemp -d)
    if git clone --quiet --depth 1 "$repo_url" "$tmp_dir"; then
        local found_script_path=$(find "$tmp_dir" -type f \( -name "*.sh" -o -name "*.py" \) | head -n 1)
        if [ -n "$found_script_path" ]; then
            rm -f "$script_path"
            mv "$found_script_path" "$script_path"
            chmod +x "$script_path"
            rm -rf "$tmp_dir"; history -c -w
            echo -e "${VERDE}› '${script_final_name}' ha sido actualizado correctamente.${FIN}"
        else rm -rf "$tmp_dir"; echo -e "${ROJO}Error: No se encontró script en el repositorio.${FIN}"; fi
    else rm -rf "$tmp_dir"; echo -e "\n${ROJO}Error: Falló la clonación del repositorio.\n${AMARILLO}› Si usas una URL SSH (git@github.com), asegúrate de tener la clave SSH configurada.\n› Si no, prueba a usar la URL HTTPS (https://github.com...).${FIN}"; fi
    sleep 2
}

# --- FUNCIÓN #2: EJECUTAR O INSTALAR ---
run_or_install() {
    local script_final_name="$1"; local repo_url="$2"; local interpreter="${3:-bash}"
    local script_path="/root/${script_final_name}"

    if [ -f "$script_path" ]; then
        echo -e "${VERDE}› Ejecutando '${script_final_name}'...${FIN}"
        "$interpreter" "$script_path"
        read -p $'\nPresiona ENTER para volver al menú...'
    else
        echo -e "${AMARILLO}› Script no encontrado. Se procederá a la instalación.${FIN}"
        force_install "$script_final_name" "$repo_url" "$interpreter"
        if [ -f "$script_path" ]; then
            echo -e "\n${VERDE}› Ejecutando el script recién instalado...${FIN}"
            "$interpreter" "$script_path"
            read -p $'\nPresiona ENTER para volver al menú...'
        fi
    fi
}

# --- FUNCIÓN #3: SUBMENÚ DE ACTUALIZACIONES ---
show_update_menu() {
    while true; do
        clear; echo; echo
        echo -e "${MAGENTA}===================================================${FIN}"
        echo -e "              ${BLANCO_BRILLANTE}MENÚ DE ACTUALIZACIONES${FIN}"
        echo -e "${MAGENTA}===================================================${FIN}"
        echo -e "\n${CYAN}Elige el script que deseas forzar a actualizar:${FIN}\n"
        echo -e "  ${AMARILLO}1)${FIN} ${BLANCO_BRILLANTE}Gestión y Monitorización${FIN}"
        echo -e "  ${AMARILLO}2)${FIN} ${BLANCO_BRILLANTE}Renovaciones Servidores LISA${FIN}"
        echo -e "  ${AMARILLO}3)${FIN} ${BLANCO_BRILLANTE}Analizador de URLs${FIN}"
        echo
        echo -e "  ${AMARILLO}0)${FIN} ${GRIS}Volver al Menú Principal${FIN}"
        echo -e "${MAGENTA}---------------------------------------------------${FIN}"
        read -p "$(echo -e ${CYAN}› Selecciona una opción: ${FIN})" UPDATE_CHOICE

        case $UPDATE_CHOICE in
            1) force_install "lisa.sh" "https://github.com/lisaserver25/lisa.git" "bash";;
            2) force_install "renovaciones.sh" "https://github.com/lisaserver25/renovacioneslisa.git" "bash";;
            3) force_install "analizador_url.sh" "https://github.com/lisaserver25/analizador_url.git" "python3";;
            0) break;;
            *) echo -e "\n${ROJO}Opción no válida.${FIN}"; sleep 1.5;;
        esac
    done
}

# --- OTRAS FUNCIONES ---
convert_logo_to_ascii() { read -p "$(echo -e "${CYAN}› Introduce la URL de la imagen (SVG, PNG, JPG): ${FIN}")" LOGO_URL; if [ -z "$LOGO_URL" ]; then echo -e "${ROJO}Error: No se introdujo ninguna URL.${FIN}"; sleep 1; return; fi; echo -e "\n${CYAN}› Convirtiendo logo...${FIN}\n"; local command_to_save=""; case "$LOGO_URL" in *.svg|*.SVG) if ! command -v rsvg-convert &> /dev/null; then echo -e "${ROJO}Error: 'rsvg-convert' no está instalado.${FIN}"; sleep 2; return; fi; curl -sL "$LOGO_URL" | rsvg-convert | jp2a --color --width=80 -; command_to_save="curl -sL \"$LOGO_URL\" | rsvg-convert | jp2a --color --width=80 -";; *.png|*.PNG|*.jpg|*.JPG|*.jpeg|*.JPEG) if ! command -v convert &> /dev/null; then echo -e "${ROJO}Error: 'imagemagick' no está instalado.${FIN}"; sleep 2; return; fi; curl -sL "$LOGO_URL" | convert - jpg:- | jp2a --color --width=80 -; command_to_save="curl -sL \"$LOGO_URL\" | convert - jpg:- | jp2a --color --width=80 -";; *) echo -e "${ROJO}Error: Formato de archivo no soportado.${FIN}"; sleep 2; return; ;; esac; echo; read -p "$(echo -e "${CYAN}› ¿Quieres guardar este comando en un script? (s/N): ${FIN}")" save_choice; if [[ "$save_choice" =~ ^[sS]$ ]]; then local save_path="/root/logo_ascii_command.sh"; echo "#!/bin/bash" > "$save_path"; echo "$command_to_save" >> "$save_path"; chmod +x "$save_path"; echo -e "${VERDE}› ¡Comando guardado en ${save_path}!${FIN}"; fi; read -p $'\nPresiona ENTER...'; }
show_pending_message() { echo; echo; echo -e "\n${AMARILLO}=============================================${FIN}"; echo -e "         ${BLANCO_BRILLANTE}Opción en Desarrollo${FIN}"; echo -e "${AMARILLO}=============================================${FIN}"; echo -e "\n${CYAN}› Este script está pendiente de ser añadido.${FIN}\n"; read -p "Presiona ENTER..."; }
show_legal_notice() { echo; echo; echo -e "${AMARILLO}=======================================================================${FIN}"; echo -e "${BLANCO_BRILLANTE}                          AVISO LEGAL Y DE USO${FIN}"; echo -e "${AMARILLO}=======================================================================${FIN}"; echo; echo -e "... (texto legal) ..."; read -p $'\nPresiona ENTER...'; }

# --- FUNCIÓN DEL MENÚ PRINCIPAL ---
show_menu() {
    while true; do
        clear; echo; echo
        
        # Título
        echo -e "        ${VERDE}██╗     ██╗███████╗ █████╗${FIN}"
        echo -e "        ${VERDE}██║     ██║██╔════╝██╔══██╗${FIN}"
        echo -e "        ${VERDE}██║     ██║███████╗███████║${FIN}"
        echo -e "        ${VERDE}██║     ██║╚════██║██╔══██║${FIN}"
        echo -e "        ${VERDE}███████╗██║███████║██║  ██║${FIN}"
        echo -e "        ${VERDE}╚══════╝╚═╝╚══════╝╚═╝  ╚═╝${FIN}"
        echo -e "        ${BLANCO_BRILLANTE}S  E  R  V  E  R${FIN}"
        echo -e "  ${MAGENTA}===================================================${FIN}"
        echo -e "       ${BLANCO_BRILLANTE}Panel de Control y Seguimiento de Renovaciones${FIN}"
        echo -e "  ${MAGENTA}===================================================${FIN}\n"

        echo -e "  ${CYAN}LisaServer${FIN}"; echo -e "  ${AMARILLO} 1)${FIN} ${BLANCO_BRILLANTE}Gestión y Monitorización${FIN}"; echo -e "  ${AMARILLO} 2)${FIN} ${BLANCO_BRILLANTE}Renovaciones Servidores LISA${FIN}"; echo -e "  ${AMARILLO} 3)${FIN} ${GRIS}Índice de Herramientas (Pendiente)${FIN}"; echo
        echo -e "  ${CYAN}Herramientas de Servidor${FIN}"; echo -e "  ${AMARILLO} 4)${FIN} ${BLANCO_BRILLANTE}Analizador de URLs${FIN}"; echo -e "  ${AMARILLO} 5)${FIN} ${GRIS}Instalación de Servidor Plex (Pendiente)${FIN}"; echo -e "  ${AMARILLO} 6)${FIN} ${GRIS}Instalación de IPTV (Pendiente)${FIN}"; echo -e "  ${AMARILLO} 7)${FIN} ${BLANCO_BRILLANTE}Convertir Logo a ASCII${FIN}"; echo
        echo -e "  ${CYAN}Sistema e Información${FIN}"; echo -e "  ${AMARILLO} 8)${FIN} ${VERDE}Actualizar Scripts${FIN}"; echo -e "  ${AMARILLO}50)${FIN} ${BLANCO_BRILLANTE}Reiniciar Servidor${FIN}"; echo -e "  ${AMARILLO}99)${FIN} ${BLANCO_BRILLANTE}Aviso Legal${FIN}"; echo -e "   ${AMARILLO}0)${FIN} ${BLANCO_BRILLANTE}Salir${FIN}"; echo -e "${MAGENTA}---------------------------------------------------${FIN}"
        read -p "$(echo -e ${CYAN}› Selecciona una opción y presiona ENTER: ${FIN})" CHOICE

        case $CHOICE in
            1) echo; echo; run_or_install "lisa.sh" "https://github.com/lisaserver25/lisa.git" "bash";;
            2) echo; echo; run_or_install "renovaciones.sh" "https://github.com/lisaserver25/renovacioneslisa.git" "bash";;
            3) show_pending_message;;
            4) echo; echo; run_or_install "analizador_url.sh" "https://github.com/lisaserver25/analizador_url.git" "python3";;
            5) show_pending_message;;
            6) show_pending_message;;
            7) echo; echo; convert_logo_to_ascii;;
            8) show_update_menu;;
            50) echo; echo; echo -e "${AMARILLO}Estás a punto de reiniciar...${FIN}"; read -p "¿Estás seguro? (s/N): " confirm; if [[ "$confirm" =~ ^[sS]$ ]]; then echo -e "${ROJO}› Reiniciando...${FIN}"; reboot; else echo -e "${VERDE}› Cancelado.${FIN}"; sleep 1; fi;;
            99) show_legal_notice;;
            0) echo -e "\n${CYAN}› Saliendo...${FIN}"; break;;
            *) echo; echo; echo -e "${ROJO}Opción no válida.${FIN}"; sleep 1.5;;
        esac
    done
}

# --- EJECUCIÓN DEL SCRIPT ---
if [[ $EUID -ne 0 ]]; then echo -e "${ROJO}Error: Este script debe ser ejecutado como root.${FIN}\n${AMARILLO}Por favor, ejecútalo usando: sudo ./menu_lisa.sh${FIN}"; exit 1; fi
clear; check_dependencies; show_menu