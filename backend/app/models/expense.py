from datetime import datetime

class Expense:
    def __init__(self, id=None, user_id=None, amount=None, category_id=None, description=None, date=None, created_at=None):
        self.id = id
        self.user_id = user_id
        self.amount = amount
        self.category_id = category_id
        self.description = description
        self.date = date if isinstance(date, datetime) else datetime.utcnow()
        self.created_at = created_at if isinstance(created_at, datetime) else datetime.utcnow()

    def to_dict(self):
        return {
            'id': self.id,
            'user_id': self.user_id,
            'amount': self.amount,
            'category_id': self.category_id,
            'description': self.description,
            'date': self.date.strftime('%Y-%m-%d %H:%M:%S') if self.date else None,
            'created_at': self.created_at.strftime('%Y-%m-%d %H:%M:%S') if self.created_at else None
        }

    @staticmethod
    def from_dict(data):
        return Expense(
            id=data.get('id'),
            user_id=data.get('user_id'),
            amount=data.get('amount'),
            category_id=data.get('category_id'),
            description=data.get('description'),
            date=datetime.strptime(data['date'], '%Y-%m-%d %H:%M:%S') if data.get('date') else None,
            created_at=datetime.strptime(data['created_at'], '%Y-%m-%d %H:%M:%S') if data.get('created_at') else None
        ) 