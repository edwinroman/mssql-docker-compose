# SQL Server en Docker con Docker Compose

Este proyecto proporciona una configuración de `docker-compose` para levantar un contenedor de Microsoft SQL Server 2022, ideal para entornos de desarrollo.

La configuración está modularizada e incluye:
1.  Un servicio principal para la base de datos (`mssqldb`).
2.  Un servicio (`mssql-tools`) que espera a que la base de datos esté lista y luego ejecuta un script SQL para crear una base de datos y un usuario por defecto.
3.  Un servicio (`mssql-dacpac`) que despliega un archivo DACPAC para definir el esquema de la base de datos.

## Prerrequisitos

- [Docker](https://www.docker.com/get-started)
- [Docker Compose](https://docs.docker.com/compose/install/) (incluido con Docker Desktop)

## Cómo empezar

1.  **Clona este repositorio:**
    ```bash
    git clone <URL_DEL_REPOSITORIO>
    cd mssql-docker-compose
    ```

2.  **Configura tus variables de entorno:**
    Crea un archivo `.env` a partir del ejemplo `.env.example`.
    ```bash
    # En Windows (Command Prompt)
    copy .env.example .env

    # En Windows (PowerShell)
    cp .env.example .env

    # En Linux o macOS
    cp .env.example .env
    ```
    Abre el archivo `.env` y edita las variables. Como mínimo, debes establecer una contraseña segura para `MSSQL_SA_PASSWORD`.

    **Ejemplo de `.env`:**
    ```ini
    # Contraseña para el usuario 'sa' (System Administrator)
    MSSQL_SA_PASSWORD=TuContraseñaSegura123

    # Edición de SQL Server (Developer es gratuita para desarrollo)
    MSSQL_PID=Developer

    # Zona horaria para el contenedor
    MSSQL_TZ=America/Bogota

    # Usuario y base de datos a crear por el script de inicialización
    MSSQL_DB_USERNAME=user_dev
    MSSQL_DB_PASSWORD=Password_dev_123
    MSSQL_DB_DEFAULT=proyect_db
    ```

3.  **Inicia los servicios:**
    Usa `docker-compose` para iniciar los servicios en segundo plano (`-d`).
    ```bash
    docker-compose up -d
    ```
    Este comando orquestará el inicio de `mssqldb` y, una vez que esté saludable, ejecutará los servicios `mssql-tools` y `mssql-dacpac` para inicializar y configurar la base de datos.

## Conexión a la Base de Datos

Una vez que el contenedor `mssqldb` esté en funcionamiento, puedes conectarte a él:

-   **Servidor:** `localhost`
-   **Puerto:** `1433`
-   **Usuario:** `sa` o el `MSSQL_DB_USERNAME` que definiste.
-   **Contraseña:** La `MSSQL_SA_PASSWORD` o `MSSQL_DB_PASSWORD` que definiste.
-   **Base de datos:** `master`, `proyect_db` (creada por el script) o `dbApplication` (creada por el DACPAC).

Puedes usar cualquier cliente de base de datos como [Azure Data Studio](https://azure.microsoft.com/en-us/products/data-studio) o SQL Server Management Studio.

## Detalles de la Configuración

### `docker-compose.yaml`

-   **Servicio `mssqldb`**:
    -   Define el contenedor principal de SQL Server 2022.
    -   **`environment`**: Carga la configuración desde el archivo `.env`.
    -   **`ports`**: Mapea el puerto `1433` del contenedor a tu máquina.
    -   **`volumes`**: Utiliza **volúmenes nombrados** (`mssql_data`, `mssql_log`, `mssql_secrets`) para persistir los datos de forma segura, gestionados por Docker.
    -   **`healthcheck`**: Verifica que el servicio de SQL Server esté activo y listo para aceptar conexiones antes de que otros servicios dependan de él.
    -   **`networks`**: Usa una red dedicada (`development-network`) para aislar los servicios.

-   **Servicio `mssql-tools`**:
    -   Utiliza una imagen ligera con las herramientas de línea de comandos de SQL Server.
    -   **`depends_on`**: Su ejecución se retrasa hasta que el `healthcheck` de `mssqldb` sea exitoso, asegurando que la base de datos esté lista.
    -   **`command`**: Ejecuta el script `docker-db-init.sql` para crear la base de datos y el usuario definidos en las variables de entorno.
    -   **`restart: no`**: Este servicio es una tarea de un solo uso y no necesita reiniciarse.

-   **Servicio `mssql-dacpac`**:
    -   Usa la imagen del SDK de .NET para tener acceso a la herramienta `sqlpackage`.
    -   **`depends_on`**: También espera a que `mssqldb` esté saludable.
    -   **`command`**: Instala `sqlpackage` y lo utiliza para publicar el archivo `dbApplication.dacpac`, aplicando el esquema de base de datos en el servidor.
    -   **`restart: no`**: Es otra tarea de un solo uso.

## Buenas Prácticas Implementadas

-   **Modularidad**: Las responsabilidades están separadas en diferentes servicios (base de datos, inicialización, despliegue), lo que hace la configuración más limpia y mantenible.
-   **Configuración Desacoplada**: La configuración sensible (contraseñas) se gestiona a través de variables de entorno en un archivo `.env`, manteniendo el `docker-compose.yaml` limpio.
-   **Persistencia de Datos con Volúmenes Nombrados**: Se usan volúmenes gestionados por Docker, lo que previene la pérdida de datos y facilita las copias de seguridad y la migración.
-   **Inicialización Controlada**: El uso de `depends_on` con `condition: service_healthy` asegura un orden de inicio correcto y robusto, evitando errores de conexión.
-   **Tareas de un Solo Uso**: Los servicios de inicialización están configurados para no reiniciarse, ya que solo deben ejecutarse una vez.
-   **Redes Aisladas**: Se utiliza una red personalizada para mejorar la seguridad y la organización de los servicios.
