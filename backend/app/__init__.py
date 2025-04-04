from flask import Flask
from flask_cors import CORS
from dotenv import load_dotenv
from .database import init_db
from .routes import auth_bp, expense_bp

def create_app():
    # Load environment variables
    load_dotenv()

    # Initialize Flask app
    app = Flask(__name__)
    CORS(app)

    # Initialize database
    init_db()

    # Register blueprints
    app.register_blueprint(auth_bp, url_prefix='/api/v1/auth')
    app.register_blueprint(expense_bp, url_prefix='/api/v1')

    return app 