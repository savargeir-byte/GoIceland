# GO ICELAND - Firebase Data Pipeline

Complete guide for populating Firestore with 2000+ Icelandic POIs from OpenStreetMap.

## 📋 Overview

This pipeline consists of three stages:

1. **Fetch** - Download POIs from OpenStreetMap (2000-4500 locations)
2. **Transform** - Clean, categorize, and format for Firestore
3. **Upload** - Batch upload to Cloud Firestore

## 🛠️ Prerequisites

### 1. Python Environment

```bash
# Install required packages
pip install requests firebase-admin
```

### 2. Firebase Service Account Key

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select **go-iceland** project
3. Navigate to **Project Settings** > **Service Accounts**
4. Click **Generate New Private Key**
5. Save as `serviceAccountKey.json` in the `scripts/` directory

⚠️ **IMPORTANT**: Never commit `serviceAccountKey.json` to version control!

## 🚀 Full Pipeline Execution

### Step 1: Fetch POIs from OpenStreetMap

```bash
cd scripts
python fetch_iceland_pois.py
```

**What it does:**

- Queries Overpass API for all Iceland POIs
- Categories: waterfalls, geysers, hot springs, beaches, cliffs, caves, peaks, lakes, glaciers, viewpoints, attractions, museums, churches, monuments, ruins, villages, towns, hiking routes, nature reserves, lighthouses
- Output: `iceland_pois_raw.json` (~2000-4500 POIs)
- Duration: ~10-15 minutes (includes rate limiting)

**Sample output:**

```
✅ FETCH COMPLETE
Total POIs collected: 3247
Category breakdown:
  viewpoint                :  421
  waterfall                :  312
  peak                     :  287
  village                  :  198
  ...
```

### Step 2: Transform Data for Firestore

```bash
python transform_pois_for_firestore.py
```

**What it does:**

- Cleans and deduplicates POIs
- Assigns Iceland regions (Höfuðborgarsvæðið, Suðurland, Vesturland, etc.)
- Categorizes into GO ICELAND taxonomy
- Calculates quality scores
- Filters low-quality entries
- Output: `places_firestore.json` (Firestore-ready)

**Sample output:**

```
✅ Saved 2847 places to places_firestore.json
Top categories:
  viewpoint                :  398
  waterfall                :  289
  peak                     :  271
  ...
By region:
  Norðurland eystra        :  542
  Suðurland                :  487
  Austurland               :  398
  ...
```

### Step 3: Upload to Firestore

```bash
python upload_to_firestore.py
```

**Options:**

```bash
# Dry run (preview without uploading)
python upload_to_firestore.py --dry-run

# Custom batch size
python upload_to_firestore.py --batch-size 300

# Different collection name
python upload_to_firestore.py --collection test_places
```

**What it does:**

- Initializes Firebase Admin SDK
- Batch uploads POIs to `/places` collection
- Adds server timestamps
- Verifies upload
- Provides indexing recommendations

**Sample output:**

```
✅ Upload complete!
   Uploaded: 2847
   Failed: 0

🔍 Verifying upload...
   Total documents: 2847
   natural        :  1247
   tourism        :  892
   historic       :  412
   ...
```

## 📊 Firestore Structure

### `/places/{placeId}`

```javascript
{
  id: "osm_123456789",
  name: "Skógafoss",
  type: "natural",              // natural, tourism, historic, outdoor, place
  subtype: "waterfall",         // Specific category
  lat: 63.5321,
  lng: -19.5117,
  region: "Suðurland",
  popularity: 85,               // 0-100 score
  difficulty: null,             // For hiking routes only
  rating: null,                 // User reviews (populated later)
  images: [],                   // Photo URLs
  mapPreview: null,             // Map thumbnail
  gpxUrl: null,                 // For trails
  description: "...",
  wikipedia: "en:Skógafoss",
  website: "https://...",
  source: "osm",
  quality_score: 0.95,
  updatedAt: "2025-12-12T...",
  uploadedAt: Timestamp,
  meta: {
    icon: "💧",
    osm_id: 123456789,
    fetched_at: "2025-12-12T..."
  }
}
```

### `/trails/{trailId}` (Already seeded - 15 trails)

