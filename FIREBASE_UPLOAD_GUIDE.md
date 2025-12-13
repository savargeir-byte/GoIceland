# 🔥 Firebase Upload Guide - GO ICELAND

## ✅ Files Ready for Upload

Located in `travel_super_app/` directory:

- **firestore_places.json** (13 POIs - waterfalls, glaciers, hot springs, etc.)
- **firestore_trails.json** (404 hiking trails from OSM)

## 📤 Upload Steps (Firebase Console)

### Step 1: Upload Places

1. Go to: https://console.firebase.google.com/project/go-iceland-c12bb/firestore
2. Click **Start collection** (or go to existing `places` collection)
3. Click three-dot menu ⋮ → **Import data**
4. Select `firestore_places.json`
5. Choose **Auto-generate IDs** (or use document IDs from file)
6. Click **Import**

### Step 2: Upload Trails

1. In Firestore, click **Start collection** (or go to existing `trails` collection)
2. Click three-dot menu ⋮ → **Import data**
3. Select `firestore_trails.json`
4. Choose **Auto-generate IDs** (or use document IDs from file)
5. Click **Import**

## 🎯 Expected Results

### Places Collection (13 documents)

- Skógafoss, Gullfoss, Seljalandsfoss
- Blue Lagoon, Jökulsárlón, Svartifoss
- Þingvellir, Geysir, Dettifoss, Goðafoss
- Kerið, Reynisfjara, Dyrhólaey

Each with:

- ✅ Icelandic Wikipedia descriptions
- ✅ Services (parking, toilet, restaurant, etc.)
- ✅ Visit info (best time, crowds, duration, entry fee)
- ✅ Images (hero, thumbnail, gallery)
- ✅ Ratings (Google, TripAdvisor)
- ✅ Sources (OSM, Wikipedia links)

### Trails Collection (404 documents)

- Famous: Laugavegur (136km), Fimmvörðuháls (59km), Kjalvegur (20km)
- Popular: Glymur (6km), Reykjavegur (101km), Hornstrandir routes
- Skaftafell trails: Svartifoss, Kristínartindar, etc.
- Total: 272 easy, 98 moderate, 16 challenging, 18 expert

Each with:

- ✅ Full polyline coordinates for map rendering
- ✅ Distance, duration, elevation
- ✅ Difficulty classification
- ✅ Start/end points with coordinates
- ✅ Region assignment
- ✅ Surface type, SAC scale
- ✅ Sources (OSM relation/way IDs)

## 🔧 Alternative Upload Methods

### Option B: Firebase CLI

```bash
cd travel_super_app
firebase use go-iceland-c12bb
firebase firestore:import firestore_places.json --collection places
firebase firestore:import firestore_trails.json --collection trails
```

### Option C: Node.js Script (if you have Admin SDK key)

```bash
cd travel_super_app
npm install firebase-admin
node upload_data.js
```

## ✅ Verification Steps

After upload:

1. Check Firestore → `places` collection → should have 13 documents
2. Check Firestore → `trails` collection → should have 404 documents
3. Click any place → verify `description.short`, `media.hero_image`, `services`, `visit_info` fields
4. Click any trail → verify `polyline` array, `distance_km`, `difficulty`, `start`, `end` fields

## 🎉 What's Next?

Once data is uploaded:

1. ✅ Update Flutter app to use PoiModelFull
2. ✅ Integrate PlaceDetailFull widget
3. ✅ Create TrailDetailFull widget
4. ✅ Add trail list screen
5. ✅ Render trail polylines on map
6. ✅ Build APK and test on phone

## 📊 Statistics

- **Total Locations:** 417 (13 POIs + 404 trails)
- **Trail Distance:** 2,743.8 km total
- **Data Sources:** OSM (ODbL), Wikipedia (CC-BY-SA), Unsplash, Wikimedia
- **Enrichment Date:** 2025-12-13
- **Languages:** Icelandic (primary), English (fallback)

---

**GO ICELAND - Best hiking app á Íslandi** 🏔️🇮🇸
