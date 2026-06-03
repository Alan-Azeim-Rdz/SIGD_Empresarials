#!/bin/bash

# Script de control para levantar, apagar o reiniciar los 3 módulos del sistema SIGD en Linux o macOS.
ACTION=${1:-"menu"}
MODULE=${2:-"all"}

# Colores para la consola
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

ensure_network() {
    echo -e "${CYAN}Verificando red Docker 'sigd_network'...${NC}"
    if [ -z "$(docker network ls --filter name=sigd_network -q)" ]; then
        echo -e "${YELLOW}Creando red Docker 'sigd_network'...${NC}"
        docker network create sigd_network
    else
        echo -e "${GREEN}La red 'sigd_network' ya existe.${NC}"
    fi
}

run_compose() {
    local cmd_action=$1
    local target_module=$2

    ensure_network

    declare -A compose_files
    compose_files[central]="docker-compose.central.yml"
    compose_files[reportes]="docker-compose.reportes.yml"
    compose_files[busqueda]="docker-compose.busqueda.yml"

    local targets=()
    if [ "$target_module" == "all" ]; then
        if [ "$cmd_action" == "up" ]; then
            targets=("busqueda" "reportes" "central")
        else
            targets=("central" "reportes" "busqueda")
        fi
    else
        if [ -n "${compose_files[$target_module]}" ]; then
            targets=("$target_module")
        else
            echo -e "${RED}Error: Módulo '$target_module' no válido. Use: all, central, reportes, busqueda.${NC}"
            return 1
        fi
    fi

    for t in "${targets[@]}"; do
        local file=${compose_files[$t]}
        echo -e "${CYAN}--------------------------------------------------------${NC}"
        echo -e "${CYAN}Ejecutando '$cmd_action' para el módulo: $t ($file)${NC}"
        echo -e "${CYAN}--------------------------------------------------------${NC}"

        if [ "$cmd_action" == "up" ]; then
            docker compose -f "$file" up -d --build
        elif [ "$cmd_action" == "down" ]; then
            docker compose -f "$file" down
        elif [ "$cmd_action" == "clean" ]; then
            docker compose -f "$file" down -v
        elif [ "$cmd_action" == "restart" ]; then
            docker compose -f "$file" restart
        elif [ "$cmd_action" == "logs" ]; then
            docker compose -f "$file" logs --tail=100 -f
        elif [ "$cmd_action" == "build" ]; then
            docker compose -f "$file" build --no-cache
        fi
    done
}

if [ "$ACTION" == "menu" ]; then
    clear
    echo -e "${CYAN}=============================================${NC}"
    echo -e "${CYAN}      SIGD EMPRESARIAL — DOCKER MANAGER      ${NC}"
    echo -e "${CYAN}=============================================${NC}"
    echo "1. Iniciar todos los servicios (Start)"
    echo "2. Detener todos los servicios (Stop)"
    echo "3. Reiniciar todos los servicios (Restart)"
    echo "4. Ver logs del sistema (Logs)"
    echo "5. Reconstruir imágenes sin caché (Build)"
    echo "6. Limpiar volúmenes / Reiniciar BD (Clean)"
    echo "7. Iniciar módulo específico"
    echo "8. Detener módulo específico"
    echo "9. Limpiar módulo específico (Clean)"
    echo "10. Salir"
    echo -e "${CYAN}=============================================${NC}"
    
    read -p "Seleccione una opción: " choice

    case $choice in
        1) run_compose "up" "all" ;;
        2) run_compose "down" "all" ;;
        3) run_compose "restart" "all" ;;
        4) run_compose "logs" "all" ;;
        5) run_compose "build" "all" ;;
        6) run_compose "clean" "all" ;;
        7)
            read -p "Escriba el módulo (central, reportes, busqueda): " mod
            run_compose "up" "$mod"
            ;;
        8)
            read -p "Escriba el módulo (central, reportes, busqueda): " mod
            run_compose "down" "$mod"
            ;;
        9)
            read -p "Escriba el módulo (central, reportes, busqueda): " mod
            run_compose "clean" "$mod"
            ;;
        10) exit 0 ;;
        *) echo -e "${RED}Opción inválida.${NC}" ;;
    esac
else
    case $ACTION in
        start) cmd="up" ;;
        stop) cmd="down" ;;
        clean) cmd="clean" ;;
        restart) cmd="restart" ;;
        logs) cmd="logs" ;;
        build) cmd="build" ;;
        *)
            echo -e "${RED}Acción '$ACTION' no válida. Use: start, stop, clean, restart, logs, build.${NC}"
            exit 1
            ;;
    esac
    run_compose "$cmd" "$MODULE"
fi
