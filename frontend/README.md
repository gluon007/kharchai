# KharchAI - Frontend

This is the frontend of the KharchAI project, an AI-powered expense tracking system.

## Features

- User authentication (login/register)
- Expense tracking with categories
- Analytics and visualizations
- Settings and user profile management

## Getting Started

### Prerequisites

- Flutter SDK (3.0 or higher)
- Dart SDK
- Android Studio or VS Code with Flutter extensions

### Installation

1. Clone the repository:
```
git clone https://github.com/yourusername/kharchai.git
cd kharchai/frontend
```

2. Install dependencies:
```
flutter pub get
```

3. Create a `.env` file at the root of the frontend directory with the following content:
```
API_URL=http://localhost:5000/api/v1
```

4. Create the `assets/images` directory:
```
mkdir -p assets/images
```

5. Run the application:
```
flutter run
```

## Project Structure

```
frontend/
├── lib/
│   ├── api/          # API services
│   ├── models/       # Data models
│   ├── providers/    # State management
│   ├── screens/      # UI screens
│   ├── utils/        # Utility classes
│   ├── widgets/      # Reusable widgets
│   └── main.dart     # Entry point
├── assets/
│   └── images/       # Images and icons
├── pubspec.yaml      # Dependencies
└── .env              # Environment variables
```

## Dependencies

- provider: State management
- http: Network requests
- shared_preferences: Local storage
- intl: Date formatting
- fl_chart: Charts and visualizations
- url_launcher: Opening URLs
- flutter_dotenv: Environment variables

## Connecting to Backend

By default, the app will try to connect to a backend server running at http://localhost:5000/api/v1. Make sure the backend server is running before using the app. You can change the API URL in the `.env` file.

## Future Enhancements

- Voice input for expense entry
- Receipt scanning using camera
- Budget planning and alerts
- Multiple currencies support
- Dark mode

## License

This project is licensed under the MIT License - see the LICENSE file for details.
