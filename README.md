# Sistema de Gestión de Restaurante

Este proyecto implementa un sistema de gestión de restaurantes que se conecta a una base de datos PostgreSQL para manejar operaciones diarias como reservaciones, control de inventario y gestión de clientes.

## Contenido del Proyecto

- **Directorio `sql/`**: Contiene los scripts para crear el esquema de la base de datos, funciones, triggers e insertar datos de ejemplo.
- **Directorio `python_app/`**: Aplicación Python con el sistema de gestión completo.

## Requisitos

- Python 3.7 o superior
- PostgreSQL (puede ser local, en contenedor o remoto)
- Paquetes listados en `python_app/requirements.txt`

## Instalación y Configuración

### 1. Preparar entorno Python

```bash
cd python_app
python -m venv venv
source venv/bin/activate  # En Windows: venv\Scripts\activate
pip install -r requirements.txt
```

### 2. Configurar base de datos

Antes de ejecutar la aplicación, debe tener PostgreSQL instalado y corriendo. Luego:

1. Cree una base de datos (por ejemplo, `coworkingdb`)
2. Ejecute los siguientes scripts SQL en orden:
   - `sql/esquema.sql` - Crea las tablas
   - `sql/funciones.sql` - Crea las funciones
   - `sql/triggers.sql` - Crea los triggers
   - `sql/inserts.sql` - Inserta datos de ejemplo

### 3. Configurar variables de entorno

Copie el archivo de ejemplo y edite según su configuración:

```bash
cp .env .env.local
```

Edite `.env.local` con los datos de conexión a su base de datos PostgreSQL:

```
DB_HOST=localhost
DB_NAME=nombre_de_su_base_de_datos
DB_USER=nombre_de_usuario
DB_PASSWORD=contraseña
DB_PORT=5432
```

## Uso

### 1. Activar entorno virtual

```bash
cd python_app
source venv/bin/activate  # En Windows: venv\Scripts\activate
```

### 2. Iniciar la aplicación

```bash
python main.py <nombre_de_usuario>
```

Por ejemplo:
```bash
python main.py "Laura Gómez"
```

El sistema pedirá la contraseña del usuario. Después de autenticarse, se mostrará el menú principal.

### 3. Funcionalidades del sistema

- **Gestionar Reservaciones**: Crear, buscar y cancelar reservaciones
- **Gestionar Inventario**: Buscar, agregar y actualizar productos en inventario
- **Ver Historial de Clientes**: Consultar historial de visitas de un cliente
- **Generar Reportes**: 
  - Top 10 platillos más vendidos
  - Top 10 clientes más frecuentes
  - Top 5 clientes con más reservas
  - Reporte mensual de inventario (bajo stock y productos por caducar)
  - Resumen de desempeño por sede
- **Cerrar Programa**: Genera automáticamente un reporte de cierre diario

## Reportes Disponibles

Todos los reportes se generan desde el menú de reportes:

1. **Top 10 Platillos Más Vendidos**
2. **Top 10 Clientes Más Frecuentes**
3. **Top 5 Clientes con Más Reservas**
4. **Reporte Mensual de Inventario** (alertas de bajo stock y productos por caducar)
5. **Resumen de Sucursales** (reservas y ventas por sede)

## Seguridad y Auditoría

- Sistema de autenticación con roles
- Registro automático de todas las operaciones en la tabla de bitácora
- Todos los datos sensibles se manejan de forma segura en la base de datos

## Estructura del Proyecto

```
workspace_cafe/
├── sql/
│   ├── esquema.sql      # Esquema de la base de datos
│   ├── funciones.sql    # Funciones PostgreSQL
│   ├── triggers.sql     # Triggers para auditoría
│   └── inserts.sql      # Datos de ejemplo
└── python_app/
    ├── main.py          # Punto de entrada del sistema
    ├── database.py      # Conexión y operaciones con base de datos
    ├── menu.py          # Sistema de menú principal
    ├── daily_closing.py # Generador de reporte de cierre diario
    ├── requirements.txt # Dependencias
    ├── .env             # Variables de entorno
    └── README.md        # Documentación
```

