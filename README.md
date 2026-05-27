# 🚀 InnovaTech - Plataforma Multi-Capa de Ventas y Despacho

¡Bienvenido al repositorio oficial de **InnovaTech**! Este proyecto consiste en un ecosistema empresarial altamente escalable, robusto y automatizado para la gestión de **Ventas y Despachos**. La solución implementa una **Arquitectura Multi-Capa (Multi-Tier Architecture)** desplegada de manera distribuida en Amazon Web Services (AWS) utilizando prácticas modernas de DevOps, tales como contenerización con **Docker**, orquestación con **Docker Compose** y despliegue continuo (CI/CD) mediante **GitHub Actions**.

---

## 🗺️ Arquitectura de la Solución (Multi-Tier AWS)

Para garantizar la alta disponibilidad, seguridad y el aislamiento de recursos, la infraestructura de **InnovaTech** está dividida en tres capas independientes (Tiers), cada una ejecutándose sobre su propia instancia virtual **AWS EC2**:

```mermaid
graph TD
    subgraph Capa_Cliente ["🌐 Capa de Presentación (Client Tier - EC2 Frontend)"]
        A[Nginx Web Server] -->|Servidor Estático| B[React + Vite + Tailwind]
    end

    subgraph Capa_Aplicacion ["⚙️ Capa de Lógica de Negocio (Application Tier - EC2 Backends)"]
        C[Spring Boot: API Ventas - Puerto 8081]
        D[Spring Boot: API Despachos - Puerto 8080]
    end

    subgraph Capa_Datos ["💾 Capa de Persistencia (Data Tier - EC2 Database)"]
        E[(MySQL 8.0 - Puerto 3306)]
    end

    %% Flujos de Comunicación
    Usuario([👤 Cliente / Navegador]) -->|HTTP Puerto 80| A
    B -->|REST Requests - Puerto 8081| C
    B -->|REST Requests - Puerto 8080| D
    C -->|JPA/JDBC - Puerto 3306| E
    D -->|JPA/JDBC - Puerto 3306| E

    %% Estilos de Nodos
    style A fill:#4F46E5,stroke:#312E81,stroke-width:2px,color:#FFF
    style B fill:#818CF8,stroke:#312E81,stroke-width:2px,color:#FFF
    style C fill:#10B981,stroke:#064E3B,stroke-width:2px,color:#FFF
    style D fill:#059669,stroke:#064E3B,stroke-width:2px,color:#FFF
    style E fill:#F59E0B,stroke:#78350F,stroke-width:2px,color:#FFF
```

### 🏢 Desglose de Capas

1. **Capa de Presentación (Frontend - `front_despacho`)**:
   - Compilada bajo **React** y **Vite** para máxima velocidad y optimización del DOM.
   - Diseñada estéticamente usando **Tailwind CSS** y notificaciones dinámicas mediante **SweetAlert2**.
   - Servida a producción a través de un servidor web ligero **Nginx** expuesto en el puerto `80`.
   
2. **Capa de Aplicación (Backends - APIs REST)**:
   - **Backend Ventas (`back-Ventas_SpringBoot`)**: Servicio Spring Boot expuesto en el puerto `8081` que administra transacciones comerciales.
   - **Backend Despachos (`back-Despachos_SpringBoot`)**: Servicio Spring Boot expuesto en el puerto `8080` que gestiona el estado y asignación de despachos físicos.
   - Ambos usan imágenes ultra-ligeras basadas en **eclipse-temurin Alpine Java 17** y corren bajo el principio de menor privilegio (`devopsuser`).

3. **Capa de Datos (Database - `db-ventas`)**:
   - Instancia aislada de **MySQL 8.0** accesible exclusivamente desde la capa de aplicación por temas de seguridad.
   - Persistencia de datos configurada a través de volúmenes de Docker para evitar la pérdida de información ante reinicios de contenedores.

---

## 📂 Estructura del Repositorio

El proyecto cuenta con una organización modular limpia, ideal para el despliegue individual de microservicios:

