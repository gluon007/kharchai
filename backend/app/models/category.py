from datetime import datetime

class Category:
    def __init__(self, id=None, name=None, description=None, created_at=None):
        self.id = id
        self.name = name
        self.description = description
        self.created_at = created_at if isinstance(created_at, datetime) else datetime.utcnow()

    def to_dict(self):
        return {
            'id': self.id,
            'name': self.name,
            'description': self.description,
            'created_at': self.created_at.strftime('%Y-%m-%d %H:%M:%S') if self.created_at else None
        }

    @staticmethod
    def from_dict(data):
        return Category(
            id=data.get('id'),
            name=data.get('name'),
            description=data.get('description'),
            created_at=datetime.strptime(data['created_at'], '%Y-%m-%d %H:%M:%S') if data.get('created_at') else None
        ) 