import mysql.connector

# Database connection settings
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
    
    # Add resume_path column to students table
    cursor.execute("""
        ALTER TABLE students 
        ADD COLUMN resume_path VARCHAR(255)
    """)
    
    conn.commit()
    print("✓ Successfully added resume_path column to students table!")
    
except mysql.connector.Error as err:
    if err.errno == 1060:  # Duplicate column name
        print("✓ Column resume_path already exists!")
    else:
        print(f"Error: {err}")
finally:
    if 'cursor' in locals():
        cursor.close()
    if 'conn' in locals():
        conn.close()
