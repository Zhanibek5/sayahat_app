# API Specification

This document provides a complete specification of the backend API, describing all available endpoints, HTTP methods, request parameters, example request/response formats, error codes, and authentication rules used in the Sayahat mobile application.

---

## Authentication

User authentication (Sign Up / Sign In) is handled **exclusively by Firebase Authentication (Email & Password)** on the client side (Flutter).

- The Python (Flask) backend **does not perform authentication**
- No passwords or tokens are stored or validated by the backend
- User identity is passed implicitly via `user_id` (Firebase UID) in API paths

---

## API Overview

The backend API is a lightweight **Flask-based service** responsible only for:

1. Managing user profile text ("About Me") stored in a JSON file
2. Uploading, retrieving, and deleting user profile images stored in server folders

> ℹ️ Tourist places data, localization files (`kk.json`, `ru.json`, `en.json`), and application images are stored in **Flutter assets** and are **not handled by this API**.

---

## Endpoint: /about_me/{user_id}

### Method: GET

**Purpose:**
Retrieve the "About Me" text of a specific user.

**Path Parameters:**
| Parameter | Type | Description |
|---------|------|-------------|
| user_id | string | Firebase user UID |

**Response (example):**
```json
{
  "aboutMe": "Hello! My name is Zhanibek"
}
```

**Error Codes:**
- **200** – Request successful (empty string if no data)

---

### Method: POST

**Purpose:**
Create or update the user's "About Me" text. If the text is empty, the existing value is deleted.

**Request Headers:**
```
Content-Type: application/json
```

**Request Body (example):**
```json
{
  "aboutMe": "Hello! My name is Zhanibek"
}
```

**Response (example):**
```json
{
  "status": "success",
  "aboutMe": "Hello! My name is Zhanibek"
}
```

**Error Codes:**
- **400** – Invalid or missing JSON body
- **500** – Failed to write to JSON file

---

## Endpoint: /upload_profile_image/{user_id}

### Method: POST

**Purpose:**
Upload or replace a user's profile image on the server.

**Request:**
- Content-Type: `multipart/form-data`

**Request Body:**
| Field | Type | Description |
|------|------|-------------|
| image | File | Profile image file |

**Response (example):**
```json
{
  "message": "Image uploaded successfully"
}
```

**Error Codes:**
- **400** – No image uploaded
- **500** – Failed to save image

---

## Endpoint: /profile_image/{user_id}

### Method: GET

**Purpose:**
Retrieve the user's profile image. If no image exists, a default avatar image is returned.

**Path Parameters:**
| Parameter | Type | Description |
|---------|------|-------------|
| user_id | string | Firebase user UID |

**Response:**
- Image file (`image/png`, `image/jpg`, or `image/jpeg`)

**Behavior:**
- Returns user image if found
- Returns `static/avatar.png` if no user image exists

**Error Codes:**
- **200** – Image returned successfully

---

## Endpoint: /delete_profile_image/{user_id}

### Method: DELETE

**Purpose:**
Delete the user's profile image from the server.

**Path Parameters:**
| Parameter | Type | Description |
|---------|------|-------------|
| user_id | string | Firebase user UID |

**Response (example):**
```json
{
  "success": true
}
```

**Error Codes:**
- **404** – Image file not found
- **500** – Failed to delete image

---

## Client-side JSON Data (Flutter Assets)

The following data files are stored locally in the Flutter application
and are not accessed through the backend API:

- Localization files: `assets/translations/kk.json`, `ru.json`, `en.json`
- Tourist places data: `assets/places.json`
- Static images: `assets/*.png`, `assets/*.jpg`

These files are bundled with the application and loaded using Flutter asset management.

#### Localization example 

**(kk.json)**

```json
{
	"username": "Пайдаланушы аты",
}
```
**(ru.json)**

```json
{
	"username": "Имя пользователя",
}
```
**(en.json)**

```json
{
	"username": "Username",
}
```
#### Places example (places.json)
```
{
		"name": {
			"kk": "Baiterek",
			"ru": "Байтерек",
			"en": "Baiterek"
		},
		"polygon": [
			{ "lat": 51.1282, "lon": 71.4303 },
			{ "lat": 51.1284, "lon": 71.4303 },
			{ "lat": 51.1284, "lon": 71.4307 },
			{ "lat": 51.1282, "lon": 71.4307 }
		],
		"description": {
			"kk": "Baiterek монументі...",
			"ru": "Монумент Байтерек...",
			"en": "Baiterek monument..."
		}
},
```
---

## Data Storage Summary

| Data Type | Storage Location | Managed By |
|---------|-----------------|------------|
| User authentication | Firebase Authentication | Firebase |
| About Me text | JSON file (`about_me.json`) | Flask Backend |
| Profile images | Server folder (`profile_images/`) | Flask Backend |
| Tourist places data | Flutter assets (JSON) | Flutter App |
| Localization files | Flutter assets (JSON) | Flutter App |
| App images | Flutter assets | Flutter App |

---

## Notes

- All API responses use **JSON** format unless returning image files
- Backend supports **GET, POST, and DELETE** methods only
- No SQL or NoSQL database is used on the backend

---

## Conclusion

This API provides a minimal and efficient backend for the Sayahat application, handling only user profile text and profile images, while authentication, localization, and main application content are fully managed on the client side using Firebase and Flutter assets.

