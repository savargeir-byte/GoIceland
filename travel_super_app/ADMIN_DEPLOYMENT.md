# 🚀 Admin Panel Deployment Guide

Complete guide to deploy the Firebase Management Console for Go Iceland.

## 📋 Prerequisites

- Flutter SDK installed
- Firebase CLI installed (`npm install -g firebase-tools`)
- Node.js 18+ installed
- Firebase project created (go-iceland)
- Firebase Admin SDK key downloaded

## 🎯 Quick Start (5 Minutes)

### Step 1: Create Admin User

```bash
cd travel_super_app/scripts
node create_admin_user.js
```

Follow the prompts:

- Email: your-email@example.com
- Password: (min 6 characters)
- Display Name: Your Name
- Role: 1 (Admin)

### Step 2: Deploy Security Rules

```bash
cd travel_super_app
firebase deploy --only firestore:rules
```

### Step 3: Run Admin Panel Locally

```bash
flutter run -d chrome --target lib/main_admin.dart
```

Open browser to `http://localhost:xxxxx` and login!

---

## 📱 Deployment Options

### Option A: Web Deployment (Recommended)

Deploy admin panel as web app on Firebase Hosting.

#### 1. Configure Firebase Hosting

Edit `firebase.json`:

```json
{
  "hosting": {
    "public": "build/web",
    "ignore": ["firebase.json", "**/.*", "**/node_modules/**"],
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ]
  }
}
```

#### 2. Build Web App

```bash
flutter build web --release --target lib/main_admin.dart
```

#### 3. Deploy to Firebase Hosting

```bash
firebase deploy --only hosting
```

#### 4. Access Admin Panel

Visit: `https://your-project.web.app`

**Security**: Set up Firebase Hosting custom domain with HTTPS.

---

### Option B: Desktop App

Build standalone desktop app for Windows/Mac.

#### Windows:

```powershell
flutter build windows --release --target lib/main_admin.dart
```

Executable: `build\windows\runner\Release\travel_super_app.exe`

#### macOS:

```bash
flutter build macos --release --target lib/main_admin.dart
```

App: `build/macos/Build/Products/Release/travel_super_app.app`

---

### Option C: Mobile Integration

Integrate admin panel into existing mobile app.

#### 1. Add Admin Route

Edit `lib/app.dart`:

```dart
import 'admin/screens/admin_login_screen.dart';
import 'admin/screens/admin_dashboard_screen.dart';

// In your route configuration
'/admin': (context) => const AdminLoginScreen(),
'/admin/dashboard': (context) => const AdminDashboardScreen(),
```

#### 2. Add Admin Navigation

```dart
// In your app drawer or settings
ListTile(
  leading: Icon(Icons.admin_panel_settings),
  title: Text('Admin Panel'),
  onTap: () {
    Navigator.pushNamed(context, '/admin');
  },
)
```

#### 3. Protect with Permissions

```dart
// Check if user is admin before showing option
FutureBuilder<AdminUser?>(
  future: AdminAuthService().getCurrentAdminUser(),
  builder: (context, snapshot) {
    if (snapshot.data?.isAdmin ?? false) {
      return ListTile(...); // Show admin option
    }
    return SizedBox.shrink();
  },
)
```

---

## 🔐 Security Configuration

### Firebase Authentication

Enable Email/Password authentication:

1. Firebase Console → Authentication → Sign-in method
2. Enable "Email/Password"
3. Save changes

### Firestore Security Rules

Already deployed, but to verify:

```bash
firebase deploy --only firestore:rules
```

Test rules in Firebase Console → Firestore → Rules tab → Simulator

### Storage Security Rules

Create `storage.rules`:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Only authenticated editors can upload
    match /places/{placeId}/{fileName} {
      allow read: if true;  // Public read
      allow write: if request.auth != null;  // Authenticated write
    }

    match /trails/{trailId}/{fileName} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

Deploy:

```bash
firebase deploy --only storage
```

---

## 👥 User Management

### Create Admin Users

**Method 1: Node.js Script (Recommended)**

```bash
cd scripts
node create_admin_user.js
```

**Method 2: Firebase Console**

1. Create user in Authentication
2. Copy UID
3. Go to Firestore → `users` collection
4. Create document with UID as document ID:

