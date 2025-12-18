# API Specification

This document provides a complete specification of the backend API, describing all available endpoints, HTTP methods, request parameters, example request/response formats, error codes, and authentication rules used in the Sayahat mobile application.

---

## Authentication

User authentication (Sign Up / Sign In) is handled **only by Firebase Authentication (Email & Password)** on the client side (Flutter).

- The Python backend **does NOT** handle authentication
- No passwords are stored or processed by the backend
- API endpoints are used after successful Firebase authentication

---

## API Overview

The Python backend server is responsible **only for the following operations**:

1. Image upload, retrieval, and deletion (stored in server folders)
2. User profile information storage and retrieval (stored in JSON files)

> ⚠️ Tourist places data, localization files (kk.json, ru.json, en.json), and application images are stored **locally in Flutter assets** and are **not managed by the backend API**.

---

## Endpoint: /api/images

### Method: POST

**Purpose:**
Uploads an image file to the server and stores it in the image folder.

**Request:**
- Content-Type: `multipart/form-data`

**Request Body:**
| Field | Type | Description |
|------|------|-------------|
| image | File | Image file to upload |

**Response (example):**
```json
{
  "message": "Image uploaded successfully",
  "filename": "image_123.jpg"
}
```

**Error Codes:**
- **400** – No image provided
- **500** – Failed to save image

---

### Method: GET

**Purpose:**
Retrieves a list of uploaded images.

**Response (example):**
```json
{
  "images": [
    "image_123.jpg",
    "image_124.png"
  ]
}
```

**Error Codes:**
- **500** – Failed to read image directory

---

### Method: DELETE

**Endpoint:** /api/images/{filename}

**Purpose:**
Deletes a specific image from the server folder.

**Path Parameters:**
| Parameter | Type | Description |
|---------|------|-------------|
| filename | string | Name of the image file |

**Response (example):**
```json
{
  "message": "Image deleted successfully"
}
```

**Error Codes:**
- **404** – Image not found
- **500** – Failed to delete image

---

## Endpoint: /api/users

### Method: POST

**Purpose:**
Stores user profile information in a server-side JSON file.

**Request Body (example):**
```json
{
  "uid": "firebase_user_id",
  "name": "Zhanibek",
  "email": "user@example.com"
}
```

**Response (example):**
```json
{
  "message": "User data saved successfully"
}
```

**Error Codes:**
- **400** – Invalid user data
- **500** – Failed to write JSON file

---

### Method: GET

**Endpoint:** /api/users/{uid}

**Purpose:**
Retrieves user profile information from the JSON file.

**Path Parameters:**
| Parameter | Type | Description |
|---------|------|-------------|
| uid | string | Firebase user ID |

**Response (example):**
```json
{
  "uid": "firebase_user_id",
  "name": "Zhanibek",
  "email": "user@example.com"
}
```

**Error Codes:**
- **404** – User not found
- **500** – Failed to read JSON file

---

## Data Storage Summary

| Data Type | Storage Location | Managed By |
|----------|------------------|------------|
| User login (email/password) | Firebase Authentication | Firebase |
| User profile info | JSON file | Python Backend |
| Uploaded images | Server folder | Python Backend |
| Tourist places data | Flutter assets (JSON) | Flutter App |
| Localization (kk/ru/en) | Flutter assets (JSON) | Flutter App |
| App images | Flutter assets | Flutter App |

---

## Notes

- All API responses use JSON format
- Backend supports only GET, POST, and DELETE methods
- No database (SQL/Firestore) is used on the backend

---

## Conclusion

The Sayahat backend API is a lightweight Python-based service designed exclusively for image management and user profile data storage using JSON files. All authentication, localization, and tourist content are handled directly within the Flutter application, ensuring a simple and secure system architecture.


