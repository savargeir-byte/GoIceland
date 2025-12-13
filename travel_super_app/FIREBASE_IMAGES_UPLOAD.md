# 🖼️ Firebase Image Upload Instructions

## Problem

App er að sækja gögn úr Firebase en það eru engar myndir í Firestore.

## Solution

Við þurfum að uploada places með Unsplash myndum í Firebase.

## Option 1: Manual Import (Firebase Console) ⭐ EASIEST

1. Opnaðu Firebase Console: https://console.firebase.google.com
2. Veldu project: `travel-super-app` (eða hvað sem hann heitir)
3. Farðu í **Firestore Database**
4. Smelltu á **Import/Export** efst
5. Veldu **Import data**
6. Veldu file: `places_with_images.json` (í þessari möppu)
7. Collection: `places`
8. Smelltu **Import**

✅ **Done!** Myndir ættu núna að virka.

## Option 2: Node.js Script (Firebase Admin SDK)

### Setup

```powershell
# Install dependencies
npm install firebase-admin

# Download service account key from Firebase Console:
# Project Settings > Service Accounts > Generate new private key
# Save as: serviceAccountKey.json
```

### Run

```powershell
node upload_places.js
```

## Option 3: Update Existing Documents

Ef þú vilt bara bæta myndum við existing documents:

1. Opnaðu Firebase Console
2. Farðu í Firestore Database > places collection
3. Fyrir hvert document:
   - Smelltu á document ID
   - Bættu við field: `image` (string)
   - Value: `https://images.unsplash.com/photo-XXXXX?w=800`
   - Bættu við field: `images` (array)
   - Value: `["https://images.unsplash.com/photo-XXXXX?w=800"]`

## Verify Images Work

Eftir upload:

```powershell
# Rebuild APK
flutter build apk --release

# Install on phone
adb install build/app/outputs/flutter-apk/app-release.apk

# Check logs
adb logcat -d | Select-String "Image"
```

## Sample Image URLs (Unsplash - Free)

```
Waterfalls:
- https://images.unsplash.com/photo-1520208422220-d12a3c588e6c?w=800
- https://images.unsplash.com/photo-1504893524553-b855bce32c67?w=800

Blue Lagoon:
- https://images.unsplash.com/photo-1578271887552-5ac3a72752bc?w=800

Geysir:
- https://images.unsplash.com/photo-1551632436-cbf8dd35adfa?w=800

Beach:
- https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800
```

## Check Current Firestore Data

Til að sjá hvað er í Firebase núna:

```dart
// Run in Flutter debug console
import 'package:cloud_firestore/cloud_firestore.dart';
final snap = await FirebaseFirestore.instance.collection('places').limit(1).get();
print(snap.docs.first.data());
```

## PoiModel Structure

App leitar að myndum í þessari röð:

1. `images` array → tekur fyrstu mynd: `images[0]`
2. `image` string

Báðar útgáfur eru í `places_with_images.json`.
