import mysql.connector
from mysql.connector import Error

def test_connection():
    try:
        print("Testing MySQL connection...")
        # Try to connect to MySQL
        connection = mysql.connector.connect(
            host='localhost',
            user='root',
            password='Gluon@2403',
            auth_plugin='mysql_native_password'
        )
        
        if connection.is_connected():
            print("Successfully connected to MySQL!")
            
            # Create cursor
            cursor = connection.cursor()
            
            # Create database
            print("Creating database 'kharchai'...")
            cursor.execute("CREATE DATABASE IF NOT EXISTS kharchai")
            print("Database 'kharchai' created or already exists")
            
            # Switch to kharchai database
            cursor.execute("USE kharchai")
            
            # Create users table
            print("Creating users table...")
            cursor.execute('''
                CREATE TABLE IF NOT EXISTS users (
                    id INT AUTO_INCREMENT PRIMARY KEY,
                    username VARCHAR(50) UNIQUE NOT NULL,
                    email VARCHAR(100) UNIQUE NOT NULL,
                    password_hash VARCHAR(255) NOT NULL,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                )
            ''')
            print("Users table created or already exists")
            
            # Create expenses table
            print("Creating expenses table...")
            cursor.execute('''
                CREATE TABLE IF NOT EXISTS expenses (
                    id INT AUTO_INCREMENT PRIMARY KEY,
                    user_id INT NOT NULL,
                    amount DECIMAL(10, 2) NOT NULL,
                    category VARCHAR(50) NOT NULL,
                    description TEXT,
                    date TIMESTAMP NOT NULL,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    FOREIGN KEY (user_id) REFERENCES users(id)
                )
            ''')
            print("Expenses table created or already exists")
            
            # Verify tables
            print("\nVerifying tables:")
            cursor.execute("SHOW TABLES")
            tables = cursor.fetchall()
            print(f"Tables in database: {tables}")
            
            # Close connection
            cursor.close()
            connection.close()
            print("\nDatabase connection closed")
            
    except Error as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    test_connection() 