# Script de control para levantar, apagar o reiniciar los 3 módulos del sistema SIGD.
Param (
    [string]$Action = "menu",
    [string]$Module = "all"
)

# Función para verificar y crear la red sigd_network
function Ensure-Network {
    Write-Host "Verificando red Docker 'sigd_network'..." -ForegroundColor Cyan
    $network = docker network ls --filter name=sigd_network -q
    if (-not $network) {
        Write-Host "Creando red Docker 'sigd_network'..." -ForegroundColor Yellow
        docker network create sigd_network
    } else {
        Write-Host "La red 'sigd_network' ya existe." -ForegroundColor Green
    }
}

# Mapeo de archivos docker compose
$ComposeFiles = @{
    "central"  = "docker-compose.central.yml";
    "reportes" = "docker-compose.reportes.yml";
    "busqueda" = "docker-compose.busqueda.yml"
}

# Función para ejecutar docker compose
function Run-Compose {
    param(
        [string]$CmdAction,
        [string]$TargetModule
    )

    Ensure-Network

    $targets = @()
    if ($TargetModule -eq "all") {
        # Levantamos en orden: primero reportes y búsqueda (bases de datos), luego central
        if ($CmdAction -eq "up") {
            $targets = @("busqueda", "reportes", "central")
        } else {
            $targets = @("central", "reportes", "busqueda")
        }
    } else {
        if ($ComposeFiles.ContainsKey($TargetModule)) {
            $targets = @($TargetModule)
        } else {
            Write-Error "Módulo '$TargetModule' no válido. Use: all, central, reportes, busqueda."
            return
        }
    }

    foreach ($t in $targets) {
        $file = $ComposeFiles[$t]
        Write-Host "--------------------------------------------------------" -ForegroundColor DarkGray
        Write-Host "Ejecutando '$CmdAction' para el módulo: $t ($file)" -ForegroundColor Cyan
        Write-Host "--------------------------------------------------------" -ForegroundColor DarkGray

        if ($CmdAction -eq "up") {
            docker compose -f $file up -d --build
        } elseif ($CmdAction -eq "down") {
            docker compose -f $file down
        } elseif ($CmdAction -eq "clean") {
            docker compose -f $file down -v
        } elseif ($CmdAction -eq "restart") {
            docker compose -f $file restart
        } elseif ($CmdAction -eq "logs") {
            docker compose -f $file logs --tail=100 -f
        } elseif ($CmdAction -eq "build") {
            docker compose -f $file build --no-cache
        }
    }
}

# Menú interactivo si no se pasa parámetro
if ($Action -eq "menu") {
    Clear-Host
    Write-Host "=============================================" -ForegroundColor Cyan
    Write-Host "      SIGD EMPRESARIAL — DOCKER MANAGER      " -ForegroundColor Cyan
    Write-Host "=============================================" -ForegroundColor Cyan
    Write-Host "1. Iniciar todos los servicios (Start)"
    Write-Host "2. Detener todos los servicios (Stop)"
    Write-Host "3. Reiniciar todos los servicios (Restart)"
    Write-Host "4. Ver logs del sistema (Logs)"
    Write-Host "5. Reconstruir imágenes sin caché (Build)"
    Write-Host "6. Limpiar volúmenes / Reiniciar BD (Clean)"
    Write-Host "7. Iniciar módulo específico"
    Write-Host "8. Detener módulo específico"
    Write-Host "9. Limpiar módulo específico (Clean)"
    Write-Host "10. Salir"
    Write-Host "=============================================" -ForegroundColor Cyan
    
    $choice = Read-Host "Seleccione una opción"

    switch ($choice) {
        "1"  { Run-Compose "up" "all" }
        "2"  { Run-Compose "down" "all" }
        "3"  { Run-Compose "restart" "all" }
        "4"  { Run-Compose "logs" "all" }
        "5"  { Run-Compose "build" "all" }
        "6"  { Run-Compose "clean" "all" }
        "7"  {
            $mod = Read-Host "Escriba el módulo (central, reportes, busqueda)"
            Run-Compose "up" $mod
        }
        "8"  {
            $mod = Read-Host "Escriba el módulo (central, reportes, busqueda)"
            Run-Compose "down" $mod
        }
        "9"  {
            $mod = Read-Host "Escriba el módulo (central, reportes, busqueda)"
            Run-Compose "clean" $mod
        }
        "10" { Exit }
        default { Write-Host "Opción inválida." -ForegroundColor Red }
    }
} else {
    $cmd = ""
    if ($Action -eq "start") { $cmd = "up" }
    elseif ($Action -eq "stop") { $cmd = "down" }
    elseif ($Action -eq "clean") { $cmd = "clean" }
    elseif ($Action -eq "restart") { $cmd = "restart" }
    elseif ($Action -eq "logs") { $cmd = "logs" }
    elseif ($Action -eq "build") { $cmd = "build" }
    else {
        Write-Error "Acción '$Action' no válida. Use: start, stop, clean, restart, logs, build."
        Exit
    }

    Run-Compose $cmd $Module
}
