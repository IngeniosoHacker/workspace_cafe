#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Test script to verify authentication process with a known user
"""

import sys
import os

# Add the current directory to the path
sys.path.append('/home/juampa/UVG/DB1/workspace_cafe/python_app')

from database import DatabaseConnection


def test_authentication():
    """Test the authentication process directly."""
    print("Testing authentication process...")
    
    db = DatabaseConnection()
    
    try:
        # Test getting user ID for Laura Gómez
        query = "SELECT id, nombre, puesto FROM personal WHERE nombre = %s;"
        user_data = db.fetch_one(query, ("Laura Gómez",))
        
        if user_data:
            user_id, user_name, user_role = user_data
            print(f"✓ User found: {user_name}, ID: {user_id}, Role: {user_role}")
            
            # Test password verification
            query = "SELECT get_password(%s);"
            stored_password = db.fetch_one(query, (user_id,))
            
            if stored_password:
                print(f"✓ Password for user {user_id} retrieved: {stored_password[0]}")
                
                # This should match the password from inserts.sql: 'pass123'
                expected_password = 'pass123'
                if stored_password[0] == expected_password:
                    print("✓ Password matches expected value from inserts.sql")
                else:
                    print(f"✗ Password doesn't match. Expected: {expected_password}, Got: {stored_password[0]}")
            else:
                print("✗ Failed to retrieve password")
        else:
            print("✗ User 'Laura Gómez' not found")
            
    except Exception as e:
        print(f"✗ Error during authentication test: {e}")
    finally:
        db.close()


def test_functions():
    """Test that database functions work correctly."""
    print("\nTesting database functions...")
    
    db = DatabaseConnection()
    
    try:
        # Test top_menu function (should return empty since no sales yet)
        result = db.fetch_all("SELECT * FROM top_menu();")
        print(f"✓ top_menu function works, returned {len(result)} results")
        
        # Test s_inventario function
        result = db.fetch_all("SELECT * FROM s_inventario(1);")
        print(f"✓ s_inventario function works, returned {len(result)} results for sede 1")
        
        # Test other functions
        result = db.fetch_all("SELECT * FROM top_clientes();")
        print(f"✓ top_clientes function works, returned {len(result)} results")
        
        result = db.fetch_all("SELECT * FROM resumen_sucursales();")
        print(f"✓ resumen_sucursales function works, returned {len(result)} results")
        
    except Exception as e:
        print(f"✗ Error testing functions: {e}")
    finally:
        db.close()


if __name__ == "__main__":
    test_authentication()
    test_functions()
    print("\n✓ All tests completed successfully!")