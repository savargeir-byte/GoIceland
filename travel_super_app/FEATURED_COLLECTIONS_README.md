# GO ICELAND - Featured Collections & Trails Implementation

## Yfirlit (Overview)

Þetta verkefni bætir við Featured Collections (Leið 2) með trails (gönguleiðir), Firestore samþættingu, og nýjum data models fyrir GO ICELAND appið.

## 📂 Nýjar skrár (New Files Created)

### Data Models

- **`lib/data/models/place_model.dart`**

  - PlaceModel fyrir POIs (waterfalls, hot springs, viewpoints, etc.)
  - Stuðningur við Firestore serialization
  - 42 staðir í Íslandi með metadata (region, rating, accessibility)

- **`lib/data/models/trail_model.dart`**
  - TrailModel fyrir gönguleiðir með polyline geometry
  - Difficulty ratings (Easy, Moderate, Hard, Expert)
  - 15 trails frá Laugavegur til Hvannadalshnjúkur
  - Helper methods: `formattedDuration`, `difficultyColor`

### UI Components

- **`lib/core/widgets/trail_cards.dart`**
  - **LargePlaceCard**: 320x240px kort fyrir Today's Picks með gradient overlay
  - **SmallPlaceCard**: 180px horizontal kort fyrir collections
  - **TrailListTile**: Trail card með difficulty badge, stats, mini map preview

### Features

- **`lib/features/trail/trail_map_view.dart`**

  - Full-screen Mapbox map view fyrir trails
  - Polyline rendering með start/end markers
  - Auto-fit camera to trail bounds
  - Trail info card með lengthKm, duration, elevation gain
  - "Byrja leið" floating action button
  - GPX download support (TODO)

- **`lib/features/explore/explore_feed_screen.dart`** (refactored)
  - **Today's Picks**: Large horizontal scrolling cards
  - **Nearby Wonders**: Small horizontal cards
  - **Trending**: Popular destinations
  - **Hidden Gems**: Off-the-beaten-path
  - **Hiking Trails**: Vertical list með TrailListTile
  - Firebase Firestore integration með real-time updates

### Seed Data

- **`assets/seed/places_seed.json`**

  - 42 Icelandic POIs (waterfalls, hot springs, villages, nature reserves)
  - Metadata: region, accessibility, parking fees, services
  - Examples: Seljalandsfoss, Jökulsárlón, Blue Lagoon, Hornstrandir

- **`assets/seed/trails_seed.json`**
  - 15 hiking trails with polyline coordinates
  - Examples: Laugavegurinn (55km, Hard), Fimmvörðuháls (25km, Expert)
  - Reykjadalur (6.8km, Easy), Glymur (7km, Moderate)

### Scripts

- **`scripts/seed-firestore.js`**

  - Node.js script using Firebase Admin SDK
  - Seeds places, trails, and collections to Firestore
  - Creates 6 curated collections:
    1. **todays_picks** - Featured destinations
    2. **nearby_wonders** - South Coast favorites
    3. **trending** - Popular right now
    4. **hidden_gems** - Hidden treasures
    5. **food_highlights** - Dining experiences
    6. **hiking_trails** - Trails for all levels

- **`scripts/README.md`**
  - Setup instructions for Firebase Admin SDK
  - How to download service account key
  - Usage: `node seed-firestore.js`
  - Firestore security rules examples

## 🗂️ Firestore Schema

```
/places/{placeId}
  - id: string
  - name: string (e.g., "Seljalandsfoss")
  - type: string (waterfall, hot_spring, viewpoint, etc.)
  - lat: number
  - lng: number
  - rating: number (optional, 0-5)
  - images: string[]
  - description: string
  - meta: {
      region: string (e.g., "Suðurland")
      accessibility: string (easy, moderate, difficult, expert)
      parkingFee: boolean
      entranceFee: boolean
      services: string[] (restaurant, hotel, gas_station, etc.)
    }

/trails/{trailId}
  - id: string
  - name: string (e.g., "Laugavegurinn")
  - difficulty: string (Easy, Moderate, Hard, Expert)
  - lengthKm: number
  - durationMin: number
  - elevationGain: number (meters)
  - startLat: number
  - startLng: number
  - gpxUrl: string (optional)
  - polyline: [{lat: number, lng: number}]
  - images: string[]
  - region: string

/collections/{collectionId}
  - id: string
  - name: string
  - description: string
  - placeIds: string[] (references to places)
  - trailIds: string[] (references to trails)
  - updatedAt: timestamp

/users/{userId}/saved_places/{placeId}
  - (existing structure for bookmarks)
```

## 🎨 UI Design - Featured Collections Layout

### Home Screen Structure:

