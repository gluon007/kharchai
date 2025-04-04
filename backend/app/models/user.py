from datetime import datetime
from werkzeug.security import generate_password_hash, check_password_hash

class User:
    def __init__(self, id=None, username=None, email=None, password_hash=None, created_at=None):
        self.id = id
        self.username = username
        self.email = email
        self.password_hash = password_hash
        self.created_at = created_at if isinstance(created_at, datetime) else datetime.utcnow()

    @property
    def password(self):
        raise AttributeError('password is not a readable attribute')

    @password.setter
    def password(self, password):
        self.password_hash = generate_password_hash(password)

    def verify_password(self, password):
        return check_password_hash(self.password_hash, password)

    def to_dict(self):
        return {
            'id': self.id,
            'username': self.username,
            'email': self.email,
            'created_at': self.created_at.isoformat() if self.created_at else None
        }

    @staticmethod
    def from_dict(data):
        created_at = data.get('created_at')
        if isinstance(created_at, str):
            created_at = datetime.fromisoformat(created_at)
        elif not isinstance(created_at, datetime):
            created_at = datetime.utcnow()
            
        return User(
            id=data.get('id'),
            username=data.get('username'),
            email=data.get('email'),
            password_hash=data.get('password_hash'),
            created_at=created_at
        ) 