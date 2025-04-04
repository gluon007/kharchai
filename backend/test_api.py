import requests
import json
from datetime import datetime

BASE_URL = 'http://localhost:5000/api/v1'

def test_categories():
    print("\n=== Testing Categories ===")
    
    # Test getting all categories
    print("\n1. Getting all categories...")
    try:
        response = requests.get(f'{BASE_URL}/categories')
        print(f"Status Code: {response.status_code}")
        if response.status_code == 200:
            categories = response.json()
            print(f"Found {len(categories)} categories:")
            for category in categories:
                print(f"- {category['name']} (ID: {category['id']})")
            return categories
        else:
            print(f"Error: {response.text}")
            return []
    except requests.RequestException as e:
        print(f"Request failed: {e}")
        return []
    
    # Test getting a specific category
    if response.status_code == 200 and categories:
        category_id = categories[0]['id']
        print(f"\n2. Getting category with ID {category_id}...")
        response = requests.get(f'{BASE_URL}/categories/{category_id}')
        print(f"Status Code: {response.status_code}")
        if response.status_code == 200:
            category = response.json()
            print(f"Category details: {json.dumps(category, indent=2)}")
        else:
            print(f"Error: {response.json()}")

def test_user_flow():
    print("\n=== Testing User Flow ===")
    
    # First, register a user and get token
    print("\n1. Registering a test user...")
    user_data = {
        'username': f'testuser_{datetime.now().strftime("%Y%m%d%H%M%S")}',
        'email': f'test_{datetime.now().strftime("%Y%m%d%H%M%S")}@example.com',
        'password': 'testpass123'
    }
    
    try:
        response = requests.post(f'{BASE_URL}/auth/register', json=user_data)
        print(f"Status Code: {response.status_code}")
        if response.status_code not in [201, 200]:
            print(f"Error: {response.text}")
            return None
    except requests.RequestException as e:
        print(f"Request failed: {e}")
        return None
    
    # Login to get token
    print("\n2. Logging in...")
    login_data = {
        'email': user_data['email'],
        'password': user_data['password']
    }
    
    try:
        response = requests.post(f'{BASE_URL}/auth/login', json=login_data)
        print(f"Status Code: {response.status_code}")
        if response.status_code != 200:
            print(f"Error: {response.text}")
            return None
        
        result = response.json()
        token = result.get('token')
        if not token:
            print("No token returned")
            return None
        
        print("Login successful, token received")
        return {
            'user': user_data,
            'token': token,
            'headers': {'Authorization': f'Bearer {token}'}
        }
    except requests.RequestException as e:
        print(f"Request failed: {e}")
        return None

def test_expenses(user_info, categories):
    if not user_info or not categories:
        print("Cannot test expenses without user info and categories")
        return
    
    headers = user_info['headers']
    
    # Add an expense
    print("\n=== Testing Expenses ===")
    print("\n1. Adding an expense...")
    expense_data = {
        'amount': 50.00,
        'category_id': categories[0]['id'],
        'description': 'Test expense',
        'date': datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S')
    }
    
    try:
        response = requests.post(f'{BASE_URL}/expenses', json=expense_data, headers=headers)
        print(f"Status Code: {response.status_code}")
        if response.status_code == 201:
            expense = response.json()
            print(f"Created expense: {json.dumps(expense, indent=2)}")
            expense_id = expense['id']
        else:
            print(f"Error: {response.text}")
            return
    except requests.RequestException as e:
        print(f"Request failed: {e}")
        return
    
    # Get all expenses
    print("\n2. Getting all expenses...")
    try:
        response = requests.get(f'{BASE_URL}/expenses', headers=headers)
        print(f"Status Code: {response.status_code}")
        if response.status_code == 200:
            expenses = response.json()
            print(f"Found {len(expenses)} expenses")
            for exp in expenses:
                print(f"- {exp['amount']} ({exp.get('category_name', 'N/A')})")
        else:
            print(f"Error: {response.text}")
    except requests.RequestException as e:
        print(f"Request failed: {e}")
    
    # Get specific expense
    print(f"\n3. Getting expense with ID {expense_id}...")
    try:
        response = requests.get(f'{BASE_URL}/expenses/{expense_id}', headers=headers)
        print(f"Status Code: {response.status_code}")
        if response.status_code == 200:
            expense = response.json()
            print(f"Expense details: {json.dumps(expense, indent=2)}")
        else:
            print(f"Error: {response.text}")
    except requests.RequestException as e:
        print(f"Request failed: {e}")
    
    # Update expense
    print("\n4. Updating expense...")
    update_data = {
        'amount': 75.00,
        'description': 'Updated test expense'
    }
    
    try:
        response = requests.put(f'{BASE_URL}/expenses/{expense_id}', json=update_data, headers=headers)
        print(f"Status Code: {response.status_code}")
        if response.status_code == 200:
            expense = response.json()
            print(f"Updated expense: {json.dumps(expense, indent=2)}")
        else:
            print(f"Error: {response.text}")
    except requests.RequestException as e:
        print(f"Request failed: {e}")
    
    # Delete expense
    print(f"\n5. Deleting expense with ID {expense_id}...")
    try:
        response = requests.delete(f'{BASE_URL}/expenses/{expense_id}', headers=headers)
        print(f"Status Code: {response.status_code}")
        if response.status_code == 204:
            print("Expense deleted successfully")
        else:
            print(f"Error: {response.text}")
    except requests.RequestException as e:
        print(f"Request failed: {e}")

if __name__ == '__main__':
    print("Starting API tests...")
    print("Make sure Flask server is running at http://localhost:5000")
    
    # Test categories first (doesn't require authentication)
    categories = test_categories()
    
    # Test user authentication flow
    user_info = test_user_flow()
    
    # Test expenses with the authenticated user
    if user_info and categories:
        test_expenses(user_info, categories)
    
    print("\nAPI tests completed!") 