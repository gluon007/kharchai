from flask import Flask
from flask_cors import CORS
from dotenv import load_dotenv

def create_app():
    # Load environment variables
    load_dotenv()

    # Initialize Flask app
    app = Flask(__name__)
    CORS(app)

    # Register blueprints (will be added later)
    # from .routes import auth_bp, expense_bp
    # app.register_blueprint(auth_bp)
    # app.register_blueprint(expense_bp)

    return app 