### `/collections/{collectionId}` (Already seeded - 6 collections)

## 🔐 Firestore Security Rules

The `firestore.rules` file is included. Deploy it:

```bash
firebase deploy --only firestore:rules
```

**Key rules:**

- **Places/Trails**: Public read, admin-only write
- **User data**: Owner read/write
- **Reviews**: Authenticated users can create, owners can update
- **Collections**: Public read, admin-only write

## 📈 Recommended Firestore Indexes

Create these composite indexes in Firebase Console:

1. `type + region + popularity (DESC)`
2. `subtype + region + popularity (DESC)`
3. `region + popularity (DESC)`
4. `type + popularity (DESC)`
5. `quality_score (DESC) + popularity (DESC)`

**How to create:**

1. Firestore Console → **Indexes** tab
2. Click **Add Index**
3. Collection: `places`
4. Add fields as listed above

## 🔄 Updating Data

### Re-fetch from OSM (monthly recommended)

```bash
# Full pipeline
python fetch_iceland_pois.py
python transform_pois_for_firestore.py
python upload_to_firestore.py
```

### Manual seed script (42 places + 15 trails)

```bash
cd scripts
npm install firebase-admin
node seed-firestore.js
```

## 🎯 Data Quality

### Filtering criteria:

- ✅ Has name
- ✅ Has coordinates
- ✅ Valid category
- ✅ Quality score ≥ 0.3
- ✅ Deduplicated by location

### Quality score factors:

- Has name: +0.4
- Has description: +0.2
- Has Wikipedia/website: +0.2
- Known category: +0.2

## 🗺️ Categories

### Natural (type="natural")

waterfall, geyser, hot_spring, beach, cliff, cave, peak, lake, glacier, volcano, lava_field, fumarole, caldera

### Tourism (type="tourism")

viewpoint, attraction, museum, information, picnic_site, artwork

### Historic (type="historic")

church, ruins, monument, memorial, archaeological_site

### Outdoor (type="outdoor")

hiking_route, nature_reserve, campsite, swimming_pool

### Places (type="place")

village, town, hamlet, island, locality

### Infrastructure (type="infrastructure")

lighthouse, parking, shelter

## 📱 Flutter Integration

Once data is uploaded, fetch in your app:

```dart
// Get all waterfalls in Suðurland
final snapshot = await FirebaseFirestore.instance
  .collection('places')
  .where('type', isEqualTo: 'natural')
  .where('subtype', isEqualTo: 'waterfall')
  .where('region', isEqualTo: 'Suðurland')
  .orderBy('popularity', descending: true)
  .limit(20)
  .get();
```

## 🐛 Troubleshooting

**Error: "No module named 'requests'"**

```bash
pip install requests
```

**Error: "Could not load credentials"**

- Verify `serviceAccountKey.json` exists in `scripts/` directory
- Check file permissions

**Error: "429 Too Many Requests" from Overpass**

- Script includes rate limiting (2s between queries)
- If still failing, increase sleep time in `fetch_iceland_pois.py`

**Timeout from Overpass API**

- Some queries may timeout - script continues with other categories
- Re-run to catch missed data

**Firebase permission denied**

- Verify service account has Firestore Admin role
- Check Firebase project ID in credentials

## 📚 Data Sources

- **OpenStreetMap**: Primary POI source (CC BY-SA license)
- **Overpass API**: Query interface for OSM data
- **Manual seed data**: Curated 42 places + 15 trails (already created)

## 🎉 Success Checklist

- [x] Python scripts created
- [x] Firebase security rules configured
- [ ] Run `fetch_iceland_pois.py` → get 2000+ POIs
- [ ] Run `transform_pois_for_firestore.py` → clean data
- [ ] Run `upload_to_firestore.py` → populate Firestore
- [ ] Deploy security rules: `firebase deploy --only firestore:rules`
- [ ] Create Firestore indexes in Console
- [ ] Test queries in Flutter app

## 📞 Support

Issues? Check:

1. Python packages installed (`pip list`)
2. Firebase credentials valid
3. Internet connection for Overpass API
4. Firestore billing enabled (Blaze plan for large datasets)
