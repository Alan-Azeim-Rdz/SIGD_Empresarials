<div align="center">

# 📄 SIGD Empresarial

### Sistema Integral de Gestión Documental — Multi-Empresa

[![.NET](https://img.shields.io/badge/.NET_10-512BD4?style=for-the-badge&logo=dotnet&logoColor=white)](https://dotnet.microsoft.com/)
[![PHP](https://img.shields.io/badge/PHP_8.2-777BB4?style=for-the-badge&logo=php&logoColor=white)](https://www.php.net/)
[![Node.js](https://img.shields.io/badge/Node.js_20-339933?style=for-the-badge&logo=nodedotjs&logoColor=white)](https://nodejs.org/)
[![Docker](https://img.shields.io/badge/Docker_Compose-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://docs.docker.com/compose/)
[![TypeScript](https://img.shields.io/badge/TypeScript-3178C6?style=for-the-badge&logo=typescript&logoColor=white)](https://www.typescriptlang.org/)

**Proyecto universitario · Ingeniería en Informática**

[🔗 Repositorio](https://github.com/Alan-Azeim-Rdz/SIGD_Empresarials) · [📖 Módulo Central](src/ModuloCentral/Gestion%20de%20Documentos/README.md) · [🔍 Módulo Búsqueda](src/ModuloBusqueda/README.md)

</div>

---

## 📋 Descripción

**SIGD Empresarial** es una plataforma multi-tenant de gestión documental empresarial desarrollada con arquitectura de microservicios. Permite a múltiples organizaciones controlar el ciclo de vida completo de sus documentos: desde su creación como borrador hasta su publicación como normativa vigente, con flujos de revisión y aprobación, versionado automático, búsqueda full-text, generación de reportes y validación de registro por correo electrónico.

El sistema está compuesto por **tres módulos independientes** que se comunican entre sí a través de APIs REST y comparten estado mediante sus propias bases de datos especializadas, todos orquestados con **tres archivos Docker Compose separados** y un script de administración centralizado.

### Características principales

- 🏢 **Multi-Empresa (Multi-Tenant):** Cada empresa registrada opera de forma aislada con sus propios usuarios, departamentos, tipos de documento y flujos.
- ✉️ **Validación por Correo Electrónico:** Al registrar una nueva empresa, se envía un correo al administrador con un enlace de activación. La empresa permanece inactiva hasta que se valide.
- 🔢 **Versionado Automático:** Los documentos aprobados terminan en `.0` (ej. `1.0`, `2.0`). Los rechazados incrementan el decimal (ej. `0.1`, `0.2`, `1.1`).
- 📦 **Obsolescencia Automática:** Cuando un documento pasa de `1.0` a `2.0`, la versión anterior (`1.0`) se marca como obsoleta de forma automática.
- 🪞 **Tabla Espejo SQL Server ↔ PostgreSQL:** Los usuarios y departamentos del Módulo Central (SQL Server) se sincronizan automáticamente al Módulo de Reportes (PostgreSQL).
- 🔍 **Búsqueda Global Full-Text:** Los documentos se indexan en MongoDB para búsquedas instantáneas por título, código, contenido y metadatos.
- 📊 **Reportes y Dashboard:** Dashboard interactivo con métricas de documentos vigentes, descargas, y acuses de lectura.
- 🛡️ **Auditoría Completa:** Bitácora de accesos, registro de IP de usuario, y trazabilidad de cada acción sobre documentos.

---

## 🏗️ Diagrama de Arquitectura

```
┌─────────────────────────────────────────────────────────────────────┐
│                    DOCKER · sigd_network (bridge)                    │
│                                                                       │
│   ┌─────────────────────┐        ┌──────────────────────┐           │
│   │   🗄️ SQL Server 2022  │        │   🐘 PostgreSQL 16    │           │
│   │   Puerto 1434         │        │   Puerto 5433         │           │
│   │   BD: SIGD_Central    │        │   BD: Postgres_SIGD   │           │
│   │   (docker-compose.    │        │   (docker-compose.    │           │
│   │    central.yml)       │        │    reportes.yml)      │           │
│   └──────────┬────────────┘        └──────────┬───────────┘           │
│              │ EF Core                         │ PDO                   │
│   ┌──────────▼────────────┐        ┌──────────▼───────────┐           │
│   │  🏢 MÓDULO CENTRAL     │  API   │  📊 MÓDULO REPORTES   │           │
│   │  ASP.NET Core 10 C#   │◄──────►│  PHP 8.2 + Nginx     │           │
│   │  Puerto 5000           │  REST  │  Puerto 8000          │           │
│   └──────────┬────────────┘        └──────────────────────┘           │
│              │                                                         │
│              │ POST /indexar                                           │
│              │ GET  /buscar                                            │
│   ┌──────────▼────────────┐        ┌──────────────────────┐           │
│   │  🔍 MÓDULO BÚSQUEDA    │        │   🍃 MongoDB 7.0       │           │
│   │  Node.js + TypeScript │◄──────►│   Puerto 27017        │           │
│   │  Express 5 · Puerto 3000│       │   BD: sigd_busqueda   │           │
│   │  (docker-compose.      │       │   (docker-compose.    │           │
│   │   busqueda.yml)        │       │    busqueda.yml)      │           │
│   └───────────────────────┘        └──────────────────────┘           │
│                                                                       │
└─────────────────────────────────────────────────────────────────────┘

         ┌──────────────────────────────────────────┐
         │            🌐 USUARIO FINAL               │
         │  Central :5000 · Reportes :8000 · API :3000 │
         └──────────────────────────────────────────┘
```

### Flujo de integración entre módulos

| Origen | Destino | Endpoint | Propósito |
|--------|---------|----------|-----------|
| Módulo Central | Módulo Búsqueda | `POST /index` | Indexar documento al publicarlo |
| Módulo Central | Módulo Búsqueda | `GET /searhc?q=` | Búsqueda full-text desde la UI |
| Módulo Central | Módulo Reportes | `POST /api/sync.php?action=sincronizar_documento` | Sincronizar documentos vigentes |
| Módulo Central | Módulo Reportes | `POST /api/sync.php?action=sincronizar_usuario` | Sincronizar tabla espejo de usuarios |
| Módulo Central | Módulo Reportes | `POST /api/sync.php?action=sincronizar_departamento` | Sincronizar tabla espejo de departamentos |
| Módulo Central | Módulo Reportes | `POST /api/sync.php?action=sincronizar_tipo` | Sincronizar tipos de documento |

---

## 🛠️ Tecnologías Utilizadas

### Backend

| Módulo | Lenguaje | Framework | Base de Datos | ORM / Driver |
|--------|----------|-----------|---------------|--------------|
| Central | C# | ASP.NET Core 10.0 MVC | SQL Server 2022 | Entity Framework Core 10 |
| Reportes | PHP 8.2 | Nginx + PHP-FPM + PDO | PostgreSQL 16 | PDO (pdo_pgsql) |
| Búsqueda | TypeScript | Express 5.2 | MongoDB 7.0 | Mongoose 9 |

### Infraestructura y herramientas

| Categoría | Tecnología | Versión |
|-----------|-----------|---------|
| Contenedores | Docker + Docker Compose | v2 (plugin) |
| Orquestación | 3 archivos `docker-compose.*.yml` + script `start-sigd.ps1` | — |
| Envío de correo | SMTP (Gmail / Outlook) | `SmtpEmailService.cs` |
| Logging (Reportes) | Monolog | ^3.0 |
| Logging (Búsqueda) | Pino + Pino-Pretty | ^9.0 |
| Generación PDF | dompdf | ^3.1 |
| Documentación API | Swagger UI / OpenAPI 3 | — |
| Testing (Búsqueda) | Jest + ts-jest + Supertest | Jest 29 |
| Testing (Reportes) | PHPUnit | ^11.0 |

---

## ✅ Requisitos Previos

Antes de levantar el proyecto asegúrate de tener instalado:

| Herramienta | Versión mínima | Verificar con |
|-------------|----------------|---------------|
| **Docker Desktop** | 24.x | `docker --version` |
| **Docker Compose** | 2.x (plugin) | `docker compose version` |
| **Git** | 2.x | `git --version` |
| **PowerShell** (Windows) | 5.1+ | `$PSVersionTable.PSVersion` |

> **Nota:** No necesitas instalar .NET, PHP ni Node.js localmente. Todo corre dentro de contenedores Docker.

### Recursos mínimos de sistema

- 🐏 **RAM:** 4 GB disponibles (recomendado 8 GB)
- 💾 **Disco:** ~5 GB libres (imágenes Docker + datos)
- 🖥️ **OS:** Windows 10/11, macOS 12+, Ubuntu 20.04+

---

## 🚀 Instalación y Puesta en Marcha

### Paso 1 — Clonar el repositorio

```bash
git clone https://github.com/Alan-Azeim-Rdz/SIGD_Empresarials.git
cd SIGD_Empresarials
```

### Paso 2 — Configurar variables de entorno

Crea un archivo `.env` en la raíz del proyecto con el siguiente contenido (modifica las contraseñas a tu gusto):

```dotenv
# ── SQL Server (Módulo Central) ──────────────────────────────
SQL_DATABASE=SIGD_Central
SQL_SA_PASSWORD=TuPasswordSeguro123!
APP_DB_USER=sa
APP_DB_PASSWORD=TuPasswordSeguro123!

# ── PostgreSQL (Módulo Reportes) ─────────────────────────────
PG_USER=Super_Admin
PG_PASSWORD=TuPasswordPostgres!
PG_DATABASE=Postgres_SIGD

# ── MongoDB (Módulo Búsqueda) ────────────────────────────────
MONGO_USERNAME=Super_Admin
MONGO_PASSWORD=TuPasswordMongo!

# ── API Key compartida entre módulos ─────────────────────────
SYNC_API_KEY=sigd_sync_secret_2026
```

> ⚠️ **Nunca** subas el archivo `.env` real al repositorio. Ya está en `.gitignore`.

### Paso 3 — Configurar el servicio SMTP (Correo electrónico)

Para que la validación de correo funcione al registrar nuevas empresas, debes configurar las credenciales SMTP en el archivo:

```
src/ModuloCentral/Gestion de Documentos/Gestion de Documentos/appsettings.json
```

Busca la sección `"Smtp"` y edítala con tus datos reales:

```json
"Smtp": {
    "Host": "smtp.gmail.com",
    "Port": 587,
    "Username": "tu_correo@gmail.com",
    "Password": "tu_contraseña_de_aplicacion",
    "From": "tu_correo@gmail.com"
}
```

> ⚠️ **Si usas Gmail:** No uses tu contraseña normal. Debes generar una **Contraseña de Aplicación**:
> 1. Ve a [myaccount.google.com](https://myaccount.google.com/) → Seguridad.
> 2. Activa la **Verificación en dos pasos** si no la tienes.
> 3. Busca **Contraseñas de aplicaciones** y genera una nueva.
> 4. Copia la contraseña de 16 letras y pégala en el campo `"Password"`.

> 💡 **Si usas Outlook/Hotmail:** Cambia el Host a `smtp-mail.outlook.com`.

### Paso 4 — Levantar el sistema

El proyecto incluye un **script de administración** que simplifica todas las operaciones Docker. Funciona tanto en Windows (PowerShell) como en Linux/macOS (Bash).

#### Opción A: Menú interactivo (recomendado para primera vez)

```powershell
# Windows (PowerShell)
.\start-sigd.ps1

# Linux / macOS
chmod +x start-sigd.sh
./start-sigd.sh
```

Se mostrará un menú con opciones numeradas. Elige **1. Iniciar todos los servicios (Start)**.

#### Opción B: Comando directo

```powershell
# Windows
.\start-sigd.ps1 start

# Linux / macOS
./start-sigd.sh start
```

La primera vez puede tardar **5–10 minutos** mientras Docker descarga las imágenes base y compila los módulos. Las ejecuciones posteriores son mucho más rápidas.

El script se encarga automáticamente de:
1. ✅ Crear la red Docker `sigd_network` si no existe.
2. ✅ Levantar primero las bases de datos (Búsqueda y Reportes) y luego el Módulo Central.
3. ✅ Construir las imágenes con `--build` en cada inicio.
4. ✅ Ejecutar los scripts de inicialización de cada base de datos (tablas, seed data).

### 🐧 Despliegue en Servidor Linux (Ubuntu/Debian)

Si estás desplegando en un servidor Linux (como Ubuntu Server 20.04/22.04/24.04 LTS), sigue estos pasos para preparar el entorno e instalar el sistema:

#### 1. Instalar dependencias del sistema (Git y Curl)
```bash
sudo apt update
sudo apt install -y git curl
```

#### 2. Instalar Docker y Docker Compose (Plugin)
Recomendamos instalar Docker desde el repositorio oficial mediante su script de conveniencia:
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
```

Verifica que Docker y el plugin Compose estén instalados correctamente:
```bash
docker --version
docker compose version
```

#### 3. Configurar Permisos de Docker (Opcional pero Recomendado)
To be able to run Docker commands without using `sudo`:
```bash
sudo usermod -aG docker $USER
```
> ⚠️ **Importante:** Para que este cambio tenga efecto, cierra la sesión SSH y vuelve a conectarte, o ejecuta `newgrp docker`.

#### 4. Clonar el Repositorio y Configurar el .env
Clona el repositorio utilizando la URL correcta:
```bash
git clone https://github.com/Alan-Azeim-Rdz/SIGD_Empresarials.git
cd SIGD_Empresarials
```
Sigue el **Paso 2** de la guía general para crear y configurar tu archivo `.env`.

#### 5. Configurar el Cortafuegos (UFW)
Asegúrate de permitir el tráfico en los puertos que utiliza el sistema:
```bash
# Permitir acceso al Módulo Central (.NET MVC)
sudo ufw allow 5000/tcp
# Permitir acceso al Módulo de Reportes (PHP/Nginx)
sudo ufw allow 8000/tcp
# Permitir acceso a la API de Búsqueda (Node.js) - Opcional
sudo ufw allow 3000/tcp
```

#### 6. Levantar el Sistema en Segundo Plano (Detached)
El script de administración ya está diseñado para ejecutar los contenedores en segundo plano (`-d`):
```bash
chmod +x start-sigd.sh
./start-sigd.sh start
```
Puedes monitorear el progreso levantando los logs:
```bash
./start-sigd.sh logs
```

### Paso 5 — Verificar que todos los servicios estén activos

```bash
docker ps
```

Deberías ver **7 contenedores** con estado `Up`:

```
CONTAINER ID   IMAGE                          STATUS          PORTS                    NAMES
xxxxxxxxxxxx   sigd-central-modulo_central    Up              0.0.0.0:5000->8080/tcp   app_central_dotnet
xxxxxxxxxxxx   mcr.microsoft.com/mssql/...    Up (healthy)    0.0.0.0:1434->1433/tcp   sigd_sqlserver
xxxxxxxxxxxx   nginx:1.26.0-alpine            Up              0.0.0.0:8000->80/tcp     app_reportes_nginx
xxxxxxxxxxxx   sigd-reportes-php_reportes     Up              9000/tcp                 app_reportes_php
xxxxxxxxxxxx   postgres:16.3-alpine           Up              0.0.0.0:5433->5432/tcp   sigd_postgres
xxxxxxxxxxxx   sigd-busqueda-modulo_busqueda  Up              0.0.0.0:3000->3000/tcp   app_busqueda_node
xxxxxxxxxxxx   mongo:7.0.9                    Up              0.0.0.0:27017->27017/tcp  sigd_mongodb
```

### Paso 6 — Acceder al sistema

Una vez levantado, abre tu navegador:

| Módulo | URL | Descripción |
|--------|-----|-------------|
| 🏢 Central (principal) | http://localhost:5000 | Panel de administración y gestión documental |
| 📊 Reportes / Portal | http://localhost:8000 | Dashboard de reportes y portal de operarios |
| 🔍 Búsqueda (API) | http://localhost:3000 | API REST de búsqueda full-text |
| 📖 Swagger UI | http://localhost:3000/docs | Documentación interactiva de la API de búsqueda |

---

## 🔑 Credenciales Iniciales (Datos de Demostración)

> Estas credenciales son para el entorno de desarrollo y demos. Los scripts de seed crean automáticamente una empresa de demostración con usuarios de prueba.

| Campo | Valor |
|-------|-------|
| **URL de acceso** | http://localhost:5000/Auth/Login |
| **Correo** | `admin@sigd.local` |
| **Contraseña** | `Admin@SIGD2026!` |
| **Rol** | Super Administrador |

### Usuarios de demostración adicionales

El seed genera 8 usuarios de prueba con distintos roles:

| Correo | Contraseña | Rol |
|--------|-----------|-----|
| `admin@demo.local` | `Admin@SIGD2026!` | Administrador |
| `jlopez@demo.local` | `Contra@1234` | Superior |
| `mgarcia@demo.local` | `Contra@1234` | Superior |
| `crojas@demo.local` | `Contra@1234` | Usuario |
| `aherrera@demo.local` | `Contra@1234` | Usuario |
| `lmendez@demo.local` | `Contra@1234` | Usuario |
| `ptorres@demo.local` | `Contra@1234` | Usuario |
| `rnavarro@demo.local` | `Contra@1234` | Usuario |

El administrador tiene acceso completo para:
- ✅ Crear y gestionar usuarios, roles y permisos
- ✅ Configurar departamentos y tipos de documento
- ✅ Gestionar el flujo de aprobación de documentos
- ✅ Ver bitácoras de acceso y auditoría
- ✅ Registrar nuevas empresas

---

## 🏢 Registro de Nuevas Empresas

SIGD Empresarial es multi-tenant. Cualquier persona puede registrar una nueva empresa desde la pantalla de Login.

### Flujo de registro

```
Pantalla de Login           Formulario de              Correo de               Validación
    │                       Registro Empresa           Validación              exitosa
    │  Clic en              ────────────────           ──────────              ──────────
    │  "Regístrate aquí"    Nombre empresa             Se envía un email       El admin hace
    ├─────────────────────► RFC                        al correo del     ────► clic en el enlace
    │                       Correo admin          ───► administrador           del correo
    │                       Contraseña admin           con un enlace           │
    │                       etc.                       de activación           ▼
    │                                                                    ┌─────────────┐
    │                                                                    │ ✅ Empresa    │
    │◄───────────────────────────────────────────────────────────────────│    activada   │
    │  Ahora puede iniciar sesión                                       └─────────────┘
```

### Seguridad del registro

1. **La empresa se crea con `Estatus = false`** (inactiva) hasta que se valide el correo.
2. **No se puede iniciar sesión** con una empresa no validada. El sistema muestra un mensaje de error claro.
3. **El token de validación es único** (GUID) y se invalida automáticamente después de su primer uso.
4. **Se crea automáticamente:** Un departamento "Administración" y un usuario con rol "Administrador" para la nueva empresa.

---

## 🔢 Sistema de Versionado de Documentos

El versionado sigue reglas específicas basadas en el flujo de aprobación:

| Escenario | Versión resultante | Ejemplo |
|-----------|-------------------|---------|
| Primer documento sin historial, aprobado | `1.0` | — |
| Primer documento, rechazado 1 vez | `0.1` | — |
| Primer documento, rechazado 3 veces | `0.3` | — |
| Documento con 2 versiones aprobadas, rechazado 2 veces | `2.2` | Existían `1.0` y `2.0`, se rechazó dos veces |
| Documento rechazado y luego aprobado | `X.0` | El decimal se resetea a `.0` al aprobar |

### Obsolescencia automática

Cuando un documento alcanza una nueva versión vigente (ej. pasa de `1.0` a `2.0`), la versión anterior (`1.0`) se marca automáticamente como **Obsoleta**. Esto es un proceso automático del sistema, no una acción manual del usuario.

---

## 📁 Estructura del Repositorio

```
SIGD_Empresarials/
│
├── 📄 docker-compose.central.yml   # Módulo Central + SQL Server
├── 📄 docker-compose.reportes.yml  # Módulo Reportes + PostgreSQL + Nginx
├── 📄 docker-compose.busqueda.yml  # Módulo Búsqueda + MongoDB
├── 📄 .env                         # Variables de entorno (NO se sube al repo)
├── 📄 .gitignore
├── 📄 start-sigd.ps1               # Script de administración Docker (Windows)
├── 📄 start-sigd.sh                # Script de administración Docker (Linux/macOS)
│
├── 📂 src/
│   │
│   ├── 📂 ModuloCentral/           # ASP.NET Core 10 · C# MVC
│   │   └── Gestion de Documentos/
│   │       ├── Controllers/        # Auth, Admin, Documento, Flujo, Búsqueda,
│   │       │                       # SuperAdmin, Modulos, Home
│   │       ├── Models/             # EF Entities + DbContext (DirContext)
│   │       ├── Views/              # Razor Views (.cshtml)
│   │       ├── Services/           # ReportesIntegration, BusquedaIntegration,
│   │       │                       # MongoGridFs, SmtpEmail
│   │       ├── Program.cs          # DI, autenticación, HttpClients
│   │       ├── appsettings.json    # Config DB, SMTP, módulos externos
│   │       └── Dockerfile          # Multi-stage: restore → build → publish
│   │
│   ├── 📂 ModuloReportes/          # PHP 8.2 + Nginx
│   │   ├── api/                    # sync.php (endpoint de sincronización)
│   │   ├── config/                 # Database.php · Logger.php
│   │   ├── controllers/            # Dashboard, Reporte, Sync
│   │   ├── models/                 # Acuse.php
│   │   ├── views/                  # dashboard.php · portal_operario.php
│   │   ├── nginx/                  # default.conf (Nginx reverse-proxy a PHP-FPM)
│   │   ├── tests/                  # PHPUnit tests
│   │   ├── composer.json           # dompdf · monolog · phpunit
│   │   ├── index.php               # Punto de entrada
│   │   └── Dockerfile              # php:8.2-fpm + pdo_pgsql + composer
│   │
│   └── 📂 ModuloBusqueda/          # Node.js 20 · TypeScript · Express 5
│       ├── __tests__/              # 35 tests · cobertura de líneas
│       ├── index.ts                # App Express + modelo Mongoose + endpoints
│       ├── server.ts               # Punto de entrada
│       ├── package.json            # express · mongoose · pino · swagger
│       ├── tsconfig.json
│       ├── jest.config.ts
│       └── Dockerfile              # Multi-stage: dev (ts-node-dev) → builder → prod
│
├── 📂 scripts/
│   ├── sqlserver/
│   │   ├── entrypoint.sh           # Arranca SQL Server y espera al init
│   │   ├── wait-and-init.sh        # Espera a que SQL esté listo y ejecuta init + seed
│   │   ├── init_Central.sql        # Creación de tablas, empresa, soporte multi-tenant
│   │   └── seed.sql                # Datos de demostración (usuarios, documentos, etc.)
│   ├── postgres/
│   │   ├── init_Reportes.sql       # Tablas espejo: departamento, usuario, documento_vigente, etc.
│   │   └── seed_demo.sql           # Datos espejo de demostración
│   └── mongo/
│       ├── init_busqueda.js        # Índices y colección de documentos
│       └── seed_demo.js            # Documentos indexados de demostración
│
└── 📂 db/                          # Scripts SQL complementarios
```

---

## 🐳 Script de Administración (`start-sigd`)

El proyecto incluye un script que simplifica la gestión de Docker. Disponible en PowerShell (`.ps1`) y Bash (`.sh`).

### Menú interactivo

```powershell
.\start-sigd.ps1       # Windows
./start-sigd.sh        # Linux/macOS
```

```
=============================================
      SIGD EMPRESARIAL — DOCKER MANAGER
=============================================
1. Iniciar todos los servicios (Start)
2. Detener todos los servicios (Stop)
3. Reiniciar todos los servicios (Restart)
4. Ver logs del sistema (Logs)
5. Reconstruir imágenes sin caché (Build)
6. Limpiar volúmenes / Reiniciar BD (Clean)
7. Iniciar módulo específico
8. Detener módulo específico
9. Limpiar módulo específico (Clean)
10. Salir
=============================================
```

### Comandos directos

```powershell
# Iniciar todo (construye imágenes + levanta contenedores)
.\start-sigd.ps1 start

# Detener todo (conserva datos en volúmenes)
.\start-sigd.ps1 stop

# Reiniciar servicios
.\start-sigd.ps1 restart

# Reconstruir imágenes sin caché
.\start-sigd.ps1 build

# Ver logs en tiempo real
.\start-sigd.ps1 logs

# ⚠️ LIMPIAR TODO (destruye volúmenes = borra bases de datos)
.\start-sigd.ps1 clean
```

### Gestionar un módulo individual

```powershell
# Solo levantar el módulo central
.\start-sigd.ps1 start central

# Solo limpiar la base de datos de reportes (PostgreSQL)
.\start-sigd.ps1 clean reportes

# Módulos disponibles: central, reportes, busqueda
```

> **⚠️ Diferencia importante entre `stop` y `clean`:**
> - `stop` (`docker compose down`): Elimina contenedores pero **conserva los datos** de las bases de datos en los volúmenes Docker.
> - `clean` (`docker compose down -v`): Elimina contenedores **y los volúmenes**, lo que **borra todas las bases de datos**. Al volver a iniciar, se ejecutarán los scripts de inicialización desde cero.

---

## 🔄 Sincronización de Datos (Tabla Espejo)

El Módulo Central (SQL Server) es la fuente de verdad para los datos de usuarios, departamentos y tipos de documento. El Módulo de Reportes (PostgreSQL) mantiene una **tabla espejo** que se sincroniza automáticamente mediante llamadas API REST.

### ¿Cuándo se sincroniza?

| Acción en Módulo Central | Se sincroniza a PostgreSQL |
|--------------------------|---------------------------|
| Crear usuario | ✅ Automático |
| Editar usuario | ✅ Automático |
| Eliminar usuario (soft delete) | ✅ Automático |
| Reactivar usuario | ✅ Automático |
| Crear departamento | ✅ Automático |
| Aprobar/publicar documento | ✅ Automático |
| Validar empresa por correo | ✅ Automático |

### Datos sincronizados por tabla

| Tabla SQL Server | Tabla PostgreSQL | Campos clave |
|-----------------|------------------|--------------|
| `Empresa` → | `(implícito via id_empresa)` | ID, Nombre |
| `Departamento` → | `departamento` | ID, Nombre, Abreviatura, IdEmpresa |
| `Usuario` → | `usuario` | ID, Nombre, Apellido, Correo, IdEmpresa |
| `TipoDocumento` → | `tipo_documento` | ID, Nombre, Abreviatura, IdEmpresa |
| `Documento` → | `documento_vigente` | ID, Código, Título, Versión, Ruta |

---

## 🔄 Flujo de un Documento

El ciclo de vida completo de un documento en SIGD sigue estos estados:

```
  ┌──────────┐     Enviar a      ┌──────────────┐     Aprobar     ┌──────────┐
  │          │    revisión       │              │  ─────────────► │          │
  │ BORRADOR │ ──────────────► │   REVISIÓN   │                  │ APROBADO │
  │  (Draft) │                  │  (In Review) │  ◄───────────── │          │
  └──────────┘                  └──────────────┘   Solicitar      └────┬─────┘
       ▲                               │             cambios           │
       │                               │ Rechazar                      │ Publicar
       │                               ▼                               │
       │                         ┌──────────┐                         ▼
       └─────────────────────────│ RECHAZADO│              ┌──────────────────┐
              Editar y           └──────────┘              │    VIGENTE       │
              reenviar                                      │  (Normativa      │
                                                           │   publicada)     │
                                                           └────────┬─────────┘
                                                                    │
                                                           Nueva versión
                                                                    │
                                                                    ▼
                                                           ┌──────────────────┐
                                                           │    OBSOLETO      │
                                                           │  (Automático al  │
                                                           │   publicar nueva │
                                                           │   versión)       │
                                                           └──────────────────┘
```

### Descripción de estados

| Estado | Descripción | Quién puede actuar |
|--------|-------------|-------------------|
| 📝 **Borrador** | Documento en creación/edición | Autor del documento |
| 🔎 **Revisión** | Enviado para revisión técnica | Revisor asignado |
| ✅ **Aprobado** | Revisado y listo para publicar | Aprobador / Admin |
| 🚫 **Rechazado** | Devuelto con observaciones (versión decimal incrementa) | — (vuelve al autor) |
| 📢 **Vigente** | Publicado como normativa activa (versión termina en `.0`) | Admin (para publicar) |
| 📦 **Obsoleto** | Reemplazado automáticamente por una versión más nueva | Sistema automático |

> Cuando un documento pasa a **Vigente**, el Módulo Central notifica automáticamente al Módulo de Búsqueda (`POST /index`) para indexarlo y hacerlo buscable, y al Módulo de Reportes (`POST /api/sync.php`) para actualizar las tablas espejo.

---

## 🌐 URLs de Acceso por Módulo

### 🏢 Módulo Central — `http://localhost:5000`

| Ruta | Descripción |
|------|-------------|
| `/Auth/Login` | Inicio de sesión |
| `/Auth/RegistroEmpresa` | Registro público de nuevas empresas |
| `/Auth/ValidarRegistro?token=xxx` | Validación de correo electrónico |
| `/Home` | Dashboard principal |
| `/Admin` | Panel de administración (usuarios, departamentos, tipos doc.) |
| `/Auth/Registro` | Crear usuario dentro de tu empresa (requiere rol Admin) |
| `/Auth/Usuarios` | Gestión de usuarios de la empresa |
| `/Documento` | Gestión de documentos |
| `/Flujo/Pendientes` | Flujos de aprobación pendientes |
| `/Busqueda/Global` | Búsqueda global de documentos (integrada con MongoDB) |
| `/Modulos/Dashboard` | Dashboard de reportes (proxy al Módulo Reportes) |
| `/Modulos/Portal` | Portal de normativas (proxy al Módulo Reportes) |
| `/SuperAdmin` | Consola de Super Administrador (gestión de empresas) |

### 📊 Módulo Reportes — `http://localhost:8000`

| Ruta | Descripción |
|------|-------------|
| `/` | Dashboard de reportes y estadísticas |
| `/portal` | Portal público de operarios |
| `/api/v1/dashboard` | API JSON de métricas del dashboard |
| `/api/v1/portal` | API JSON del portal de operarios |
| `/api/sync.php` | Endpoint de sincronización (llamado por .NET) |

### 🔍 Módulo Búsqueda — `http://localhost:3000`

| Ruta | Método | Descripción |
|------|--------|-------------|
| `/search?q={texto}` | `GET` | Búsqueda full-text (máx. 100 caracteres) |
| `/index` | `POST` | Indexar un nuevo documento |
| `/documento/:id` | `GET` | Obtener metadatos por ID o código |
| `/docs` | `GET` | Swagger UI interactivo |
| `/docs.json` | `GET` | Especificación OpenAPI 3.0 |

---

## 🐳 Comandos Docker Útiles (Sin script)

Si prefieres usar Docker Compose directamente en lugar del script:

### Gestión por módulo

```bash
# Levantar el Módulo Central + SQL Server
docker compose -f docker-compose.central.yml up -d --build

# Levantar el Módulo de Reportes + PostgreSQL + Nginx
docker compose -f docker-compose.reportes.yml up -d --build

# Levantar el Módulo de Búsqueda + MongoDB
docker compose -f docker-compose.busqueda.yml up -d --build
```

> ⚠️ **Orden de levantamiento importante:** Primero `busqueda`, luego `reportes`, y finalmente `central` (ya que el central depende de que los otros módulos estén en la red).

### Detener y limpiar

```bash
# Detener (conserva datos)
docker compose -f docker-compose.central.yml down
docker compose -f docker-compose.reportes.yml down
docker compose -f docker-compose.busqueda.yml down

# Detener y destruir volúmenes (borra bases de datos) ⚠️
docker compose -f docker-compose.central.yml down -v
docker compose -f docker-compose.reportes.yml down -v
docker compose -f docker-compose.busqueda.yml down -v
```

### Monitoreo y logs

```bash
# Ver logs del módulo central
docker logs app_central_dotnet --tail=100

# Ver logs de SQL Server
docker logs sigd_sqlserver --tail=100

# Ver logs de PHP (Reportes)
docker logs app_reportes_php --tail=100

# Ver logs de Node.js (Búsqueda)
docker logs app_busqueda_node --tail=100
```

### Acceder a consolas de bases de datos

```bash
# Consola SQL Server
docker exec -it sigd_sqlserver /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "TuPasswordSeguro123!" -C

# Consola PostgreSQL
docker exec -it sigd_postgres psql -U Super_Admin -d Postgres_SIGD

# Consola MongoDB
docker exec -it sigd_mongodb mongosh -u Super_Admin -p TuPasswordMongo! --authenticationDatabase admin
```

### Ejecutar tests

```bash
# Tests del Módulo Búsqueda (Jest)
docker exec -it app_busqueda_node npm test

# Tests del Módulo Reportes (PHPUnit)
docker exec -it app_reportes_php ./vendor/bin/phpunit tests/
```

---

## ❓ Solución de Problemas Comunes

### "La empresa no ha sido validada"
- **Causa:** Registraste una empresa pero no has hecho clic en el enlace de validación enviado a tu correo.
- **Solución:** Revisa tu bandeja de entrada (y la carpeta de spam) buscando un correo de "SIGD Empresarial". Haz clic en el enlace "Validar mi cuenta".

### "No me llega el correo de validación"
- **Causa:** Las credenciales SMTP en `appsettings.json` no son correctas.
- **Solución:** Verifica que estés usando una Contraseña de Aplicación si tu proveedor es Gmail. Revisa los logs con `docker logs app_central_dotnet --tail=50` para ver el error exacto.

### Los datos de prueba no aparecen después de reiniciar
- **Causa:** Los scripts `init_*.sql` y `seed_demo.*` solo se ejecutan cuando Docker crea el volumen por primera vez. Si ya existían datos, no se sobrescriben.
- **Solución:** Usa el comando `clean` para destruir los volúmenes y volver a empezar:
  ```powershell
  .\start-sigd.ps1 clean
  .\start-sigd.ps1 start
  ```

### Los usuarios/departamentos no aparecen en el Módulo de Reportes
- **Causa:** La sincronización API entre módulos falló (posiblemente el módulo de reportes no estaba levantado cuando se creó el usuario).
- **Solución:** Verifica que todos los módulos estén corriendo con `docker ps`. Si el problema persiste, haz un `clean` y vuelve a levantar para que los seeds regeneren todo.

### Error de conexión a SQL Server
- **Causa:** SQL Server puede tardar 20-30 segundos en estar listo después de iniciar. El módulo central espera un healthcheck pero en hardware lento puede no ser suficiente.
- **Solución:** Reinicia solo el módulo central: `.\start-sigd.ps1 restart central` o `docker compose -f docker-compose.central.yml restart modulo_central`.

---

## 🎓 Información Académica

| Campo | Detalle |
|-------|---------|
| **Materia** | Proyecto Final de Ingeniería en Informática |
| **Tipo** | Sistema web empresarial con arquitectura de microservicios |
| **Repositorio** | [github.com/Alan-Azeim-Rdz/SIGD_Empresarials](https://github.com/Alan-Azeim-Rdz/SIGD_Empresarials) |
| **Rama principal** | `main` |

### Objetivos del proyecto

- ✅ Implementar arquitectura de microservicios con tres módulos independientes
- ✅ Integrar tres motores de base de datos distintos (SQL Server, PostgreSQL, MongoDB)
- ✅ Implementar flujo de gestión documental completo con roles y permisos
- ✅ Implementar soporte multi-empresa (multi-tenant) con aislamiento de datos
- ✅ Validación de registro por correo electrónico vía SMTP
- ✅ Versionado automático de documentos con lógica de aprobado/rechazado
- ✅ Obsolescencia automática de versiones anteriores
- ✅ Sincronización de tablas espejo entre SQL Server y PostgreSQL
- ✅ Lograr comunicación REST entre servicios con API Keys
- ✅ Containerizar la aplicación completa con Docker Compose (3 archivos independientes)
- ✅ Implementar búsqueda full-text sobre documentos indexados en MongoDB
- ✅ Generar reportes en PDF con dompdf
- ✅ Script de administración multiplataforma (PowerShell + Bash)
- ✅ Cobertura de tests unitarios en módulos de búsqueda y reportes

---

<div align="center">

**SIGD Empresarial** · v2.0.1 · © 2026

</div>
