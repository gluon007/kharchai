import os
from dotenv import load_dotenv

load_dotenv()

class Config:
    # Database configuration
    DATABASE_URL = os.getenv('DATABASE_URL', 'mysql://root:password@localhost:3306/kharchai')
    
    # JWT configuration
    JWT_SECRET_KEY = os.getenv('JWT_SECRET', 'your-secret-key')
    JWT_ACCESS_TOKEN_EXPIRES = 3600  # 1 hour
    
    # AI/ML configuration
    GOOGLE_CLOUD_PROJECT = os.getenv('GOOGLE_CLOUD_PROJECT')
    OPENAI_API_KEY = os.getenv('OPENAI_API_KEY')
    
    # Application configuration
    DEBUG = os.getenv('FLASK_ENV') == 'development'
    TESTING = False
    
    # API configuration
    API_PREFIX = '/api/v1' 