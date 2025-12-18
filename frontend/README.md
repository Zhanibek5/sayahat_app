# Sayahat

## Overview
Sayahat is a mobile tourism application designed to help tourists and local users explore Kazakhstan through an interactive map and location-based information. The application provides detailed descriptions of places, audio guides, route planning, and weather information in multiple languages.

## Problem and Solution
The product solves the problem of fragmented tourist information, language barriers, and difficulties in navigating attractions across Kazakhstan.

## Target Users
The target user group includes foreign tourists, local travelers, students, and anyone interested in exploring Kazakhstan.

## Tech Stack
List of main technologies:
- **Front end:** Flutter (Dart)

- **Back end / Services:** Firebase (Authentication), Python (Flask)

- **APIs:** OpenStreetMap API, OpenWeatherMap API, OpenRouteService API

- **Localization:** easy_localization with JSON files (kk.json, ru.json, en.json)

- **Data / Content:** JSON files (assets/places.json) with place information

- **Other tools:** Git, GitHub

## Project Structure

The project is organized into separate frontend and backend components,
with shared documentation at the root level.


```
sayahat_app/
│
├── frontend/                              # Flutter mobile application (client side)
│   │
│   ├── android/                          # Android-specific configuration and build files
│   ├── ios/                              # iOS-specific configuration and build files
│   │
│   ├── assets/                           # Static assets used in the application
│   │   ├── translations/                # Localization JSON files (Kazakh, Russian, English)
│   │   ├── images/                      # Images used in the UI
│   │   └── places.json                  # Static data about places and landmarks
│   │
│   ├── lib/                              # Main Dart source code
│   │   │
│   │   ├── firstPage/                   # Onboarding and splash screens
│   │   │   ├── loadingPage.dart          # Initial loading screen
│   │   │   └── pageView.dart             # Introduction and onboarding pages
│   │   │
│   │   ├── loginPage/                   # Authentication and user account management
│   │   │   ├── app_data.dart             # Global app state and shared data
│   │   │   ├── app_loading_page.dart     # Loading screen during authentication
│   │   │   ├── auth_layout.dart          # Layout for authentication screens
│   │   │   ├── auth_service.dart         # Firebase authentication logic
│   │   │   ├── change_password_page.dart # Change user password screen
│   │   │   ├── delete_account_page.dart  # Delete user account functionality
│   │   │   ├── login_page.dart           # User login screen
│   │   │   ├── register_page.dart        # User registration screen
│   │   │   ├── reset_password_page.dart  # Password reset functionality
│   │   │   └── verify_email.dart         # Email verification screen
│   │   │
│   │   ├── secondPage/                  # Main application screens after login
│   │   │   ├── about_me_page.dart        # User information screen
│   │   │   ├── edit_profile_page.dart    # Profile editing screen
│   │   │   ├── info.dart                 # General information page
│   │   │   ├── loading.dart              # General-purpose loading widget
│   │   │   ├── mainPage.dart             # Main navigation and home screen
│   │   │   ├── map.dart                  # Interactive map with places and routes
│   │   │   ├── profile.dart              # User profile screen
│   │   │   ├── setting.dart              # Application settings page
│   │   │   └── settings_provider.dart    # State management for settings
│   │   │
│   │   ├── firebase_options.dart         # Firebase project configuration
│   │   └── main.dart                     # Flutter application entry point
│   │
│   ├── pubspec.yaml                     # Flutter dependencies and asset definitions
│   └── README.md                        # Frontend setup and usage documentation
│
├── backend/                             # Python Flask backend (server side)
│   │
│   ├── .venv/                           # Python virtual environment (not committed)
│   │
│   │── server.py                        # Flask server entry point
│   |── about_me.json                    # User-related data served by the API
│   │   
│   │
│   ├── profile_images/                  # Uploaded user profile images
│   └── static/                          # avatar.png on the pofile
│   
│
├── .env.example                         # Global environment variable template
│
├── docs/                                # Project documentation
│   ├── User_Stories.md                  # User scenarios and use cases
│   ├── Architecture.md                  # System architecture description
│   ├── PRD.md                           # Product Requirements Document
│   └── API.md                           # API specification and endpoints
│
└── README.md                            # Main project overview and instructions

```
## How to Run the Project Locally

The project consists of two parts:
1. Backend server (Python Flask)
2. Mobile client (Flutter)

The backend server must be started first.  
After that, the server IP address must be configured in the Flutter application.

---

### System Requirements

**Backend (Server):**
- Python 3.9 or higher  
- pip (Python package manager)  
- Flask  

**Frontend (Mobile App):**
- Flutter SDK 3.x or higher  
- Dart SDK  
- Android Studio or Visual Studio Code  
- Android/IOS Emulator or physical Android/IOS device  

### Installation and Run Steps

#### 1. Clone the Repository

```bash
git clone <repository_url>
cd sayahat_app
```
#### 2. Run Backend (Flask Server)

Navigate to the backend directory:
```
cd backend
```
Create and activate a virtual environment (recommended):
```
python -m venv venv
source venv/bin/activate   # macOS / Linux
venv\Scripts\activate      # Windows
```
Install required dependencies:
```
pip install -r requirements.txt
```
Run the Flask server:
```
python server.py
```
The server will start on:
```
http://127.0.0.1:5000
```

#### 3. Configure Server IP in Flutter

Open the Flutter project and update the server IP address
(for example, in a constants or service file):
```
const String serverIp = "http://127.0.0.1:5000";
```
Make sure the emulator or device can access the server.

#### 4. Run Flutter Application

Navigate to the Flutter project root:
```
cd frontend
```
Install dependencies:
```
flutter pub get
```
Ensure that an emulator or physical device is connected:
```
flutter devices
```
Run the application:
```
flutter run
```

## How to Run Tests

#### Backend Tests (Flask)

If backend tests are implemented, run:
```
pytest
```
#### Frontend Tests (Flutter)

The Flutter application uses the built-in Flutter testing framework.

To run all tests:
```
flutter test
```
Test results will be displayed in the terminal.





