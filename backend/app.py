from flask import Flask, jsonify
from flask_cors import CORS
from dotenv import load_dotenv
import os
from app.database import init_db
from app.routes.auth import bp as auth_bp
from app.routes.expense import bp as expense_bp
from app.routes.category import bp as category_bp

# Load environment variables
load_dotenv()

def create_app():
    app = Flask(__name__)
    CORS(app)
    
    # Initialize database
    init_db()
    
    # Register blueprints
    app.register_blueprint(auth_bp, url_prefix='/api/v1/auth')
    app.register_blueprint(expense_bp, url_prefix='/api/v1')
    app.register_blueprint(category_bp, url_prefix='/api/v1')
    
    # Basic route for testing
    @app.route('/')
    def index():
        return jsonify({'message': 'Welcome to KharchAI API'})
    
    # Health check endpoint
    @app.route('/health')
    def health_check():
        return jsonify({'status': 'healthy'})
    
    return app

if __name__ == '__main__':
    port = int(os.getenv('PORT', 5000))
    app = create_app()
    app.run(host='0.0.0.0', port=port, debug=True) 