```text
 proyecto semestral/
 ├── .github/
 │   └── workflows/
 │       └── deploy.yml            # Pipeline CI/CD nativo de GitHub Actions
 ├── back-Despachos_SpringBoot/    # Microservicio de Gestión de Despachos
 │   ├── Springboot-API-REST-DESPACHO/
 │   │   ├── src/                  # Código fuente (Java, Controllers, Entities, JPA)
 │   │   ├── Dockerfile            # Construcción Multi-Stage en Maven + Temurin Alpine
 │   │   └── pom.xml               # Dependencias de Maven (Spring Boot Web, JPA, MySQL Connector)
 │   └── README.md                 # Documentación específica del Backend Despachos
 ├── back-Ventas_SpringBoot/       # Microservicio de Gestión de Ventas
 │   ├── Springboot-API-REST/
 │   │   ├── src/                  # Código fuente (Java, Controllers, Entities, JPA)
 │   │   ├── Dockerfile            # Construcción Multi-Stage en Maven + Temurin Alpine
 │   │   └── pom.xml               # Dependencias de Maven (Spring Boot Web, JPA, MySQL Connector)
 │   └── README.md                 # Documentación específica del Backend Ventas
 ├── front_despacho/               # Frontend de la aplicación (React + Vite)
 │   ├── src/                      # Código fuente (Vistas JSX, Axios, Componentes)
 │   ├── Dockerfile            # Dockerfile Multi-Stage (Node.js Build + Nginx Runtime)
 │   ├── .env                      # Variables de entorno locales (Endpoints del backend)
 │   └── README.md                 # Documentación específica del Frontend
 ├── docker-compose-backends.yml   # Orquestación de ambos backends en el servidor de Aplicación
 ├── docker-compose-db.yml         # Orquestación de la Base de Datos en el servidor de Persistencia
 ├── docker-compose-frontend.yml   # Orquestación del Frontend en el servidor web
 ├── actualizar_ip.bat             # Herramienta de automatización de IPs del codebase
 └── README.md                     # Documentación Global (Este Archivo)
```

---

## ⚙️ Automatización de Infraestructura: `actualizar_ip.bat`

Debido a que las instancias AWS EC2 a menudo cambian de dirección IP pública al detenerse e iniciarse (si no se usan IPs elásticas), el repositorio incluye una herramienta automatizada llamada `actualizar_ip.bat` en lenguaje Batch y PowerShell.

### ¿Qué hace este script?
1. Solicita de forma interactiva las nuevas IPs públicas para los tres servidores (Frontend, Backends y Base de Datos).
2. Actualiza automáticamente los archivos de configuración local:
   - Modifica el archivo `.env` del Frontend apuntando al nuevo host del Backend.
   - Actualiza de forma segura referencias IP estáticas en archivos `.jsx` del frontend.
   - Configura el string de conexión JDBC (`SPRING_DATASOURCE_URL`) en el archivo `docker-compose-backends.yml` apuntando a la IP correcta de la Base de Datos.
   - Actualiza los archivos `application.properties` correspondientes a Spring Boot.
3. Te recuerda cuáles **GitHub Secrets** debes configurar en tu repositorio para asegurar el éxito del pipeline.

> [!TIP]
> Cada vez que inicies o recrees tus instancias AWS EC2, ejecuta este script en tu máquina Windows para sincronizar todo el código al instante antes de hacer un push.

---

## 🛠️ Cómo Ejecutar el Proyecto Localmente

Para realizar pruebas locales completas de toda la arquitectura en tu máquina de desarrollo, Docker Compose es la mejor opción.

### Prerrequisitos
- Tener instalado **Docker** y **Docker Desktop** (en Windows/Mac).
- Tener instalado **Git**.

### Paso 1: Clonar el repositorio
```bash
git clone https://github.com/oretnad8/innovatech.git
cd "proyecto semestral"
```

### Paso 2: Levantar la Base de Datos
```bash
docker-compose -f docker-compose-db.yml up -d
```
*Esto iniciará MySQL 8.0 en el puerto `3306` con la base de datos `ventas_db` precargada.*

### Paso 3: Configurar variables locales
Asegúrate de que tu archivo `front_despacho/.env` apunte a tu host local:
```env
VITE_API_VENTAS=http://localhost:8081
VITE_API_DESPACHOS=http://localhost:8080
```

Y que tu archivo `docker-compose-backends.yml` apunte a `localhost` en la variable de base de datos (o la IP local de tu contenedor de Docker):
```yaml
SPRING_DATASOURCE_URL=jdbc:mysql://host.docker.internal:3306/ventas_db?allowPublicKeyRetrieval=true&useSSL=false
```

### Paso 4: Levantar los Backends
```bash
docker-compose -f docker-compose-backends.yml up -d
```
*Este comando compilará el código Java automáticamente (usando compilación multi-stage de Maven) y levantará los servidores en los puertos 8080 y 8081.*

