#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from database import DatabaseConnection
from datetime import datetime
import os


class DailyClosing:
    """Daily closing report generator."""
    
    def __init__(self, user_data):
        """
        Initialize daily closing report.
        
        Args:
            user_data (dict): User information
        """
        self.user_data = user_data
        self.db = DatabaseConnection()
    
    def get_daily_reservations(self):
        """Get total reservations for today."""
        query = """
        SELECT COUNT(*) as total_reservations
        FROM reserva
        WHERE DATE(horaFecha) = CURRENT_DATE
        AND COALESCE(status, 'Activa') <> 'Cancelada';
        """
        result = self.db.fetch_one(query)
        return result[0] if result else 0
    
    def get_daily_sales(self):
        """Get total sales for today."""
        query = """
        SELECT COALESCE(SUM(m.precio), 0) as total_sales
        FROM reserva r
        JOIN pide p ON p.reservaid = r.id
        JOIN menu m ON m.id = p.menuid
        WHERE DATE(r.horaFecha) = CURRENT_DATE
        AND COALESCE(r.status, 'Activa') <> 'Cancelada';
        """
        result = self.db.fetch_one(query)
        return result[0] if result else 0
    
    def get_user_activity(self):
        """Get activity for the current user today."""
        query = """
        SELECT COUNT(*) as user_reservations
        FROM reserva
        WHERE DATE(horaFecha) = CURRENT_DATE
        AND personal_fk = %s
        AND COALESCE(status, 'Activa') <> 'Cancelada';
        """
        result = self.db.fetch_one(query, (self.user_data['id'],))
        user_reservations = result[0] if result else 0
        
        return user_reservations
    
    def get_low_stock_items(self):
        """Get items with low stock."""
        query = """
        SELECT i.producto, i.existencia, i.sede_id
        FROM inventario i
        WHERE i.existencia <= 20;
        """
        return self.db.fetch_all(query)
    
    def get_daily_changes(self):
        """Get changes made during the day."""
        query = """
        SELECT COUNT(*) as total_changes
        FROM bitacora
        WHERE DATE(fecha) = CURRENT_DATE;
        """
        result = self.db.fetch_one(query)
        return result[0] if result else 0
    
    def generate_report(self):
        """Generate and save the daily closing report."""
        print("Generando reporte de cierre diario...")
        
        # Get report data
        total_reservations = self.get_daily_reservations()
        total_sales = self.get_daily_sales()
        user_reservations = self.get_user_activity()
        low_stock_items = self.get_low_stock_items()
        daily_changes = self.get_daily_changes()
        
        # Create report content
        report_content = f"""
REPORTE DE CIERRE DIARIO
Fecha: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
Usuario: {self.user_data['name']} (ID: {self.user_data['id']}, Rol: {self.user_data['role']})

RESUMEN DEL DÍA:
- Total reservaciones activas del día: {total_reservations}
- Ventas totales del día: Q{total_sales:.2f}
- Reservaciones manejadas por usuario: {user_reservations}
- Cambios registrados en el sistema: {daily_changes}

PRODUCTOS CON BAJA EXISTENCIA:
"""
        
        if low_stock_items:
            report_content += "{:<30} {:<15} {:<10}\n".format("Producto", "Existencia", "Sede ID")
            report_content += "-" * 55 + "\n"
            for item in low_stock_items:
                report_content += "{:<30} {:<15} {:<10}\n".format(
                    item['producto'][:29],
                    item['existencia'],
                    item['sede_id']
                )
        else:
            report_content += "No hay productos con baja existencia.\n"
        
        report_content += "\nFin del reporte de cierre diario.\n"
        
        # Save report to file
        filename = f"reporte_cierre_{datetime.now().strftime('%Y%m%d_%H%M%S')}.txt"
        filepath = os.path.join(os.getcwd(), filename)
        
        try:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(report_content)
            print(f"Reporte guardado en: {filepath}")
        except Exception as e:
            print(f"Error al guardar el reporte: {e}")
            # Print to console if file save fails
            print(report_content)
        
        # Close database connection
        self.db.close()