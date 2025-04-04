from flask import Blueprint

# Create blueprints
auth_bp = Blueprint('auth', __name__)
expense_bp = Blueprint('expense', __name__)

# Import routes after blueprint creation to avoid circular imports
from . import auth, expense 