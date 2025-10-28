#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import sys
import signal
import getpass
from menu import Menu
from database import DatabaseConnection
from daily_closing import DailyClosing


def disable_ctrl_c():
    """Disable Ctrl+C to force closing through menu option only."""
    signal.signal(signal.SIGINT, signal.SIG_IGN)


def authenticate_user(username):
    """
    Authenticate user with database.
    
    Args:
        username (str): Username provided as argument
        
    Returns:
        dict: User information if authentication successful, None otherwise
    """
    db = DatabaseConnection()
    
    try:
        # Get user ID based on username
        query = "SELECT id, nombre, puesto FROM personal WHERE nombre = %s;"
        user_data = db.fetch_one(query, (username,))
        
        if not user_data:
            print("Usuario no encontrado.")
            return None
        
        user_id, user_name, user_role = user_data
        
        # Prompt for password
        password = getpass.getpass("Ingrese contraseña: ")
        
        # Verify password using the database function
        query = "SELECT get_password(%s);"
        stored_password = db.fetch_one(query, (user_id,))
        
        if stored_password and stored_password[0] == password:
            # Set context variable for audit trail
            db.execute_query("SET app.current_personal_id = %s;", (user_id,))
            return {
                'id': user_id,
                'name': user_name,
                'role': user_role,
                'username': username
            }
        else:
            print("Contraseña incorrecta.")
            return None
            
    except Exception as e:
        print(f"Error de autenticación: {e}")
        return None
    finally:
        db.close()


def main():
    """Main function of the application."""
    if len(sys.argv) != 2:
        print("Uso: python main.py <nombre_usuario>")
        sys.exit(1)
    
    username = sys.argv[1]
    
    # Disable Ctrl+C
    disable_ctrl_c()
    
    print(f"Bienvenido, {username}!")
    
    # Authenticate user
    user_data = authenticate_user(username)
    
    if not user_data:
        print("Autenticación fallida.")
        sys.exit(1)
    
    print(f"¡Inicio de sesión exitoso! Rol: {user_data['role']}")
    
    # Initialize menu
    menu = Menu(user_data)
    
    # Run the main menu loop
    try:
        menu.run()
    except KeyboardInterrupt:
        print("\nOperación no permitida. Use la opción de menú para salir.")
        sys.exit(1)
    except Exception as e:
        print(f"Error inesperado: {e}")
        sys.exit(1)
    finally:
        # Generate daily closing report when exiting
        print("\nGenerando reporte de cierre diario...")
        daily_closing = DailyClosing(user_data)
        daily_closing.generate_report()
        print("¡Hasta luego!")


if __name__ == "__main__":
    main()