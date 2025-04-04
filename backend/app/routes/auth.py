from flask import Blueprint, request, jsonify
from werkzeug.security import generate_password_hash, check_password_hash
from ..database import get_db_connection
import jwt
from datetime import datetime, timedelta
import os

bp = Blueprint('auth', __name__)

@bp.route('/register', methods=['POST'])
def register():
    try:
        data = request.get_json()
        
        if not data or not data.get('username') or not data.get('email') or not data.get('password'):
            return jsonify({'error': 'Missing required fields'}), 400
            
        conn = get_db_connection()
        cursor = conn.cursor()
        
        # Check if username or email already exists
        cursor.execute('SELECT id FROM users WHERE username = %s OR email = %s', 
                      (data['username'], data['email']))
        if cursor.fetchone():
            return jsonify({'error': 'Username or email already exists'}), 400
        
        # Create new user
        cursor.execute('''
            INSERT INTO users (username, email, password_hash)
            VALUES (%s, %s, %s)
        ''', (
            data['username'],
            data['email'],
            generate_password_hash(data['password'])
        ))
        
        conn.commit()
        return jsonify({'message': 'User registered successfully'}), 201
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    finally:
        cursor.close()
        conn.close()

@bp.route('/login', methods=['POST'])
def login():
    try:
        data = request.get_json()
        
        if not data or not data.get('email') or not data.get('password'):
            return jsonify({'error': 'Missing required fields'}), 400
            
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        
        # Get user by email
        cursor.execute('SELECT * FROM users WHERE email = %s', (data['email'],))
        user = cursor.fetchone()
        
        if not user or not check_password_hash(user['password_hash'], data['password']):
            return jsonify({'error': 'Invalid email or password'}), 401
        
        # Generate JWT token
        token = jwt.encode({
            'user_id': user['id'],
            'exp': datetime.utcnow() + timedelta(days=1)
        }, os.getenv('JWT_SECRET_KEY', 'your-secret-key'))
        
        return jsonify({
            'token': token,
            'user': {
                'id': user['id'],
                'username': user['username'],
                'email': user['email']
            }
        })
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    finally:
        cursor.close()
        conn.close() 