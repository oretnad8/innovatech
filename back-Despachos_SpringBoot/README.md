# 🚚 InnovaTech - Backend Despachos (Spring Boot)

Este directorio contiene el microservicio de **Gestión de Despachos** para la plataforma **InnovaTech**. Está desarrollado utilizando el framework de nivel empresarial **Spring Boot** en **Java 17**, ofreciendo una API REST segura, rápida y modular para administrar la distribución y entrega física de los productos.

---

## 🚀 Tecnologías Principales

- **Spring Boot 3.x** - Framework de desarrollo backend ágil y robusto.
- **Java 17 (OpenJDK)** - Versión de soporte a largo plazo (LTS) de Java con grandes optimizaciones de rendimiento.
- **Spring Data JPA & Hibernate** - Capa de persistencia y mapeo objeto-relacional (ORM).
- **MySQL Connector/J** - Driver de conexión nativa para bases de datos MySQL.
- **Spring Boot Validation (Jakarta)** - Validación integrada y declarativa de modelos de datos a nivel de controlador.
- **Maven** - Gestor de dependencias y automatizador del ciclo de vida del software.

---

## 📁 Estructura del Microservicio

```text
Springboot-API-REST-DESPACHO/
├── src/
│   ├── main/
│   │   ├── java/com/citt/
│   │   │   ├── controller/      # Capa de Presentación: Exposición de Endpoints REST
│   │   │   ├── exceptions/      # Manejador centralizado de Excepciones del negocio
│   │   │   ├── persistence/     # Capa de Datos (Entities JPA, Interfaces Repository, Services)
│   │   │   └── SpringbootApiRestDespachoApplication.java # Clase de Arranque Principal
│   │   └── resources/
│   │       └── application.properties # Parámetros de entorno y base de datos
│   └── test/                    # Pruebas unitarias y de integración
├── Dockerfile                   # Construcción Multi-Stage segura (Temurin JRE Alpine)
└── pom.xml                      # Archivo de dependencias y plugins Maven
```

---

## 📡 Endpoints Expuestos (Base Path: `/api/v1/despachos`)

El microservicio expone un controlador REST completo con operaciones CRUD para la entidad **Despacho**:

| Método HTTP | Endpoint | Descripción | Body Requerido (JSON) | Códigos HTTP |
| :--- | :--- | :--- | :--- | :--- |
| **GET** | `/api/v1/despachos` | Obtiene la lista completa de todos los despachos programados. | *Ninguno* | `200 OK` |
| **GET** | `/api/v1/despachos/{id}` | Obtiene los detalles de un despacho en específico. | *Ninguno* | `200 OK`, `404 Not Found` |
| **POST** | `/api/v1/despachos` | Registra un nuevo despacho vinculado a una venta. | Campos del modelo `Despacho` | `201 Created`, `400 Bad Request` |
| **PUT** | `/api/v1/despachos/{id}` | Actualiza información del despacho (ej. cambiar estado a "Entregado"). | Campos actualizados | `200 OK`, `404 Not Found` |
| **DELETE** | `/api/v1/despachos/{id}` | Cancela / elimina un despacho del sistema. | *Ninguno* | `204 No Content`, `404 Not Found` |

---

## 🐳 Contenerización Segura (Dockerfile)

Para garantizar la seguridad en producción y minimizar el tamaño de los contenedores expuestos, el `Dockerfile` de este servicio utiliza una **compilación multi-stage** y corre bajo un usuario sin privilegios root (`devopsuser`):

```dockerfile
# Stage 1: Build (Utiliza el JDK completo de Maven para compilar)
FROM maven:3.8.5-openjdk-17 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline
COPY src ./src
RUN mvn clean package -DskipTests

# Stage 2: Runtime (Entorno mínimo de ejecución JRE)
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
# Creación de usuario y grupo de seguridad de menor privilegio
RUN addgroup -S devopsgroup && adduser -S devopsuser -G devopsgroup
USER devopsuser
COPY --from=build /app/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
```

> [!IMPORTANT]
> El microservicio expone e interactúa de forma nativa en el puerto `8080`. En el archivo de orquestación de Docker Compose (`docker-compose-backends.yml`) se expone directamente en el puerto `8080` de la instancia EC2 para separar la lógica de ventas y despachos a nivel de puertos y facilitar la administración del tráfico de red.

---

## 🛠️ Ejecución Local con Maven

Si prefieres ejecutar el microservicio directamente desde tu sistema operativo local (requiere **JDK 17** y **Maven** instalados):

1. **Configurar la base de datos**:
   Asegúrate de tener un servidor MySQL corriendo localmente en el puerto `3306` con la base de datos `ventas_db` creada.

2. **Compilar el proyecto**:
   ```bash
   mvn clean install -DskipTests
   ```

3. **Arrancar el servidor Spring Boot**:
   ```bash
   mvn spring-boot:run
   ```
   *El microservicio de despachos estará activo en `http://localhost:8080`.*