```
┌─────────────────────────────────┐
│  Hero Banner (Weather + Aurora) │
│  Road Alert + Surprise Me       │
└─────────────────────────────────┘
┌─────────────────────────────────┐
│  Category Chips Row             │
│  All | Food | Photo | Nature... │
└─────────────────────────────────┘
┌─────────────────────────────────┐
│  Val dagsins (Today's Picks)    │
│  ┌───┐ ┌───┐ ┌───┐ ┌───┐      │ ← Large cards (320x240)
│  │ 1 │ │ 2 │ │ 3 │ │ 4 │ →    │
│  └───┘ └───┘ └───┘ └───┘      │
└─────────────────────────────────┘
┌─────────────────────────────────┐
│  Náttúruperlu í nágrenninu      │
│  ┌─┐ ┌─┐ ┌─┐ ┌─┐ ┌─┐ →        │ ← Small cards (180px)
│  │1│ │2│ │3│ │4│ │5│          │
│  └─┘ └─┘ └─┘ └─┘ └─┘          │
└─────────────────────────────────┘
┌─────────────────────────────────┐
│  Vinsælt núna                   │
│  ┌─┐ ┌─┐ ┌─┐ →                 │
│  │1│ │2│ │3│                   │
│  └─┘ └─┘ └─┘                   │
└─────────────────────────────────┘
┌─────────────────────────────────┐
│  🥾 Gönguleiðir í nágrenninu    │
│  ┌───────────────────────────┐  │
│  │ [img] Laugavegurinn       │  │ ← TrailListTile
│  │       55km | 4h | Hard    │  │
│  │       ↑1200m | Hálendið   │  │
│  └───────────────────────────┘  │
│  ┌───────────────────────────┐  │
│  │ [img] Reykjadalur         │  │
│  │       6.8km | 1.5h | Easy │  │
│  └───────────────────────────┘  │
└─────────────────────────────────┘
```

### Card Design:

- **Large cards**: Rounded 24px, gradient overlay, location + rating badges
- **Small cards**: Rounded 18px, compact image + text
- **Trail cards**: 80x80 thumbnail, difficulty pill (color-coded), stats row

### Animations:

- Cards slide in from right with 100ms stagger delay
- On tap → navigate to detail screen or TrailMapView
- Trail polyline animates on map load

## 📦 Dependencies (already in pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^3.10.1
  cloud_firestore: ^5.6.1
  firebase_auth: ^5.3.4
  mapbox_maps_flutter: ^2.8.0 # For trail polylines
  # ... existing dependencies
```

## 🚀 Setup Instructions

### 1. Run Firestore Seed Script:

```bash
cd scripts
npm install firebase-admin
# Place serviceAccountKey.json in scripts/
node seed-firestore.js
```

Expected output:

```
🚀 Starting Firestore seed...

🌍 Seeding 42 places...
✅ Places seeded successfully
🥾 Seeding 15 trails...
✅ Trails seeded successfully
📚 Creating curated collections...
✅ Collections created successfully

🎉 All data seeded successfully!

📊 Summary:
   Places: 42
   Trails: 15
   Collections: 6
```

### 2. Update pubspec.yaml (if needed):

Add assets for trail images:

```yaml
flutter:
  assets:
    - assets/images/
    - assets/seed/
    - assets/icons/pin_start.png # TODO: Create start marker icon
    - assets/icons/pin_end.png # TODO: Create end marker icon
