# KharchAI - AI-Powered Expense Tracking System

## Project Setup

### Prerequisites
- Python 3.8 or higher
- Flutter SDK
- MySQL Server
- Android Studio (for Flutter development)
- VS Code (recommended)

### Backend Setup
1. Create a virtual environment:
```bash
python -m venv venv
```

2. Activate the virtual environment:
- Windows:
```bash
venv\Scripts\activate
```
- Linux/Mac:
```bash
source venv/bin/activate
```

3. Install dependencies:
```bash
pip install -r requirements.txt
```

4. Set up environment variables:
Create a `.env` file in the backend directory with the following variables:
```
DATABASE_URL=mysql://username:password@localhost:3306/kharchai
GOOGLE_CLOUD_PROJECT=your-project-id
OPENAI_API_KEY=your-api-key
JWT_SECRET=your-secret-key
```

### Frontend Setup
1. Install Flutter SDK
2. Run Flutter doctor to verify installation:
```bash
flutter doctor
```

3. Install dependencies:
```bash
cd frontend
flutter pub get
```

### Database Setup
1. Create MySQL database:
```sql
CREATE DATABASE kharchai;
```

2. Run database migrations (will be added later)

## Running the Application

### Backend
```bash
cd backend
python app.py
```

### Frontend
```bash
cd frontend
flutter run
```

## Project Structure
```
kharchai/
├── backend/
│   ├── app/
│   │   ├── __init__.py
│   │   ├── models/
│   │   ├── routes/
│   │   ├── services/
│   │   └── utils/
│   ├── config/
│   ├── tests/
│   └── app.py
├── frontend/
│   ├── lib/
│   ├── assets/
│   └── pubspec.yaml
└── docs/
``` 