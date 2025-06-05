# Odoo - Encode

Odoo - Encode

## Desarrollo

Para la gestión de desarrollos, utilizaremos la estrategia de ramificación *Feature Branch Workflow*. Esto significa que, antes de comenzar con una nueva funcionalidad, se debe crear una rama específica siguiendo esta convención de nombres: */feature/<<nombre representativo de la funcionalidad>>*.

Para cada nuevo desarrollo se creará una rama independiente, que deberá eliminarse al finalizar el trabajo para evitar redundancias en el repositorio.


### Comandos útiles de docker

```
docker compose down --volumes --rmi all --remove-orphans
```

```
docker compose up --build -d --force-recreate
```


## Nomenclatura de mensajes

### Tag

Para el nombrado de los tags nos basaremos en el esquema **SemVer** (*Semantic Versioning*). Hasta la primera versión productiva se trabajará con 0.X.X.

- **Major (+1.0.0)**: Se incrementa al desplegar el sistema en el ambiente productivo. Se resetean las versiones *minor* y *patch* a cero.
- **Minor (X.+1.0)**: Se incrementa en cambios incompatibles o significativos (por ejemplo, al cambiar una Docker Image). Se resetean las versiones *patch* a cero.
- **Patch (X.X.+1)**: Se incrementa al corregir errores (bug fixes) o agregar nuevas funcionalidades (por ejemplo, al agregar un módulo nuevo).

### Commits

Se utilizará el siguiente formato para los mensajes de commit:

**`<tipo>: <descripción breve y específica del cambio>`**

**Tipos de Commit:**

1. **feat:** Indica la adición de una nueva funcionalidad o característica.
    - Ejemplo: `feat: agrega campo de búsqueda en el módulo de ventas`
2. **fix:** Se usa para corregir un error o bug.
    - Ejemplo: `fix: corrige error en la vista de contactos`
3. **refactor:** Señala una mejora en el código sin cambiar su funcionalidad.
    - Ejemplo: `refactor: optimiza función de cálculo de impuestos`
4. **perf:** Marca una mejora de rendimiento.
    - Ejemplo: `perf: mejora la carga de datos en el módulo de inventario`
5. **style:** Cambios de formato o estilo que no afectan el comportamiento del código.
    - Ejemplo: `style: ajusta formato de indentación en archivo de configuración`
6. **docs:** Cambios o mejoras en la documentación.
    - Ejemplo: `docs: actualiza el manual de usuario del módulo de compras`
7. **test:** Añade o modifica pruebas automáticas.
    - Ejemplo: `test: añade pruebas unitarias para la función de autenticación`

## Consideraciones de Instalación

Para poder levantar odoo con esta configuración te hace falta crear en local las carpetas "*odoo-db-data*", "*odoo-web-data*", el archivo "*.env*" y el archivo "*odoo.conf*" (este último dentro de la carpeta config/, el resto debe ir en la raiz del repositorio).
Importante: la carpeta "*odoo-web-data*" debe tener permisos de escritura (sudo chmod 777 odoo-web-data).

## Migración de datos

La migración de datos se realiza desde el excel: ...


## Estructura de repositorio

La siguiente estructura de directorios hace referencia a la ubicación de los diferentes artefactos en cada carpeta del repositorio. La ubicación de cada módulo en la carpeta *addons* es importante para el archivo de configuración de odoo, *odoo.conf*.

```
├── addons/
    ├── enterprise_addons/
    ├── third_party_addons/
    ├── utn_addons/
├── config/
    ├── odoo.conf
├── docs/
├── odoo-db-data/
├── odoo-web-data/
├── scripts/
    ├── odoo_db_backup.sh
├── .dockerignore
├── .env
├── .gitignore
├── docker-compose.yml
├── Dockerfile
├── README.md
```

Los módulos personalizados se encuentran en la carpeta *utn_addons*.

Los módulos de terceros (Odoo App Store) se encuentran en la carpeta *third_party_addons*.

```
addons_path = /usr/lib/python3/dist-packages/odoo/addons, 
        /mnt/extra-addons/, 
        /mnt/extra-addons/utn_addons, 
        /mnt/extra-addons/third_party_addons/,
        /mnt/extra-addons/enterprise_addons/,
```


## Variables de entorno (.env)

COMPOSE_PROJECT_NAME=       # Nombre referido al proyecto -> en este caso es "encode"
HOST=                       # Host del contenedor Odoo -> debe ir el nombre del contenedor de base de datos 
USER=                       # Usuario Odoo -> solemos usar "odoo"
PASSWORD=                   # Contraseña para el usuario Odoo
POSTGRES_PASSWORD=          # Contraseña para el usuario Postgres -> debe coincidir con PASSWORD
POSTGRES_DB=                # Base de datos postgres -> debe ir "postgres"
POSTGRES_USER=              # Usuario Postgres -> solemos usar "odoo" -> debe coincidir con la variable USER
ADDON_NAME=                 # Nombre del módulo a actualizar
DB_NAME=                    # Base de datos a actualizar
ODOO_PORT=                  # Puerto de Odoo mapeado en el host (fuera del contenedor)
POSTGRES_PORT=              # Puerto de PostgreSQL mapeado en el host (fuera del contenedor)
ODOO_CONTAINER_NAME=        # Nombre del contenedor de Odoo
DB_CONTAINER_NAME=          # Nombre del contenedor de PostgreSQL
ODOO_MASTER_PWD=            # Contraseña de administrador de Odoo (master password)