```

### 3. Firestore Security Rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /places/{placeId} {
      allow read: if true;
      allow write: if false;
    }

    match /trails/{trailId} {
      allow read: if true;
      allow write: if false;
    }

    match /collections/{collectionId} {
      allow read: if true;
      allow write: if false;
    }

    match /users/{userId}/saved_places/{placeId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### 4. Test the App:

```bash
flutter run -d chrome
```

Navigate to:

- **Home** → See existing POI cards (will be upgraded to collections in next step)
- **Explore** → New collections layout with Today's Picks, trails section
- Tap on trail → Opens TrailMapView with polyline

## 🎯 Next Steps (TODO)

### High Priority:

1. **Refactor Home Screen** (`premium_home_screen.dart`)

   - Replace current POI ListView with Featured Collections layout
   - Add category chips row (All, Food, Photo, Nature, etc.)
   - Integrate Today's Picks, Nearby Wonders sections

2. **Add Trail Images**

   - Create/download trail thumbnail images
   - Add to `assets/images/trails/`
   - Update seed data with image paths

3. **Create Start/End Marker Icons**

   - Design pin_start.png and pin_end.png
   - Export at 1x, 2x, 3x for different screen densities
   - Place in `assets/icons/`

4. **Road & Weather Alerts**
   - Integrate Vegagerðin API for Iceland road conditions
   - Add alert banner in PremiumWeatherBanner
   - Show live notices for volcanic areas

### Medium Priority:

5. **Place Detail Screen**

   - Create full detail view for places
   - Show all images, description, opening hours, fees
   - Add navigation button (launch Google Maps/Apple Maps)

6. **User Location & Distance**

   - Get user's current location
   - Calculate distance to places
   - Sort "Nearby Wonders" by actual distance

7. **GPX Download**

   - Implement GPX file download in TrailMapView
   - Store GPX files in Firebase Storage
   - Add "Export to Komoot/AllTrails" option

8. **Daily Collection Rotation**
   - Create Cloud Function to rotate Today's Picks daily
   - Use trending algorithm based on user views
   - Update Firestore collections automatically

### Low Priority:

9. **Static Map Previews**

   - Generate static Mapbox images for trail cards
   - Cache in Firebase Storage
   - Show mini map instead of placeholder

10. **Search & Filters**
    - Add search bar for places and trails
    - Filter by difficulty, length, region
    - Sort by popularity, rating, distance

## 📊 Data Statistics

### Places (42 total):

- **Waterfalls**: 8 (Seljalandsfoss, Gullfoss, Dettifoss, etc.)
- **Hot Springs**: 6 (Blue Lagoon, Reykjadalur, Landmannalaugar, etc.)
- **Villages/Cities**: 6 (Vík, Höfn, Akureyri, Húsavík, etc.)
- **Nature Reserves**: 5 (Þingvellir, Hornstrandir, etc.)
- **Beaches**: 2 (Reynisfjara, Diamond Beach)
- **Glaciers**: 3 (Jökulsárlón, Snæfellsjökull, etc.)
- **Others**: 12 (Geysir, Hverfjall, Kerið, etc.)

### Trails (15 total):

- **Easy**: 4 (Reykjadalur 6.8km, Svartifoss 3.7km, Hverfjall 4.2km, Dyrhólaey 2km)
- **Moderate**: 3 (Glymur 7km, Esjan 6.4km, Valahnúkur 4.5km)
- **Hard**: 3 (Laugavegur 55km, Kerlingarfjöll 12km, etc.)
- **Expert**: 5 (Fimmvörðuháls 25km, Hornstrandir 50km, Hvannadalshnjúkur 22km, etc.)

### Geographic Coverage:

- **Suðurland (South)**: 14 places
- **Norðurland (North)**: 8 places
- **Austurland (East)**: 5 places
- **Vesturland (West)**: 6 places
- **Vestfirðir (Westfjords)**: 3 places
- **Hálendi (Highlands)**: 4 places
- **Höfuðborgarsvæðið (Capital Region)**: 2 places

## 🔍 Heimildir (Sources)

All data curated from official sources:

1. **Visit Iceland** - Official tourism info
   https://www.visiticeland.com

2. **Guide to Iceland** - Top attractions and trails
   https://guidetoiceland.is

3. **Epic Iceland** - Comprehensive waterfall and hot spring lists
   https://epiceland.com

4. **Wikipedia** - List of waterfalls in Iceland
   https://en.wikipedia.org/wiki/List_of_waterfalls_in_Iceland

5. **Iceland with a View** - Hiking trails
   https://icelandwithaview.com

## 🐛 Known Issues

1. **Mapbox Token**: Trail map view requires valid Mapbox access token in .env
2. **Image Paths**: Currently using placeholder images - need actual trail photos
3. **GPX URLs**: Placeholder URLs - need to upload actual GPX files to Firebase Storage
4. **Distance Calculation**: "Nearby Wonders" not yet sorted by actual user distance

## 📝 Notes

- All place names and descriptions in Icelandic
- Coordinates verified from official sources
- Accessibility ratings based on trail difficulty and parking availability
- Some seasonal trails marked with `seasonalAccess: true`
- 4WD requirements marked with `requiresFourWheelDrive: true`

## ✅ Completed

- ✅ PlaceModel and TrailModel data classes
- ✅ 42 places seed data (waterfalls, hot springs, villages, etc.)
- ✅ 15 trails seed data with polylines
- ✅ TrailMapView with Mapbox polyline rendering
- ✅ Trail card components (LargePlaceCard, SmallPlaceCard, TrailListTile)
- ✅ Firestore seed script with 6 curated collections
- ✅ Explore Feed refactor with collections layout
- ✅ Real-time Firestore integration
- ✅ Difficulty badges with color coding
- ✅ Trail stats display (length, duration, elevation)

---

**Last Updated**: December 12, 2025
**Version**: 1.0.0
**Status**: Ready for testing (after Firestore seed)
