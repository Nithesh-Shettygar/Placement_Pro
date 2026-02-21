"""
Migration script to add posted_by_alumni column to companies table
Run this once to update the database schema
"""
import mysql.connector

# Database configuration
DB_USER = 'root'
DB_PASSWORD = ''  # Change to your MySQL password
DB_NAME = 'placement_pro_db'
DB_HOST = 'localhost'

try:
    # Connect to database
    conn = mysql.connector.connect(
        host=DB_HOST,
        user=DB_USER,
        password=DB_PASSWORD,
        database=DB_NAME
    )
    cursor = conn.cursor()
    
    # Add posted_by_alumni column if it doesn't exist
    alter_query = """
    ALTER TABLE companies 
    ADD COLUMN IF NOT EXISTS posted_by_alumni BOOLEAN DEFAULT FALSE
    """
    
    cursor.execute(alter_query)
    conn.commit()
    
    print("✓ Successfully added posted_by_alumni column to companies table")
    
    cursor.close()
    conn.close()
    
except mysql.connector.Error as err:
    if err.errno == 1060:  # Column already exists
        print("✓ Column posted_by_alumni already exists")
    else:
        print(f"Error: {err}")
except Exception as e:
    print(f"Error: {e}")
