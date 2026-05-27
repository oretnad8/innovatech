# 💻 InnovaTech - Frontend Web Application

Este directorio contiene la capa de presentación (Frontend) de la plataforma **InnovaTech**. Se trata de una aplicación web moderna del tipo SPA (Single Page Application) construida con **React**, estructurada con **Vite** para desarrollo y empaquetado ultra-rápido, y estilizada con **Tailwind CSS**.

---

## 🚀 Tecnologías Principales

- **React 18.2** - Biblioteca declarativa para la construcción de interfaces de usuario.
- **Vite 5.2** - Herramienta de compilación moderna que reemplaza de forma eficiente a Create React App (CRA).
- **Tailwind CSS 3.4** - Framework CSS de utilidades para un diseño web premium y totalmente responsivo.
- **Axios 1.6** - Cliente HTTP basado en promesas para consumir los endpoints REST de Ventas y Despachos.
- **React Router Dom 6.24** - Motor de enrutamiento del lado del cliente.
- **React Hook Form 7.52** - Gestión optimizada de formularios y validación de campos sin re-renders innecesarios.
- **SweetAlert2 11.11** - Cuadros de diálogo y alertas modales estilizadas y animadas.

---

## 📁 Estructura del Proyecto

```text
front_despacho/
├── public/                 # Recursos estáticos (Imágenes, Iconos)
├── src/
│   ├── assets/             # Estilos globales y configuraciones de CSS
│   ├── components/         # Componentes reutilizables (Botones, Inputs, Modales)
│   ├── views/              # Vistas de la aplicación (Ventas, Despachos, Dashboard)
│   ├── App.jsx             # Punto de entrada de componentes y rutas
│   └── main.jsx            # Punto de renderizado en el DOM de React
├── .env                    # Configuración de IPs de endpoints locales
├── Dockerfile              # Dockerfile Multi-Stage (Node.js -> Nginx)
├── tailwind.config.js      # Configuración del framework Tailwind CSS
├── vite.config.js          # Configuración del empaquetador Vite
└── package.json            # Dependencias y scripts de ejecución
```

---

## 🔧 Configuración de Variables de Entorno

La aplicación requiere apuntar a las URLs de los dos microservicios backend. Esto se gestiona mediante el archivo `.env` en la raíz del directorio `front_despacho/`:

```env
VITE_API_VENTAS=http://IP_DE_TU_EC2_BACKEND:8081
VITE_API_DESPACHOS=http://IP_DE_TU_EC2_BACKEND:8080
```

> [!NOTE]
> Durante la compilación de producción en Docker, estas variables se inyectan dinámicamente como argumentos de construcción (`--build-arg`) definidos en el workflow de GitHub Actions, lo que garantiza independencia de código y seguridad.

---

## 🛠️ Scripts Disponibles

Para ejecutar la aplicación localmente de forma nativa (requiere **Node.js 18+** instalado):

1. **Instalar dependencias**:
   ```bash
   npm install
   ```

2. **Ejecutar servidor de desarrollo**:
   ```bash
   npm run dev
   ```
   *La aplicación estará disponible en `http://localhost:5173`.*

3. **Compilar para producción (Crear build estático)**:
   ```bash
   npm run build
   ```
   *Los archivos compilados y optimizados se guardarán en la carpeta `dist/`.*

4. **Visualizar el build de producción localmente**:
   ```bash
   npm run preview
   ```

---

## 🐳 Contenerización (Dockerfile Multi-Stage)

El despliegue en producción se realiza encapsulando la aplicación en una imagen Docker altamente optimizada de **dos fases**:

```dockerfile
# Fase 1: Compilación
FROM node:18-alpine AS build
WORKDIR /app
ARG VITE_API_VENTAS
ARG VITE_API_DESPACHOS
ENV VITE_API_VENTAS=$VITE_API_VENTAS
ENV VITE_API_DESPACHOS=$VITE_API_DESPACHOS
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Fase 2: Servidor Web Nginx
FROM nginx:stable-alpine
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

### Ventajas de este diseño:
- **Seguridad**: El entorno de desarrollo de Node.js y el código fuente completo no se incluyen en la imagen final de producción.
- **Eficiencia**: La imagen final solo contiene el servidor **Nginx** y los archivos web precompilados estáticos (`dist/`), reduciendo el tamaño a pocos Megabytes.
- **Portabilidad**: Se expone en el puerto estándar `80` para fácil acceso e integración detrás de balanceadores de carga o proxies reversos.
