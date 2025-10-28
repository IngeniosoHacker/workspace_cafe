#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from database import DatabaseConnection
import sys
import os
from datetime import datetime


class Menu:
    """Main menu system for the restaurant management application."""
    
    def __init__(self, user_data):
        """
        Initialize the menu.
        
        Args:
            user_data (dict): User information
        """
        self.user_data = user_data
        self.db = DatabaseConnection()
    
    def display_menu(self):
        """Display the main menu options."""
        print("="*50)
        print("SISTEMA DE GESTIÓN DE RESTAURANTE")
        print("="*50)
        print(f"Usuario: {self.user_data['name']} | Rol: {self.user_data['role']}")
        print("="*50)
        print("1. Gestionar Reservaciones")
        print("2. Gestionar Inventario")
        print("3. Registrar Nuevo Cliente")
        print("4. Registrar Pedido")
        print("5. Ver Historial de Clientes")
        print("6. Generar Reportes")
        print("7. Ver Bitácora de Cambios")
        print("8. Cerrar Programa")
        print("="*50)
    
    def get_menu_choice(self):
        """
        Get and validate user menu choice.
        
        Returns:
            int: User's menu choice (1-8)
        """
        while True:
            try:
                choice = int(input("Seleccione una opción (1-8): "))
                if 1 <= choice <= 8:
                    return choice
                else:
                    print("Opción inválida. Por favor seleccione un número entre 1 y 8.")
            except ValueError:
                print("Entrada inválida. Por favor ingrese un número.")

    @staticmethod
    def clear_console():
        """Clear the terminal screen in a cross-platform way."""
        os.system("cls" if os.name == "nt" else "clear")

    @staticmethod
    def pause():
        """Wait for user confirmation before continuing."""
        input("\nPresione Enter para continuar...")

    def _safe_rollback(self):
        """Rollback current transaction, ignoring errors if none active."""
        try:
            self.db.connection.rollback()
        except Exception:
            pass

    def register_new_client(self):
        """Register a new client using the database function."""
        self.clear_console()
        print("\n--- REGISTRO DE NUEVO CLIENTE ---")

        try:
            name = input("Nombre completo: ").strip()
            if not name:
                print("El nombre es obligatorio.")
                return

            phone_raw = input("Teléfono (solo números): ").strip()
            if not phone_raw or not phone_raw.isdigit():
                print("El teléfono debe contener solo números.")
                return
            phone = int(phone_raw)

            favorite_raw = input("ID de platillo favorito (opcional): ").strip()
            favorite_id = int(favorite_raw) if favorite_raw else None

            print("\nTipos de suscripción disponibles: Básica, Silver, Gold")
            subscription_input = input("Tipo de suscripción (default Básica): ").strip()
            if not subscription_input:
                subscription = 'Básica'
            else:
                normalized = subscription_input.lower()
                subscription_map = {
                    'basica': 'Básica',
                    'básica': 'Básica',
                    'silver': 'Silver',
                    'gold': 'Gold'
                }
                subscription = subscription_map.get(normalized)
                if not subscription:
                    print("Suscripción inválida. Debe ser Básica, Silver o Gold.")
                    return

            query = "SELECT agregar_cliente(%s, %s, %s, %s);"
            result = self.db.fetch_one(query, (name, phone, favorite_id, subscription))

            if result and result[0]:
                self.db.connection.commit()
                print(f"Cliente registrado correctamente con ID: {result[0]}")
            else:
                self._safe_rollback()
                print("No se pudo registrar al cliente.")

        except ValueError:
            self._safe_rollback()
            print("Datos inválidos. Por favor verifique la información ingresada.")
        except Exception as e:
            self._safe_rollback()
            print(f"Error al registrar cliente: {e}")
        finally:
            self.pause()

    def register_order(self):
        """Register a new order for a reservation."""
        self.clear_console()
        print("\n--- REGISTRO DE PEDIDO ---")

        try:
            reservation_input = input("ID de la reservación: ").strip()
            menu_input = input("ID del platillo del menú: ").strip()

            reservation_id = int(reservation_input)
            menu_id = int(menu_input)

            result = self.db.fetch_one("SELECT realizar_pedido(%s, %s);", (reservation_id, menu_id))

            if result is not None:
                self.db.connection.commit()
                print("Pedido registrado correctamente.")
            else:
                self._safe_rollback()
                print("No se pudo registrar el pedido.")

        except ValueError:
            self._safe_rollback()
            print("Los identificadores deben ser números enteros.")
        except Exception as e:
            self._safe_rollback()
            print(f"Error al registrar el pedido: {e}")
        finally:
            self.pause()
    
    def handle_reservation_management(self):
        """Handle reservation management operations."""
        while True:
            self.clear_console()
            print("\n--- GESTIÓN DE RESERVACIONES ---")
            print("1. Crear nueva reservación")
            print("2. Buscar reservaciones")
            print("3. Cancelar reservación")
            print("4. Volver al menú principal")
            
            try:
                choice = int(input("Seleccione una opción (1-4): "))
                
                if choice == 1:
                    self.create_reservation()
                    self.pause()
                elif choice == 2:
                    self.search_reservations()
                    self.pause()
                elif choice == 3:
                    self.cancel_reservation()
                    self.pause()
                elif choice == 4:
                    break
                else:
                    print("Opción inválida.")
                    self.pause()
            except ValueError:
                print("Entrada inválida. Por favor ingrese un número.")
                self.pause()
    
    def create_reservation(self):
        """Create a new reservation."""
        self.clear_console()
        print("\n--- CREAR NUEVA RESERVACIÓN ---")
        
        try:
            # Get client information
            client_name = input("Nombre del cliente: ")
            client_phone = input("Teléfono del cliente: ")
            
            # Verify client exists
            query = "SELECT id FROM cliente WHERE nombre = %s AND telefono = %s;"
            client_data = self.db.fetch_one(query, (client_name, int(client_phone)))
            
            if not client_data:
                print("Cliente no encontrado. Debe registrarse primero.")
                return
            
            client_id = client_data[0]
            
            # Get reservation details
            date_time = input("Fecha y hora (YYYY-MM-DD HH:MM): ")
            num_people = int(input("Número de personas: "))
            observations = input("Observaciones (opcional): ") or None
            
            # Get available spaces
            query = """
            SELECT e.id, e.tipo, e.precio 
            FROM espacio e 
            WHERE NOT EXISTS (
                SELECT 1 
                FROM reserva r 
                WHERE r.espacio_fk = e.id 
                AND DATE(r.horaFecha) = DATE(%s)
                AND COALESCE(r.status, 'Activa') <> 'Cancelada'
            );
            """
            available_spaces = self.db.fetch_all(query, (date_time,))
            
            if not available_spaces:
                print("No hay espacios disponibles para la fecha y hora seleccionada.")
                return
            
            print("\nEspacios disponibles:")
            for space in available_spaces:
                print(f"ID: {space['id']}, Tipo: {space['tipo']}, Precio: {space['precio']}")
            
            space_id = int(input("ID del espacio a reservar: "))
            
            # Verify space exists and is available
            space_exists = any(s['id'] == space_id for s in available_spaces)
            if not space_exists:
                print("Espacio no disponible o inválido.")
                return
            
            # Get sede ID based on space
            query = "SELECT sede_id FROM espacio WHERE id = %s;"
            result = self.db.fetch_one(query, (space_id,))
            if not result:
                print("Error al obtener la sede del espacio.")
                return
            sede_id = result[0]
            
            # Create reservation
            query = """
            INSERT INTO reserva (horaFecha, numPersonas, espacio_fk, sede_fk, cliente_fk, personal_fk, observaciones)
            VALUES (%s, %s, %s, %s, %s, %s, %s) RETURNING id;
            """
            result = self.db.fetch_one(
                query, 
                (date_time, num_people, space_id, sede_id, client_id, self.user_data['id'], observations)
            )
            
            if result:
                print(f"¡Reservación creada exitosamente! ID: {result[0]}")
            else:
                print("Error al crear la reservación.")
                
        except Exception as e:
            print(f"Error al crear la reservación: {e}")
    
    def search_reservations(self):
        """Search for reservations using the database function."""
        self.clear_console()
        print("\n--- BUSCAR RESERVACIONES ---")
        print("Deje en blanco para omitir el filtro:")
        
        try:
            reserva_id = input("ID de la reservación (opcional): ")
            reserva_id = int(reserva_id) if reserva_id else None
            
            hora_fecha = input("Fecha y hora (YYYY-MM-DD HH:MM, opcional): ") or None
            if not hora_fecha:
                hora_fecha = None
            
            cliente_id = input("ID del cliente (opcional): ")
            cliente_id = int(cliente_id) if cliente_id else None
            
            personal_id = input("ID del personal (opcional): ")
            personal_id = int(personal_id) if personal_id else None
            
            # Call the database function to search reservations
            query = "SELECT * FROM buscar_reservas(%s, %s, %s, %s);"
            reservations = self.db.fetch_all(query, (reserva_id, hora_fecha, cliente_id, personal_id))
            
            if reservations:
                print("\nResultados de la búsqueda:")
                print("{:<5} {:<20} {:<5} {:<12} {:<10} {:<10} {:<10} {:<10} {:<30}".format(
                    "ID", "Fecha/Hora", "Pers", "Estado", "Espacio", "Sede", "Cliente", "Personal", "Observaciones"
                ))
                print("-" * 130)
                
                for res in reservations:
                    print("{:<5} {:<20} {:<5} {:<12} {:<10} {:<10} {:<10} {:<10} {:<30}".format(
                        res['id'],
                        str(res['horafecha'])[:16] if res['horafecha'] else '',
                        res['numpersonas'],
                        res['status'] or 'N/A',
                        res['espacio_fk'],
                        res['sede_fk'],
                        res['cliente_fk'],
                        res['personal_fk'],
                        res['observaciones'] or 'N/A'
                    ))
            else:
                print("No se encontraron reservaciones con los criterios especificados.")
                
        except Exception as e:
            print(f"Error al buscar reservaciones: {e}")
    
    def cancel_reservation(self):
        """Cancel a reservation."""
        self.clear_console()
        print("\n--- CANCELAR RESERVACIÓN ---")
        
        try:
            reserva_id = int(input("ID de la reservación a cancelar: "))
            
            # Check if reservation exists and belongs to the user
            query = "SELECT id, status FROM reserva WHERE id = %s AND personal_fk = %s;"
            reservation = self.db.fetch_one(query, (reserva_id, self.user_data['id']))
            
            if not reservation:
                print("No se encontró la reservación o no tiene permisos para cancelarla.")
                return
            
            if reservation[1] == 'Cancelada':
                print("La reservación ya está cancelada.")
                return
            
            # Update reservation status to 'Cancelada'
            query = "UPDATE reserva SET status = 'Cancelada' WHERE id = %s;"
            success = self.db.execute_query(query, (reserva_id,))
            
            if success:
                print(f"Reservación {reserva_id} cancelada exitosamente.")
            else:
                print("Error al cancelar la reservación.")
                
        except Exception as e:
            print(f"Error al cancelar la reservación: {e}")
    
    def handle_inventory_management(self):
        """Handle inventory management operations."""
        while True:
            self.clear_console()
            print("\n--- GESTIÓN DE INVENTARIO ---")
            print("1. Buscar inventario")
            print("2. Agregar producto al inventario")
            print("3. Actualizar existencia")
            print("4. Volver al menú principal")
            
            try:
                choice = int(input("Seleccione una opción (1-4): "))
                
                if choice == 1:
                    self.search_inventory()
                    self.pause()
                elif choice == 2:
                    self.add_inventory_item()
                    self.pause()
                elif choice == 3:
                    self.update_inventory()
                    self.pause()
                elif choice == 4:
                    break
                else:
                    print("Opción inválida.")
                    self.pause()
            except ValueError:
                print("Entrada inválida. Por favor ingrese un número.")
                self.pause()
    
    def search_inventory(self):
        """Search inventory using the database function."""
        self.clear_console()
        print("\n--- BUSCAR INVENTARIO ---")
        
        try:
            sede_id = int(input("ID de la sede: "))
            producto = input("Nombre del producto (opcional): ") or None
            
            if producto:
                producto = f"%{producto}%"
            
            # Call the database function to search inventory
            query = "SELECT * FROM s_inventario(%s, %s);"
            inventory_items = self.db.fetch_all(query, (sede_id, producto))
            
            if inventory_items:
                print("\nResultados de la búsqueda:")
                print("{:<5} {:<25} {:<10} {:<10} {:<12} {:<5}".format(
                    "ID", "Producto", "Existencia", "Unidad", "Caducidad", "Sede"
                ))
                print("-" * 75)
                
                for item in inventory_items:
                    print("{:<5} {:<25} {:<10} {:<10} {:<12} {:<5}".format(
                        item['inventario_id'],
                        item['producto'],
                        item['existencia'],
                        item['unidad'],
                        str(item['caducidad']) if item['caducidad'] else 'N/A',
                        item['sede_id']
                    ))
            else:
                print("No se encontraron productos con los criterios especificados.")
                
        except Exception as e:
            print(f"Error al buscar inventario: {e}")
    
    def add_inventory_item(self):
        """Add a new item to inventory."""
        self.clear_console()
        print("\n--- AGREGAR PRODUCTO AL INVENTARIO ---")
        
        try:
            sede_id = int(input("ID de la sede: "))
            producto = input("Nombre del producto: ")
            existencia = int(input("Cantidad existente: "))
            unidad = input("Unidad de medida (kg, pieza, taza, etc.): ")
            caducidad = input("Fecha de caducidad (YYYY-MM-DD): ")
            
            query = """
            INSERT INTO inventario (producto, existencia, unidad, caducidad, sede_id)
            VALUES (%s, %s, %s, %s, %s);
            """
            success = self.db.execute_query(
                query, 
                (producto, existencia, unidad, caducidad, sede_id)
            )
            
            if success:
                print("Producto agregado exitosamente al inventario.")
            else:
                print("Error al agregar producto al inventario.")
                
        except Exception as e:
            print(f"Error al agregar producto al inventario: {e}")
    
    def update_inventory(self):
        """Update inventory quantities."""
        self.clear_console()
        print("\n--- ACTUALIZAR EXISTENCIA ---")
        
        try:
            sede_id = int(input("ID de la sede: "))
            producto = input("Nombre exacto del producto: ")
            
            # Get current inventory for the product
            query = """
            SELECT id, producto, existencia, unidad, caducidad 
            FROM inventario 
            WHERE producto = %s AND sede_id = %s;
            """
            inventory_item = self.db.fetch_one(query, (producto, sede_id))
            
            if not inventory_item:
                print("Producto no encontrado en el inventario de esta sede.")
                return
            
            inv_id, prod_name, current_exist, unidad, caducidad = inventory_item
            print(f"Producto actual: {prod_name}, Existencia actual: {current_exist} {unidad}")
            
            new_existence = int(input("Nueva cantidad existente: "))
            
            # Update the inventory
            query = "UPDATE inventario SET existencia = %s WHERE id = %s;"
            success = self.db.execute_query(query, (new_existence, inv_id))
            
            if success:
                print("Inventario actualizado exitosamente.")
            else:
                print("Error al actualizar el inventario.")
                
        except Exception as e:
            print(f"Error al actualizar el inventario: {e}")
    
    def handle_customer_history(self):
        """Handle customer history operations."""
        self.clear_console()
        print("\n--- HISTORIAL DE CLIENTES ---")
        
        try:
            client_id = int(input("ID del cliente: "))
            
            # Get customer history using the database function
            query = "SELECT * FROM historial_cliente(%s);"
            history = self.db.fetch_all(query, (client_id,))
            
            if history:
                print(f"\nHistorial para el cliente ID: {client_id}")
                print("{:<5} {:<20} {:<15} {:<20} {:<8} {:<12} {:<3} {:<15} {:<12} {:<30}".format(
                    "ID", "Nombre", "Reserva ID", "Fecha/Hora", "Pers", "Estado", "S", "Dirección", "Espacio", "Observaciones"
                ))
                print("-" * 140)
                
                for record in history:
                    print("{:<5} {:<20} {:<15} {:<20} {:<8} {:<12} {:<3} {:<15} {:<12} {:<30}".format(
                        record['cliente_id'],
                        record['cliente_nombre'][:19],
                        record['reserva_id'],
                        str(record['horafecha'])[:16] if record['horafecha'] else '',
                        record['numpersonas'],
                        record['status'] or 'N/A',
                        record['sede_id'],
                        record['sede_direccion'][:14] if record['sede_direccion'] else '',
                        record['espacio_id'],
                        record['observaciones'] or 'N/A'
                    ))
                
                # Show additional info
                first_record = history[0]
                if first_record['platillo_favorito']:
                    print(f"\nPlatillo favorito: {first_record['platillo_favorito']}")
                
                if first_record['platillos_consumidos']:
                    print(f"Platillos consumidos: {first_record['platillos_consumidos']}")
            else:
                print("No se encontró historial para este cliente.")
                
        except Exception as e:
            print(f"Error al obtener historial de cliente: {e}")
        finally:
            self.pause()
    
    def handle_reports(self):
        """Handle report generation operations."""
        while True:
            self.clear_console()
            print("\n--- GENERAR REPORTES ---")
            print("1. Top 10 platillos más vendidos")
            print("2. Top 10 clientes más frecuentes")
            print("3. Top 5 clientes con más reservas")
            print("4. Reporte mensual de inventario")
            print("5. Resumen de sucursales")
            print("6. Volver al menú principal")
            
            try:
                choice = int(input("Seleccione una opción (1-6): "))
                
                if choice == 1:
                    self.top_menu_items()
                    self.pause()
                elif choice == 2:
                    self.top_customers()
                    self.pause()
                elif choice == 3:
                    self.top_reservation_customers()
                    self.pause()
                elif choice == 4:
                    self.monthly_inventory_report()
                    self.pause()
                elif choice == 5:
                    self.branch_summary()
                    self.pause()
                elif choice == 6:
                    break
                else:
                    print("Opción inválida.")
                    self.pause()
            except ValueError:
                print("Entrada inválida. Por favor ingrese un número.")
                self.pause()
    
    def top_menu_items(self):
        """Show top 10 most sold menu items."""
        self.clear_console()
        print("\n--- TOP 10 PLATILLOS MÁS VENDIDOS ---")
        
        try:
            query = "SELECT * FROM top_menu();"
            results = self.db.fetch_all(query)
            
            if results:
                print("{:<5} {:<40} {:<15}".format("ID", "Descripción", "Vendidos"))
                print("-" * 60)
                
                for item in results:
                    print("{:<5} {:<40} {:<15}".format(
                        item['menu_id'],
                        item['descripcion'][:39],
                        item['total_vendidos']
                    ))
            else:
                print("No hay datos disponibles para este reporte.")
                
        except Exception as e:
            print(f"Error al generar el reporte: {e}")
    
    def top_customers(self):
        """Show top 10 most frequent customers."""
        self.clear_console()
        print("\n--- TOP 10 CLIENTES MÁS FRECUENTES ---")
        
        try:
            query = "SELECT * FROM top_clientes();"
            results = self.db.fetch_all(query)
            
            if results:
                print("{:<5} {:<30} {:<15}".format("ID", "Nombre", "Reservas"))
                print("-" * 50)
                
                for item in results:
                    print("{:<5} {:<30} {:<15}".format(
                        item['cliente_id'],
                        item['nombre'][:29],
                        item['total_reservas']
                    ))
            else:
                print("No hay datos disponibles para este reporte.")
                
        except Exception as e:
            print(f"Error al generar el reporte: {e}")
    
    def top_reservation_customers(self):
        """Show top 5 customers with most reservations."""
        self.clear_console()
        print("\n--- TOP 5 CLIENTES CON MÁS RESERVAS ---")
        
        try:
            query = "SELECT * FROM top_reservas();"
            results = self.db.fetch_all(query)
            
            if results:
                print("{:<5} {:<25} {:<10} {:<10} {:<30}".format("ID", "Nombre", "Reservas", "Platillo ID", "Platillo Favorito"))
                print("-" * 80)
                
                for item in results:
                    print("{:<5} {:<25} {:<10} {:<10} {:<30}".format(
                        item['cliente_id'],
                        item['nombre'][:24],
                        item['total_reservas'],
                        item['plato_favorito_id'] or 'N/A',
                        item['plato_favorito'] or 'N/A'
                    ))
            else:
                print("No hay datos disponibles para este reporte.")
                
        except Exception as e:
            print(f"Error al generar el reporte: {e}")
    
    def monthly_inventory_report(self):
        """Show monthly inventory report."""
        self.clear_console()
        print("\n--- REPORTE MENSUAL DE INVENTARIO ---")
        
        try:
            query = "SELECT * FROM reporte_inventario_mensual();"
            results = self.db.fetch_all(query)
            
            if results:
                print("{:<5} {:<25} {:<8} {:<12} {:<15} {:<15} {:<25}".format(
                    "ID", "Producto", "Sede", "Existencia", "Caducidad", "Días Caducar", "Tipo Alerta"
                ))
                print("-" * 105)
                
                for item in results:
                    print("{:<5} {:<25} {:<8} {:<12} {:<15} {:<15} {:<25}".format(
                        item['inventario_id'],
                        item['producto'][:24],
                        item['sede_id'],
                        item['existencia'],
                        str(item['caducidad']) if item['caducidad'] else 'N/A',
                        item['dias_para_caducar'] or 'N/A',
                        item['tipo_alerta'] or 'N/A'
                    ))
            else:
                print("No hay alertas de inventario en este momento.")
                
        except Exception as e:
            print(f"Error al generar el reporte: {e}")
    
    def branch_summary(self):
        """Show branch performance summary."""
        self.clear_console()
        print("\n--- RESUMEN DE SUCURSALES ---")
        
        try:
            query = "SELECT * FROM resumen_sucursales();"
            results = self.db.fetch_all(query)
            
            if results:
                print("{:<5} {:<40} {:<15} {:<20} {:<15}".format("Sede", "Dirección", "Total Reservas", "No Canceladas", "Ventas"))
                print("-" * 100)
                
                for item in results:
                    print("{:<5} {:<40} {:<15} {:<20} {:<15}".format(
                        item['sede_id'],
                        item['direccion'][:39],
                        item['total_reservas'],
                        item['reservas_no_canceladas'],
                        item['total_ventas']
                    ))
            else:
                print("No hay datos disponibles para este reporte.")
                
        except Exception as e:
            print(f"Error al generar el reporte: {e}")
    
    def run(self):
        """Run the main menu loop."""
        while True:
            self.clear_console()
            self.display_menu()
            choice = self.get_menu_choice()
            
            if choice == 1:
                self.handle_reservation_management()
            elif choice == 2:
                self.handle_inventory_management()
            elif choice == 3:
                self.register_new_client()
            elif choice == 4:
                self.register_order()
            elif choice == 5:
                self.handle_customer_history()
            elif choice == 6:
                self.handle_reports()
            elif choice == 7:
                self.view_bitacora_logs()
            elif choice == 8:
                print("Saliendo del programa...")
                break

    def view_bitacora_logs(self):
        """Display recent entries from the audit log."""
        self.clear_console()
        print("\n--- BITÁCORA DE CAMBIOS ---")

        try:
            limit_input = input("¿Cuántos registros desea ver? (default 20): ")
            limit = int(limit_input) if limit_input.strip() else 20
            limit = max(1, min(limit, 100))

            query = "SELECT * FROM bitacora_listar(%s);"
            logs = self.db.fetch_all(query, (limit,))

            if logs:
                print("{:<5} {:<25} {:<12} {:<12} {:<20} {:<10} {:<40}".format(
                    "ID", "Esquema", "ID Afectado", "Operación", "Fecha", "Personal", "Detalle"
                ))
                print("-" * 130)
                for entry in logs:
                    fecha = entry["fecha"]
                    fecha_text = fecha.strftime("%Y-%m-%d %H:%M") if isinstance(fecha, datetime) else str(fecha)
                    print("{:<5} {:<25} {:<12} {:<12} {:<20} {:<10} {:<40}".format(
                        entry["id"],
                        entry["esquema"][:24],
                        entry["id_afectado"],
                        entry["operacion"],
                        fecha_text,
                        entry["personal_id"],
                        (entry["detalle"] or "")[:39],
                    ))
            else:
                print("No hay registros en la bitácora.")

        except ValueError:
            print("Cantidad inválida. Debe ingresar un número.")
        except Exception as e:
            print(f"Error al obtener la bitácora: {e}")
        finally:
            self.pause()
