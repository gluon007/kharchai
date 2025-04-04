from flask import Blueprint, jsonify, request
from ..database import get_db_connection
from ..models.expense import Expense
from ..middleware import token_required
from datetime import datetime

bp = Blueprint('expenses', __name__)

@bp.route('/expenses', methods=['GET'])
@token_required
def get_expenses():
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        
        cursor.execute('''
            SELECT e.*, c.name as category_name 
            FROM expenses e 
            JOIN categories c ON e.category_id = c.id 
            WHERE e.user_id = %s
            ORDER BY e.date DESC
        ''', (request.user_id,))
        
        expenses = cursor.fetchall()
        return jsonify([{
            **Expense.from_dict(expense).to_dict(),
            'category_name': expense['category_name']
        } for expense in expenses])
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    finally:
        cursor.close()
        conn.close()

@bp.route('/expenses', methods=['POST'])
@token_required
def add_expense():
    try:
        data = request.get_json()
        conn = get_db_connection()
        cursor = conn.cursor()
        
        # Verify category exists
        cursor.execute('SELECT id FROM categories WHERE id = %s', (data['category_id'],))
        if not cursor.fetchone():
            return jsonify({'error': 'Invalid category ID'}), 400
        
        # Insert expense
        cursor.execute('''
            INSERT INTO expenses (user_id, amount, category_id, description, date)
            VALUES (%s, %s, %s, %s, %s)
        ''', (
            request.user_id,
            data['amount'],
            data['category_id'],
            data.get('description'),
            datetime.strptime(data['date'], '%Y-%m-%d %H:%M:%S') if data.get('date') else datetime.utcnow()
        ))
        
        conn.commit()
        expense_id = cursor.lastrowid
        
        # Get the created expense with category name
        cursor.execute('''
            SELECT e.*, c.name as category_name 
            FROM expenses e 
            JOIN categories c ON e.category_id = c.id 
            WHERE e.id = %s
        ''', (expense_id,))
        
        expense = cursor.fetchone()
        return jsonify({
            **Expense.from_dict(expense).to_dict(),
            'category_name': expense['category_name']
        }), 201
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    finally:
        cursor.close()
        conn.close()

@bp.route('/expenses/<int:expense_id>', methods=['GET'])
@token_required
def get_expense(expense_id):
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        
        cursor.execute('''
            SELECT e.*, c.name as category_name 
            FROM expenses e 
            JOIN categories c ON e.category_id = c.id 
            WHERE e.id = %s AND e.user_id = %s
        ''', (expense_id, request.user_id))
        
        expense = cursor.fetchone()
        if not expense:
            return jsonify({'error': 'Expense not found'}), 404
            
        return jsonify({
            **Expense.from_dict(expense).to_dict(),
            'category_name': expense['category_name']
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    finally:
        cursor.close()
        conn.close()

@bp.route('/expenses/<int:expense_id>', methods=['PUT'])
@token_required
def update_expense(expense_id):
    try:
        data = request.get_json()
        conn = get_db_connection()
        cursor = conn.cursor()
        
        # Check if expense exists and belongs to user
        cursor.execute('SELECT id FROM expenses WHERE id = %s AND user_id = %s', 
                      (expense_id, request.user_id))
        if not cursor.fetchone():
            return jsonify({'error': 'Expense not found'}), 404
            
        # Verify category exists if being updated
        if 'category_id' in data:
            cursor.execute('SELECT id FROM categories WHERE id = %s', (data['category_id'],))
            if not cursor.fetchone():
                return jsonify({'error': 'Invalid category ID'}), 400
        
        # Update expense
        update_fields = []
        update_values = []
        
        if 'amount' in data:
            update_fields.append('amount = %s')
            update_values.append(data['amount'])
        if 'category_id' in data:
            update_fields.append('category_id = %s')
            update_values.append(data['category_id'])
        if 'description' in data:
            update_fields.append('description = %s')
            update_values.append(data['description'])
        if 'date' in data:
            update_fields.append('date = %s')
            update_values.append(datetime.strptime(data['date'], '%Y-%m-%d %H:%M:%S'))
            
        if not update_fields:
            return jsonify({'error': 'No fields to update'}), 400
            
        update_values.extend([expense_id, request.user_id])
        
        query = f'''
            UPDATE expenses 
            SET {', '.join(update_fields)}
            WHERE id = %s AND user_id = %s
        '''
        
        cursor.execute(query, update_values)
        conn.commit()
        
        # Get the updated expense with category name
        cursor.execute('''
            SELECT e.*, c.name as category_name 
            FROM expenses e 
            JOIN categories c ON e.category_id = c.id 
            WHERE e.id = %s
        ''', (expense_id,))
        
        expense = cursor.fetchone()
        return jsonify({
            **Expense.from_dict(expense).to_dict(),
            'category_name': expense['category_name']
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    finally:
        cursor.close()
        conn.close()

@bp.route('/expenses/<int:expense_id>', methods=['DELETE'])
@token_required
def delete_expense(expense_id):
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        
        cursor.execute('DELETE FROM expenses WHERE id = %s AND user_id = %s', 
                      (expense_id, request.user_id))
        conn.commit()
        
        if cursor.rowcount == 0:
            return jsonify({'error': 'Expense not found'}), 404
            
        return '', 204
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    finally:
        cursor.close()
        conn.close() 