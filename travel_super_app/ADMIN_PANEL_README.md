# 🔐 Firebase Admin Panel

Professional content management system for Go Iceland app.

## ✨ Features

### 🎯 Core Features

- **Role-Based Access Control**: Admin, Editor, Viewer roles
- **Multi-Language Content**: English, Chinese, Icelandic
- **Image Management**: Upload, set cover, delete images
- **Place Management**: Create, edit, delete places
- **Real-Time Updates**: Changes sync instantly to all devices

### 🌍 Multi-Language Support

Each place can have content in multiple languages:

```dart
content: {
  en: {
    description: "...",
    history: "...",
    tips: "..."
  },
  zh: {
    description: "...",
    history: "...",
    tips: "..."
  },
  is: {
    description: "...",
    history: "...",
    tips: "..."
  }
}
```

### 🖼️ Image Upload

- Upload images to Firebase Storage
- Set cover image for each place
- Manage image gallery
- Auto-backup compatibility fields

## 🚀 Setup Instructions

### 1. Install Dependencies

```bash
cd travel_super_app
flutter pub get
```

### 2. Create Admin User in Firestore

Go to Firebase Console → Firestore Database → `users` collection

Create a new document with your user ID (from Firebase Auth):

```json
{
  "email": "admin@goiceland.is",
  "role": "admin",
  "displayName": "Admin User",
  "updatedAt": "2024-01-15T12:00:00Z"
}
```

**Available Roles:**

- `admin` - Full access (manage users, places, categories)
- `editor` - Edit content (manage places, trails, collections)
- `viewer` - Read-only access

### 3. Deploy Firestore Security Rules

```bash
firebase deploy --only firestore:rules
```

This deploys the enhanced security rules with role-based access control.

### 4. Build Web Admin Panel (Optional)

For web-based admin panel:

```bash
flutter build web --release
firebase deploy --only hosting
```

Or run locally:

```bash
flutter run -d chrome
```

## 📱 Usage

### Access Admin Panel

**From Mobile App:**

1. Add admin route to your app routing
2. Navigate to `/admin/login`

**From Web:**

1. Deploy to Firebase Hosting
2. Visit: `https://your-app.web.app/admin`

### Login

1. Open admin login screen
2. Enter admin email and password
3. System checks user role in Firestore
4. If admin/editor → dashboard
5. If viewer → error message

### Manage Places

1. **View Places**: Dashboard → "Manage Places"
2. **Search**: Use search bar to find specific places
3. **Filter**: Click category chips to filter by type
4. **Edit**: Click place card to open editor

### Edit Place Content

1. Update basic info (name, category, region)
2. Upload images (cover + gallery)
3. Add multi-language descriptions:
   - Switch between EN/ZH/IS tabs
   - Fill in description, history, tips
4. Click "Save" button

### Upload Images

1. In place editor, click "Upload" button
2. Select image from device
3. Image uploads to Firebase Storage
4. URL saved to Firestore
5. Set as cover image via menu

## 🔐 Security Architecture

### Firestore Rules

```javascript
// Admins can do everything
function isAdmin() {
  return getUserData().role == 'admin';
}

// Editors can manage content
function isEditor() {
  return getUserData().role == 'admin' ||
         getUserData().role == 'editor';
}

// Places: Public read, Editor+ write
match /places/{placeId} {
  allow read: if true;
  allow create, update, delete: if isEditor();
}

// Users: Admin manages roles
match /users/{userId} {
  allow read: if isOwner(userId) || isAdmin();
  allow update: if isAdmin();  // Role management
}
```

### Role Management

**Only admins** can change user roles:

1. Go to Firebase Console
2. Firestore → `users` collection
3. Find user document
4. Update `role` field to: `admin`, `editor`, or `viewer`

## 📂 File Structure

```
lib/admin/
├── models/
│   ├── admin_user.dart       # User with role
│   └── admin_place.dart      # Place with multi-language content
├── services/
│   └── admin_service.dart    # Auth + Place management
├── screens/
│   ├── admin_login_screen.dart
│   ├── admin_dashboard_screen.dart
│   ├── places_list_screen.dart
│   └── place_edit_screen.dart
└── widgets/
    └── (reusable components)
```

## 🎨 Customization

### Add New Language

1. Update `place_edit_screen.dart`:

```dart
final Map<String, Map<String, TextEditingController>> _contentControllers = {
  'en': {...},
  'zh': {...},
  'is': {...},
  'de': {...},  // Add German
};
```

2. Add tab:

```dart
TabBar(
  tabs: [
    Tab(text: '🇬🇧 English'),
    Tab(text: '🇨🇳 Chinese'),
    Tab(text: '🇮🇸 Icelandic'),
    Tab(text: '🇩🇪 German'),  // Add here
  ],
)
```

### Add New Field

1. Update `AdminPlace` model
2. Add form field in `place_edit_screen.dart`
3. Update Firestore rules if needed

## 🐛 Troubleshooting

### "User not found in database"

**Solution**: Create user document in Firestore `users` collection with `role` field.

### "No permission to access admin panel"

**Solution**: Ensure user has `admin` or `editor` role in Firestore.

### Images not uploading

**Solution**: Check Firebase Storage rules:

```javascript
service firebase.storage {
  match /b/{bucket}/o {
    match /places/{placeId}/{fileName} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

### Can't deploy security rules

**Solution**:

```bash
firebase login
firebase use --add  # Select your project
firebase deploy --only firestore:rules
```

## 🎯 Best Practices

1. **Always set cover image** for better UX
2. **Fill all 3 languages** for international users
3. **Add descriptive history** to enrich content
4. **Tag services** (WiFi, parking, etc.)
5. **Set correct category** for filtering
6. **Add region** for geographic search

## 📊 Statistics

Current database:

- **Places**: 4,972
- **Trails**: 419
- **With Images**: 114
- **With Descriptions**: 55

Goal: Enrich all places with images and multi-language content!

## 🔗 Related Files

- Firestore Rules: `firestore.rules`
- Firebase Config: `firebase.json`
- Node.js Upload Script: `go_iceland/upload_all_places.js`
- Place Model: `lib/data/models/place_model.dart`

## 📞 Support

For issues or questions:

1. Check Firebase Console logs
2. Review Firestore security rules
3. Verify user roles in database
4. Test with different user accounts

---

**Built with ❤️ for Go Iceland**
