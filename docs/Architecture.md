# Architecture.md

## 1. System Overview

**Sayahat** is a mobile tourism application designed to help users explore Kazakhstan through interactive maps, location-based information, and route planning.  

The system follows a **client–server architecture**, where:

- **Client:** Flutter mobile application (iOS/Android)  
- **Server:** Python Flask backend (handles user profile management)  

The system also integrates **external APIs** for weather and routing information, and uses **Firebase Authentication** for user login.

---

## 2. Components

### 2.1 Frontend (Flutter)
- **Purpose:** Handles all UI, user interaction, map display, route planning, weather display, and authentication.  
- **Key Features:**
  - Reads static place data from `assets/places.json`
  - Calls external APIs directly: OpenWeatherMap, OpenRouteService
  - Manages Firebase Authentication
  - Sends requests to Flask backend for user profile operations
- **Technology:** Flutter (Dart)  
  - Justification: Cross-platform mobile development, strong support for maps, localization, and offline assets.

### 2.2 Backend (Flask)
- **Purpose:** Manages user profile data and uploaded profile images.  
- **Endpoints:**
  - `GET /about_me/<user_id>` → fetch user profile info
  - `POST /about_me/<user_id>` → update user profile info
  - `POST /upload_profile_image/<user_id>` → upload profile image
  - `GET /profile_image/<user_id>` → fetch profile image (default avatar if none exists)
  - `DELETE /delete_profile_image/<user_id>` → delete profile image
- **Storage:** 
  - JSON file (`about_me.json`) for user profiles
  - Folder `profile_images/` for profile pictures
- **Technology:** Python Flask  
  - Justification: Lightweight, simple REST API support for profile operations

### 2.3 External Services
- **Firebase Authentication:** Handles user login and registration
- **OpenWeatherMap API:** Provides weather information
- **OpenRouteService API:** Provides route planning information

### 2.4 Assets / Storage
- **Flutter assets:** Static place data (`places.json`) and images  
- **JSON-based storage:** User profile data on backend  
- **Profile images:** Stored in `profile_images/` folder on backend

---

## 3. System Architecture Diagram

flowchart TB
    subgraph Flutter_Client
        A[Map & Places] --> B[Weather API]
        A --> C[Route API]
        D[Profile Screens] --> E[Flask Backend]
        F[Firebase Auth] --> D
    end

    subgraph Flask_Backend
        E --> G[about_me.json]
        E --> H[profile_images/]
    end

    A -->|Reads directly| I[assets/places.json]



---

## 4. Data Flow

1. **Authentication:**  
   - User logs in through Firebase in Flutter → receives token → token stored in app for session management.

2. **Places & Maps:**  
   - Flutter reads `assets/places.json` locally → displays markers and information on the map.

3. **Weather & Routes:**  
   - Flutter calls OpenWeatherMap API for weather info at selected location.  
   - Flutter calls OpenRouteService API for route planning between locations.

4. **User Profile:**  
   - Flutter sends GET/POST requests to Flask backend for profile data (`about_me.json`) and profile images (`profile_images/`).  
   - Flask reads/writes JSON and image files, then responds to Flutter with updated data.

---

## 5. Technologies & Justifications

| Component | Technology | Reason |
|-----------|-----------|--------|
| Frontend | Flutter (Dart) | Cross-platform, fast development, offline asset support |
| Backend | Flask (Python) | Lightweight REST API, easy integration with JSON storage |
| Authentication | Firebase Auth | Secure, scalable, easy integration with Flutter |
| Weather API | OpenWeatherMap | Reliable weather data for Kazakhstan locations |
| Route API | OpenRouteService | Accurate routing with multiple options |
| Data storage | JSON + Flutter assets | Simple, no database required for MVP |
| Images | Local folder (`profile_images/`) | Simple file-based storage for user-uploaded images |

---

## 6. Storage / Database

- **JSON files:** `about_me.json` stores user profiles in key-value format.  
- **Flutter assets:** `places.json` stores place info with fields like name, description, coordinates.  
- **Profile images:** Stored as PNG/JPG in `profile_images/` folder

**Example JSON structure (about_me.json):**
```json
{
  "user123": "I love traveling in Kazakhstan!",
  "user456": "Tour guide and explorer."
}

---

## 7. Potential Future Extensions

- Switch JSON-based storage to a **real database** (SQL or NoSQL)  
- Add **favorites, reviews, and ratings** for places  
- Implement **push notifications** for events or route suggestions  
- Add **analytics dashboard** for user behavior tracking  
- Extend backend to handle more **dynamic place data**
