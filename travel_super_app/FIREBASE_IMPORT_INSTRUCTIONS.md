# 🔥 FIREBASE IMPORT - Enriched Places

## ✅ Gögn tilbúin!

Ég bjó til **13 enriched places** með:

- 📝 Wikipedia lýsingum (frá is.wikipedia.org)
- 🖼️ Myndum (Unsplash + Wikimedia thumbnails)
- ⏰ Visit info (best time, duration, crowds)
- 🛠️ Services framework (ready for OSM tags)
- ⭐ Ratings

## 📤 HVERNIG Á AÐ UPLOADA Í FIREBASE

### Option 1: Firebase Console (EASIEST) ⭐

1. **Opnaðu Firebase Console:**

   ```
   https://console.firebase.google.com
   ```

2. **Veldu þitt project** (travel-super-app eða hvað sem það heitir)

3. **Farðu í Firestore Database:**

   - Left menu → Firestore Database

4. **Import data:**

   - **METHOD A - Manual document creation:**
     a. Click "Start collection" eða opna existing `places` collection
     b. Fyrir hvern place í `firebase_import_enriched.json`:

     - Click "Add document"
     - Document ID: Notaðu `id` field (t.d. `mock_skogafoss`)
     - Copy/paste fields frá JSON

   - **METHOD B - Firestore import tool (ef til staðar):**
     a. Click Import/Export efst
     b. Select `firebase_import_enriched.json`
     c. Target collection: `places`
     d. Click Import

5. **Verify:**
   - Skoðaðu nokkur documents
   - Athugaðu að `image`, `description`, `media` fields séu til

### Option 2: Node.js með Firebase Admin SDK

1. **Download service account key:**

   ```
   Firebase Console → Project Settings → Service Accounts
   → Generate new private key → Save as serviceAccountKey.json
   ```

2. **Install dependencies:**

   ```powershell
   cd c:\GitHub\Radio_App\GoIceland\travel_super_app
   npm install firebase-admin
   ```

3. **Create upload script:**

   Ég bjó til `upload_places.js` fyrir þig - þú þarft bara að:

   - Setja `serviceAccountKey.json` í `travel_super_app/` möppu
   - Keyra: `node upload_places.js`

4. **Run:**
   ```powershell
   node upload_places.js
   ```

### Option 3: Python með Firebase Admin (fyrir go_iceland/)

1. **Download service account key** (sama og að ofan)

   - Save as: `go_iceland/firebase/serviceAccountKey.json`

2. **Run:**
   ```powershell
   cd c:\GitHub\Radio_App\GoIceland\go_iceland
   python firebase/upload_to_firestore.py
   ```

## 📋 Hvað er í gögnunum?

**13 places:**

1. Skógafoss - waterfall
2. Gullfoss - waterfall
3. Seljalandsfoss - waterfall
4. Dettifoss - waterfall
5. Blue Lagoon - hot spring
6. Geysir - geyser
7. Jökulsárlón - glacier lagoon
8. Reynisfjara - beach
9. Diamond Beach - beach
10. Kirkjufell - viewpoint
11. Grillmarkaðurinn - restaurant
12. Dill Restaurant - restaurant
13. Reykjavík Roasters - cafe

**Hver place inniheldur:**

```json
{
  "id": "mock_skogafoss",
  "name": "Skógafoss",
  "type": "waterfall",
  "lat": 63.5321,
  "lon": -19.5117,

  "description": {
    "short": "Skógafoss er 60 metra hár foss...",
    "history": "Fossinn var friðlýstur árið 1987..."
  },

  "services": {
    "parking": false,
    "toilet": false,
    "wheelchair_access": false,
    ...
  },

  "visit_info": {
    "best_time": "May–September",
    "crowds": "Moderate",
    "entry_fee": false,
    "suggested_duration": "30-60 minutes"
  },

  "media": {
    "hero_image": "https://images.unsplash.com/...",
    "images": ["url1"],
    "thumbnail": "https://upload.wikimedia.org/..."
  },

  "ratings": {
    "google": 4.9,
    "tripadvisor": 4.8
  },

  "sources": ["osm", "wikipedia"],
  "wikipedia_url": "https://is.wikipedia.org/wiki/Skógafoss"
}
```

## 🚀 Eftir upload

1. **Rebuild app:**

   ```powershell
   cd c:\GitHub\Radio_App\GoIceland\travel_super_app
   flutter build apk --release
   ```

2. **Install on phone:**

   ```powershell
   adb install build/app/outputs/flutter-apk/app-release.apk
   ```

3. **Test:**
   - Opnaðu app
   - Browse places
   - Smelltu á Skógafoss
   - Þú ættir að sjá:
     ✅ Hero image
     ✅ Wikipedia lýsingu
     ✅ Visit info
     ✅ Services icons
     ✅ Image gallery

## 🔍 Debugging

**Ef myndir birtast ekki:**

```dart
// Check í Firebase Console:
places/mock_skogafoss
→ media.hero_image: "https://images.unsplash.com/..."
→ images: ["https://images.unsplash.com/..."]
```

**Ef lýsingar birtast ekki:**

```dart
// Check:
description.short: "Skógafoss er 60 metra hár..."
description.history: "Fossinn var friðlýstur..."
```

**Check app logs:**

```powershell
adb logcat -d | Select-String "Firebase|Image|POI"
```

## 📊 Næstu skref

1. ✅ Upload enriched data → Firebase
2. ⏳ Update app to use `PoiModelFull`
3. ⏳ Show detail screen with full info
4. ⏳ Test on phone
5. 🎯 Add more places (OSM pipeline)
6. 🎯 Add real services data (OSM tags)
7. 🎯 Add Google Places for restaurants

---

**File locations:**

- Enriched data: `c:\GitHub\Radio_App\GoIceland\go_iceland\data\iceland_enriched_full.json`
- Import ready: `c:\GitHub\Radio_App\GoIceland\travel_super_app\firebase_import_enriched.json`
- Upload script: `c:\GitHub\Radio_App\GoIceland\travel_super_app\upload_places.js`

**Auðveldast er að nota Firebase Console og copy/paste!** 📋
