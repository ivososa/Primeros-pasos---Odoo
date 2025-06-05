#!/bin/bash

# =============================================
# SCRIPT DE BACKUP DE ODOO USANDO CURL
# =============================================
# Este script realiza un backup completo de una base de datos de Odoo
# utilizando la API HTTP de Odoo en lugar de acceder directamente a los contenedores.
# Incluye manejo de errores y logs.
# Consideración: Debe tener definidas correctamente las variables de entorno.
#
# Autor: Nicolás Moroni (CIDS, UTN)
# Fecha: 18/03/2025
# =============================================


# Obtener el directorio del script
SCRIPT_DIR="$(dirname "$(sudo find /home/ubuntu -type f -name "odoo_db_backup*.sh")")"
ENV_DIR="$(dirname "$(sudo find /home/ubuntu -type f -name ".env")")"
PARENT_DIR="$(echo $HOME)"

# Validaciones de directorios SCRIPT_DIR y ENV_DIR
if [ ! -d "$SCRIPT_DIR" ]; then
    echo "Error: El directorio del script no existe: $SCRIPT_DIR"
    exit 1
fi
if [ ! -d "$ENV_DIR" ]; then
    echo "Error: El directorio del archivo .env no existe: $ENV_DIR"
    exit 1
fi

# Definir carpeta y archivo de logs
LOG_DIR="$PARENT_DIR/logs"
mkdir -p "$LOG_DIR"  # Crear carpeta logs si no existe

DATE=$(date +"%Y_%m_%d_%H%M%S")
DATE_LOG=$(date +"%Y_%m_%d")
LOG_FILE="$LOG_DIR/db_backup_$DATE_LOG.log"  # Log diario
ENV_FILE="$ENV_DIR/.env"


# Verificar comando unzip
if ! command -v unzip &> /dev/null; then
    echo "El comando 'unzip' no está instalado. DEBE INSTALARLO.."
fi

# Verificar comando curl
if ! command -v curl &> /dev/null; then
    echo "El comando 'curl' no está instalado. DEBE INSTALARLO.."
fi

# Verificar comando tee
if ! command -v tee &> /dev/null; then
    echo "El comando 'tee' no está instalado. DEBE INSTALARLO.."
fi



# Función para escribir en el log
log() {
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] $1" | tee -a "$LOG_FILE"
}

log "==========================================="
log "Iniciando proceso de backup de Odoo"

# Cargar variables de entorno desde el archivo .env
if [ -f "$ENV_FILE" ]; then
    log "Cargando configuración desde $ENV_FILE"
    set -a
    export $(grep -v '^#' "$ENV_FILE" | xargs)
    set +a
else
    log "Error: Archivo .env no encontrado en $ENV_DIR"
    exit 1
fi

# Verificar que las variables necesarias estén definidas
REQUIRED_VARS=("DB_NAME" "ODOO_MASTER_PWD")
for var in "${REQUIRED_VARS[@]}"; do
    if [ -z "${!var}" ]; then
        log "Error: Variable $var no definida en el archivo .env"
        exit 1
    fi
done

# Configurar variables para el backup
BACKUP_DIR="$PARENT_DIR/db_backups"
TODAY_YEAR_MONTH=$(date -d "today" +"%Y_%m")
TODAY_DIR="$BACKUP_DIR/$TODAY_YEAR_MONTH"

ODOO_DB_NAME="$DB_NAME"
ODOO_MASTER_PWD="$ODOO_MASTER_PWD"  # La contraseña maestra de Odoo

# Usar el puerto de Odoo definido en el archivo .env o usar el valor por defecto
ODOO_PORT=${ODOO_PORT:-8069}
log "Puerto de Odoo configurado: $ODOO_PORT"

# Definir la URL de Odoo utilizando localhost y el puerto especificado
ODOO_URL="http://localhost:$ODOO_PORT/web/database/backup"
log "URL de Odoo para backup: $ODOO_URL"