```json
{
  "email": "user@example.com",
  "displayName": "User Name",
  "role": "admin",
  "createdAt": <timestamp>,
  "updatedAt": <timestamp>
}
```

### Change User Role

1. Firebase Console → Firestore
2. Navigate to `users/{userId}`
3. Edit `role` field:
   - `admin` - Full access
   - `editor` - Content management
   - `viewer` - Read-only

### Revoke Access

1. Firebase Console → Authentication
2. Find user
3. Click "Disable user"

Or delete from Firestore:

```bash
# Firestore Console → users/{userId} → Delete document
```

---

## 🌐 Domain Configuration (Production)

### Set up Custom Domain

1. Firebase Console → Hosting → Add custom domain
2. Enter: `admin.goiceland.is`
3. Follow DNS verification steps
4. Wait for SSL certificate (up to 24 hours)

### Update CORS (if needed)

For image upload from custom domain:

```bash
gsutil cors set cors.json gs://your-bucket-name
```

`cors.json`:

```json
[
  {
    "origin": ["https://admin.goiceland.is"],
    "method": ["GET", "POST", "PUT", "DELETE"],
    "maxAgeSeconds": 3600
  }
]
```

---

## 📊 Monitoring & Logs

### View Authentication Logs

Firebase Console → Authentication → Users → Activity

### View Firestore Usage

Firebase Console → Firestore → Usage tab

### View Storage Usage

Firebase Console → Storage → Usage

### Error Tracking

Check browser console for client errors:

```javascript
// Enable verbose logging
localStorage.setItem("debug", "firebase:*");
```

---

## 🔄 Updates & Maintenance

### Update Admin Panel

1. Make code changes
2. Test locally:
   ```bash
   flutter run -d chrome --target lib/main_admin.dart
   ```
3. Build and deploy:
   ```bash
   flutter build web --release --target lib/main_admin.dart
   firebase deploy --only hosting
   ```

### Update Security Rules

1. Edit `firestore.rules`
2. Test in Firebase Console simulator
3. Deploy:
   ```bash
   firebase deploy --only firestore:rules
   ```

### Rollback

```bash
firebase hosting:clone SOURCE_SITE_ID:VERSION_ID DESTINATION_SITE_ID
```

---

## 🐛 Troubleshooting

### Can't Login

**Error**: "User not found in database"

**Solution**:

1. Verify user exists in Authentication
2. Check `users/{uid}` document exists in Firestore
3. Verify `role` field is set correctly

### Images Not Uploading

**Error**: "Permission denied"

**Solution**:

1. Check Storage rules allow authenticated writes
2. Verify user is authenticated
3. Check CORS configuration

### Security Rules Not Working

**Solution**:

1. Re-deploy rules:
   ```bash
   firebase deploy --only firestore:rules
   ```
2. Check Firebase Console → Firestore → Rules tab
3. Test in simulator

### Build Errors

```bash
# Clean build
flutter clean
flutter pub get

# Rebuild
flutter build web --release --target lib/main_admin.dart
```

---

## 📞 Support Checklist

Before asking for help:

- [ ] User document exists in Firestore
- [ ] User has correct role (`admin`, `editor`, or `viewer`)
- [ ] Security rules deployed successfully
- [ ] Firebase Authentication enabled
- [ ] Storage rules allow authenticated uploads
- [ ] Browser console shows no errors
- [ ] Firebase Console shows no quota limits

---

## 🎯 Production Checklist

Before going live:

- [ ] Create admin users
- [ ] Deploy Firestore security rules
- [ ] Deploy Storage security rules
- [ ] Test login with all roles (admin, editor, viewer)
- [ ] Test place creation/editing
- [ ] Test image upload
- [ ] Test multi-language content
- [ ] Set up custom domain (optional)
- [ ] Configure SSL certificate
- [ ] Test on multiple browsers
- [ ] Set up monitoring/alerts
- [ ] Document admin procedures
- [ ] Train content editors

---

## 📚 Additional Resources

- [Firebase Hosting Docs](https://firebase.google.com/docs/hosting)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/get-started)
- [Firebase Storage Rules](https://firebase.google.com/docs/storage/security)
- [Flutter Web Deployment](https://docs.flutter.dev/deployment/web)

---

**Ready to manage your Iceland content! 🇮🇸**
