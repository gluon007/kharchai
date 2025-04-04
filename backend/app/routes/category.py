from flask import Blueprint, jsonify, request
from ..database import get_db_connection
from ..models.category import Category

bp = Blueprint('categories', __name__)

@bp.route('/categories', methods=['GET'])
def get_categories():
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        
        cursor.execute('SELECT * FROM categories')
        categories = cursor.fetchall()
        
        return jsonify([Category.from_dict(category).to_dict() for category in categories])
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    finally:
        cursor.close()
        conn.close()

@bp.route('/categories/<int:category_id>', methods=['GET'])
def get_category(category_id):
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        
        cursor.execute('SELECT * FROM categories WHERE id = %s', (category_id,))
        category = cursor.fetchone()
        
        if not category:
            return jsonify({'error': 'Category not found'}), 404
            
        return jsonify(Category.from_dict(category).to_dict())
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    finally:
        cursor.close()
        conn.close() 