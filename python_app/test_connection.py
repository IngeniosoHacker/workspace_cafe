#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Simple test script to verify database connection
"""

import sys
import os

# Add the current directory to the path
sys.path.append('/home/juampa/UVG/DB1/workspace_cafe/python_app')

from database import DatabaseConnection

def test_connection():
    """Test database connection."""
    print("Testing database connection...")
    
    try:
        db = DatabaseConnection()
        print("✓ Successfully connected to the database")
        
        # Test a simple query
        result = db.fetch_one("SELECT version();")
        if result:
            print(f"✓ PostgreSQL version: {result[0][:50]}...")
        
        # Test the get_password function
        password_result = db.fetch_one("SELECT get_password(1);")
        if password_result:
            print(f"✓ Password function works, example result: {password_result[0]}")
        
        # Test that tables exist
        result = db.fetch_one("SELECT COUNT(*) FROM cliente;")
        print(f"✓ Client table exists and has {result[0]} records")
        
        db.close()
        print("✓ Database connection test completed successfully")
        
    except Exception as e:
        print(f"✗ Error testing database connection: {e}")
        return False
    
    return True

if __name__ == "__main__":
    test_connection()