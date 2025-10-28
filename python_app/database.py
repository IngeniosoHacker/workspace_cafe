#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import psycopg2
from psycopg2.extras import RealDictCursor
import os
from dotenv import load_dotenv


# Load environment variables
load_dotenv()


class DatabaseConnection:
    """Database connection class for PostgreSQL."""
    
    def __init__(self):
        """Initialize database connection."""
        try:
            self.connection = psycopg2.connect(
                host=os.getenv('DB_HOST', 'localhost'),
                database=os.getenv('DB_NAME', 'coworkingDB'),
                user=os.getenv('DB_USER', 'postgres'),
                password=os.getenv('DB_PASSWORD', 'password'),
                port=os.getenv('DB_PORT', 5432)
            )
            self.connection.autocommit = False
        except psycopg2.Error as e:
            print(f"Error al conectar a la base de datos: {e}")
            raise
    
    def fetch_one(self, query, params=None):
        """
        Execute SELECT query and return a single row.
        
        Args:
            query (str): SQL query to execute
            params (tuple): Parameters for the query
            
        Returns:
            tuple: Single row result or None
        """
        try:
            with self.connection.cursor() as cursor:
                cursor.execute(query, params)
                return cursor.fetchone()
        except psycopg2.Error as e:
            print(f"Error executing query: {e}")
            self.connection.rollback()
            return None
    
    def fetch_all(self, query, params=None):
        """
        Execute SELECT query and return all rows.
        
        Args:
            query (str): SQL query to execute
            params (tuple): Parameters for the query
            
        Returns:
            list: List of rows
        """
        try:
            with self.connection.cursor(cursor_factory=RealDictCursor) as cursor:
                cursor.execute(query, params)
                return cursor.fetchall()
        except psycopg2.Error as e:
            print(f"Error executing query: {e}")
            self.connection.rollback()
            return []
    
    def execute_query(self, query, params=None):
        """
        Execute a query that doesn't return data (INSERT, UPDATE, DELETE).
        
        Args:
            query (str): SQL query to execute
            params (tuple): Parameters for the query
            
        Returns:
            bool: True if successful, False otherwise
        """
        try:
            with self.connection.cursor() as cursor:
                cursor.execute(query, params)
                self.connection.commit()
                return True
        except psycopg2.Error as e:
            print(f"Error executing query: {e}")
            self.connection.rollback()
            return False
    
    def call_procedure(self, procedure_name, params=None):
        """
        Call a stored procedure.
        
        Args:
            procedure_name (str): Name of the procedure
            params (tuple): Parameters for the procedure
            
        Returns:
            list: Results from the procedure
        """
        try:
            with self.connection.cursor(cursor_factory=RealDictCursor) as cursor:
                cursor.callproc(procedure_name, params)
                return cursor.fetchall()
        except psycopg2.Error as e:
            print(f"Error calling procedure: {e}")
            self.connection.rollback()
            return []
    
    def execute_procedure(self, procedure_name, params=None):
        """
        Execute a stored procedure without returning results.
        
        Args:
            procedure_name (str): Name of the procedure
            params (tuple): Parameters for the procedure
            
        Returns:
            bool: True if successful, False otherwise
        """
        try:
            with self.connection.cursor() as cursor:
                cursor.callproc(procedure_name, params)
                self.connection.commit()
                return True
        except psycopg2.Error as e:
            print(f"Error executing procedure: {e}")
            self.connection.rollback()
            return False
    
    def close(self):
        """Close the database connection."""
        if self.connection:
            self.connection.close()