# Crear el directorio de backups si no existe
if [ ! -d "$BACKUP_DIR" ]; then
    log "Creando directorio de backups: $BACKUP_PATH"
    mkdir -p "$BACKUP_DIR"
fi

# Crear directorio del mes actual si no existe
if [ ! -d "$TODAY_DIR" ]; then
    log "Creando directorio de backups para el mes: $TODAY_YEAR_MONTH"
    mkdir -p "$TODAY_DIR"
fi


# Generar nombre de archivo con fecha y hora
BACKUP_FILENAME="db_backup_${ODOO_DB_NAME}_${DATE}.zip"
BACKUP_PATH="$TODAY_DIR/$BACKUP_FILENAME"

log "Iniciando backup de la base de datos '$ODOO_DB_NAME'"
log "El archivo de backup será: $BACKUP_PATH"

# Ejecutar el backup con curl
log "Ejecutando solicitud de backup vía cURL..."
HTTP_RESPONSE=$(curl -s -w "%{http_code}" -X POST \
    -F "master_pwd=$ODOO_MASTER_PWD" \
    -F "name=$ODOO_DB_NAME" \
    -F "backup_format=zip" \
    -o "$BACKUP_PATH" \
    "$ODOO_URL")

HTTP_STATUS="${HTTP_RESPONSE}"

# Verificar si el backup fue exitoso
if [ "$HTTP_STATUS" = "200" ] && [ -f "$BACKUP_PATH" ]; then
    # Verificar tamaño del backup
    BACKUP_SIZE=$(stat -c%s "$BACKUP_PATH" 2>/dev/null || ls -l "$BACKUP_PATH" | awk '{print $5}')

    if [ -z "$BACKUP_SIZE" ] || [ "$BACKUP_SIZE" -lt 1000 ]; then
        log "Error: El archivo de backup parece estar vacío o ser demasiado pequeño ($BACKUP_SIZE bytes)"
        rm -f "$BACKUP_PATH"
        exit 1
    fi

    log "Backup completado exitosamente. Tamaño: $(du -h "$BACKUP_PATH" | cut -f1)"

    # Verificar contenido del ZIP
    if command -v unzip >/dev/null 2>&1; then
        log "Verificando contenido del archivo ZIP..."

        # Contar archivos en filestore
        FILESTORE_COUNT=$(unzip -l "$BACKUP_PATH" | grep 'filestore/' | wc -l)

        # Extraer solo dump.sql y manifest.json
        ZIP_CONTENTS=$(unzip -l "$BACKUP_PATH" | grep -E 'dump.sql|manifest.json')

        log "Contenido principal del backup:"
        log "$ZIP_CONTENTS"

        # Mostrar cantidad de archivos en filestore
        log "Cantidad de archivos en filestore: $FILESTORE_COUNT"

    else
        log "Comando unzip no disponible. Omitiendo verificación de contenido."
    fi
else
    log "Error: No se pudo realizar el backup. HTTP Status: $HTTP_STATUS"
    if [ -f "$BACKUP_PATH" ]; then
        rm -f "$BACKUP_PATH"
    fi
    exit 1
fi


# Mostrar lista de backups disponibles
log "Backups disponibles:"
ls -lh "$BACKUP_DIR" | grep "backup_${ODOO_DB_NAME}_" | tee -a "$LOG_FILE"

log "Proceso de backup completado exitosamente"

# Instrucciones para restaurar (para referencia)
cat << EOF >> "$LOG_FILE"

=====================================
INSTRUCCIONES PARA RESTAURAR MANUALMENTE:
Para restaurar este backup, use la interfaz web de Odoo:
1. Vaya a: http://localhost:$ODOO_PORT/web/database/manager
2. Seleccione "Restore Database"
3. Ingrese la contraseña maestra
4. Seleccione el archivo ZIP de backup
5. Ingrese el nombre para la base de datos restaurada
=====================================

EOF

exit 0