# Usa la imagen oficial de Odoo como base
FROM odoo:17.0-20250131

# Cambia al usuario root para instalar paquetes
USER root

# Elimina cualquier repositorio PostgreSQL adicional para evitar conflictos
RUN rm -f /etc/apt/sources.list.d/postgresql.list && \
  sed -i '/^deb .*postgresql/d' /etc/apt/sources.list

# Actualiza los repositorios
RUN apt-get update

# Instala las demás dependencias necesarias
RUN apt-get install -y --no-install-recommends \
  python3-pip \
  build-essential \
  libssl-dev \
  libffi-dev \
  python3-dev \
  swig \
  libxml2-dev \
  libxslt1-dev \
  zlib1g-dev \
  libjpeg-dev && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

# Copia el archivo de dependencias (requirements.txt) al contenedor
COPY addons/requirements.txt /tmp/requirements.txt

# Instala las dependencias de Python
RUN pip3 install --no-cache-dir -r /tmp/requirements.txt

# Elimina archivos temporales para mantener la imagen ligera
RUN rm -rf /tmp/requirements.txt

# Cambia de nuevo al usuario odoo
USER odoo

# Comando por defecto
CMD ["odoo"]