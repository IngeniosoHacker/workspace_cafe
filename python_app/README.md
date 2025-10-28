# Sistema de Gestión de Restaurante

Este es un sistema de gestión de restaurantes desarrollado en Python que se conecta a una base de datos PostgreSQL para manejar operaciones diarias como reservaciones, control de inventario y gestión de clientes.

## Requisitos

- Python 3.7 o superior
- PostgreSQL
- Paquetes listados en `requirements.txt`

## Instalación

1. Clona o copia el proyecto
2. Crea un entorno virtual e instala las dependencias:
   ```bash
   python -m venv venv
   source venv/bin/activate  # En Windows: venv\Scripts\activate
   pip install -r requirements.txt
   ```
3. Configura las variables de entorno en el archivo `.env`:
   ```
   DB_HOST=172.17.0.2
   DB_NAME=coworkingdb
   DB_USER=admin
   DB_PASSWORD=secret
   DB_PORT=5432
   ```
   Nota: Los valores mostrados arriba son para el contenedor Docker existente.

## Uso

Para iniciar el sistema:
```bash
python main.py <nombre_de_usuario>
```

Por ejemplo:
```bash
python main.py admin
```

El sistema solicitará la contraseña del usuario. Después de autenticarse, se mostrará el menú principal con las siguientes opciones:

1. Gestionar Reservaciones
2. Gestionar Inventario
3. Ver Historial de Clientes
4. Generar Reportes
5. Cerrar Programa

## Características

- Autenticación de usuarios con verificación de contraseña en la base de datos
- Sistema de menú intuitivo en español
- Gestión completa de reservaciones
- Control de inventario con alertas
- Generación de reportes específicos:
  - Top 10 platillos más vendidos
  - Top 10 clientes más frecuentes
  - Top 5 clientes con más reservas
  - Reporte mensual de inventario
  - Resumen de sucursales
- Reporte de cierre diario automático
- Registro de auditoría de todas las operaciones

## Estructura del Proyecto

- `main.py`: Punto de entrada del sistema
- `database.py`: Conexión y operaciones con la base de datos
- `menu.py`: Sistema de menú principal
- `daily_closing.py`: Generador de reporte de cierre diario
- `.env`: Configuración de la base de datos
- `requirements.txt`: Dependencias del proyecto