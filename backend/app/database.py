import mysql.connector
from mysql.connector import Error
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

def get_db_connection():
    try:
        print("Attempting to connect to MySQL...")
        # First connect without database to create it if needed
        connection = mysql.connector.connect(
            host=os.getenv('DB_HOST', 'localhost'),
            user=os.getenv('DB_USER', 'root'),
            password=os.getenv('DB_PASSWORD', 'Gluon@2403'),
            auth_plugin='mysql_native_password'
        )
        print("Connected to MySQL successfully")
        
        cursor = connection.cursor()
        
        # Create database if it doesn't exist
        db_name = os.getenv('DB_NAME', 'kharchai')
        print(f"Creating database {db_name} if it doesn't exist...")
        cursor.execute(f"CREATE DATABASE IF NOT EXISTS {db_name}")
        print("Database creation/check completed")
        
        # Verify database exists
        cursor.execute("SHOW DATABASES")
        databases = cursor.fetchall()
        print(f"Available databases: {databases}")
        
        cursor.close()
        connection.close()
        
        # Now connect with the database
        print(f"Connecting to the {db_name} database...")
        connection = mysql.connector.connect(
            host=os.getenv('DB_HOST', 'localhost'),
            user=os.getenv('DB_USER', 'root'),
            password=os.getenv('DB_PASSWORD', 'Gluon@2403'),
            database=os.getenv('DB_NAME', 'kharchai'),
            auth_plugin='mysql_native_password'
        )
        print(f"Connected to {db_name} database successfully")
        
        # Verify we're connected to the right database
        cursor = connection.cursor()
        cursor.execute("SELECT DATABASE()")
        current_db = cursor.fetchone()
        print(f"Currently connected to database: {current_db}")
        
        return connection
    except Error as e:
        print(f"Error connecting to MySQL Database: {e}")
        return None

def init_db():
    print("Starting database initialization...")
    connection = get_db_connection()
    if connection:
        try:
            cursor = connection.cursor()
            
            # Check if tables exist
            print("Checking existing tables...")
            cursor.execute("SHOW TABLES")
            existing_tables = cursor.fetchall()
            print(f"Existing tables: {existing_tables}")
            
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
            print("Users table created/verified")
            
            # Create categories table
            print("Creating categories table...")
            cursor.execute('''
                CREATE TABLE IF NOT EXISTS categories (
                    id INT AUTO_INCREMENT PRIMARY KEY,
                    name VARCHAR(50) NOT NULL,
                    description TEXT,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                )
            ''')
            print("Categories table created/verified")
            
            # Insert default categories if they don't exist
            default_categories = [
                ('Food & Dining', 'Restaurants, groceries, and food-related expenses'),
                ('Transportation', 'Gas, public transport, and vehicle maintenance'),
                ('Housing', 'Rent, mortgage, and home maintenance'),
                ('Utilities', 'Electricity, water, internet, and phone bills'),
                ('Entertainment', 'Movies, games, and leisure activities'),
                ('Shopping', 'Clothes, electronics, and other purchases'),
                ('Healthcare', 'Medical expenses and health-related costs'),
                ('Education', 'Books, courses, and educational materials'),
                ('Travel', 'Hotel, flights, and travel expenses'),
                ('Other', 'Miscellaneous expenses')
            ]
            
            for category in default_categories:
                cursor.execute('''
                    INSERT IGNORE INTO categories (name, description)
                    VALUES (%s, %s)
                ''', category)
            
            # Create expenses table
            print("Creating expenses table...")
            cursor.execute('''
                CREATE TABLE IF NOT EXISTS expenses (
                    id INT AUTO_INCREMENT PRIMARY KEY,
                    user_id INT NOT NULL,
                    amount DECIMAL(10, 2) NOT NULL,
                    category_id INT NOT NULL,
                    description TEXT,
                    date TIMESTAMP NOT NULL,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    FOREIGN KEY (user_id) REFERENCES users(id),
                    FOREIGN KEY (category_id) REFERENCES categories(id)
                )
            ''')
            print("Expenses table created/verified")
            
            # Verify tables were created
            print("Verifying tables...")
            cursor.execute("SHOW TABLES")
            tables = cursor.fetchall()
            print(f"Tables in database: {tables}")
            
            connection.commit()
            print("Database tables created successfully")
            
        except Error as e:
            print(f"Error creating tables: {e}")
        finally:
            cursor.close()
            connection.close()
    else:
        print("Failed to initialize database - no connection available") 