### Paso 5: Levantar el Frontend
```bash
docker-compose -f docker-compose-frontend.yml up -d
```
*Esto compilará el bundle de producción de React + Vite, configurará Nginx y lo expondrá en el puerto `80` (accesible en `http://localhost`).*

---

## 🚀 Despliegue Continuo (CI/CD) con GitHub Actions

El repositorio cuenta con un pipeline de DevOps profesional configurado en `.github/workflows/deploy.yml` que automatiza la compilación, empaquetado, distribución de imágenes y despliegue remoto sin intervención manual.

### Diagrama del Flujo CI/CD
```text
[Push a la rama 'deploy']
           │
           ▼
┌──────────────────────────────────────┐
│ GitHub Actions Runner se activa      │
├──────────────────────────────────────┤
│ 1. Checkout del código de la rama.   │
│ 2. Login nativo en Docker Hub.       │
└──────────────────┬───────────────────┘
                   │
                   ▼
┌──────────────────────────────────────┐
│ Compilación y Empaquetado de Imágenes│
├──────────────────────────────────────┤
│ Compila:                             │
│  - Ventas Backend (Java 17)          │
│  - Despachos Backend (Java 17)       │
│  - Frontend (Inyectando variables de │
│    entorno dinámicas de AWS)          │
│ Sube las imágenes a Docker Hub.      │
└──────────────────┬───────────────────┘
                   │
                   ▼
┌──────────────────────────────────────┐
│ Despliegue en AWS EC2 (SSH Keys)     │
├──────────────────────────────────────┤
│ 1. Se conecta a EC2 Backends:        │
│    - Descarga docker-compose.yml     │
│    - Detiene y limpia contenedores   │
│    - Ejecuta "docker-compose up -d"  │
│                                      │
│ 2. Se conecta a EC2 Frontend:        │
│    - Descarga docker-compose.yml     │
│    - Levanta la nueva app web en Nginx│
└──────────────────────────────────────┘
```

### 🗝️ Secrets de GitHub requeridos

Para que el pipeline funcione correctamente, debes configurar los siguientes secretos en **Settings > Secrets and variables > Actions** de tu repositorio de GitHub:

| Secreto | Descripción | Ejemplo |
| :--- | :--- | :--- |
| `DOCKERHUB_USERNAME` | Tu nombre de usuario de Docker Hub para subir imágenes. | `oretnad8` |
| `DOCKERHUB_TOKEN` | Token de acceso (Personal Access Token) de tu cuenta de Docker Hub. | `dckr_pat_...` |
| `AWS_HOST_FRONT` | IP pública o DNS público de la instancia EC2 para el Frontend. | `44.215.72.96` |
| `AWS_HOST_BACK` | IP pública o DNS público de la instancia EC2 para los Backends. | `98.86.164.163` |
| `AWS_SSH_KEY` | Contenido completo de tu archivo private key `.pem` para acceso SSH a AWS. | `-----BEGIN RSA PRIVATE KEY-----...` |

---

## 📡 Endpoints de las APIs Disponibles

Una vez desplegados los backends, los servicios exponen las siguientes rutas principales:

### 🛍️ API de Ventas (Puerto `8081`)
- **GET** `/api/v1/ventas` - Obtiene la lista completa de todas las ventas del sistema.
- **GET** `/api/v1/ventas/{id}` - Obtiene los detalles de una venta en específico.
- **POST** `/api/v1/ventas` - Crea una nueva venta. Requiere JSON en el Body.
- **PUT** `/api/v1/ventas/{id}` - Actualiza una venta existente.
- **DELETE** `/api/v1/ventas/{id}` - Elimina una venta del sistema.

### 🚚 API de Despachos (Puerto `8080`)
- **GET** `/api/v1/despachos` - Devuelve la lista de despachos programados.
- **GET** `/api/v1/despachos/{id}` - Devuelve los detalles de un despacho en específico.
- **POST** `/api/v1/despachos` - Registra un despacho para una venta específica.
- **PUT** `/api/v1/despachos/{id}` - Actualiza el estado del despacho (ej. "En Camino", "Entregado").
- **DELETE** `/api/v1/despachos/{id}` - Cancela / elimina un despacho del sistema.

---

## 👥 Desarrolladores
- **Dante Rojas / oretnad8** - DevOps & Software Engineering

*Este proyecto es parte de la Evaluación 2 del Semestre Académico.*
