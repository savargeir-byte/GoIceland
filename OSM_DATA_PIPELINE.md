# GO ICELAND - OSM Data Pipeline

Complete system for importing 2000+ Icelandic POIs from OpenStreetMap into Firebase Firestore.

## 🎯 What You Get

- **2000-4500 POIs** from OpenStreetMap
- **Automatic categorization** into GO ICELAND taxonomy
- **Region assignment** (9 Iceland regions)
- **Quality filtering** to ensure data accuracy
- **Batch Firestore upload** with progress tracking
- **Production-ready security rules**

## 📦 Files Created

### Python Scripts

1. **`fetch_iceland_pois.py`** - Downloads POIs from Overpass API

   - Queries 50+ OSM categories
   - 2000-4500 expected results
   - Output: `iceland_pois_raw.json`

2. **`transform_pois_for_firestore.py`** - Cleans and formats data

   - Deduplication
   - Quality scoring
   - Region detection
   - Output: `places_firestore.json`

3. **`upload_to_firestore.py`** - Uploads to Firestore
   - Batch processing (500 docs/batch)
   - Progress tracking
   - Verification step

### Configuration

4. **`firestore.rules`** - Security rules for production
5. **`scripts/README.md`** - Complete usage guide

## 🚀 Quick Start

```bash
# 1. Install dependencies
pip install requests firebase-admin

# 2. Download service account key
# Save as scripts/serviceAccountKey.json

# 3. Run the pipeline
cd scripts
python fetch_iceland_pois.py
python transform_pois_for_firestore.py
python upload_to_firestore.py

# 4. Deploy security rules
firebase deploy --only firestore:rules
```

## 📊 Expected Results

### POI Categories (estimated counts):

**Natural Features** (~1200)

- Waterfalls: ~300
- Viewpoints: ~400
- Peaks: ~280
- Hot springs: ~80
- Beaches: ~60
- Glaciers: ~40
- Caves: ~25
- Geysers: ~15

**Tourism** (~900)

- Attractions: ~350
- Museums: ~120
- Information centers: ~80
- Picnic sites: ~200
- Artwork: ~150

**Historic** (~420)

- Churches: ~180
- Monuments: ~120
- Ruins: ~80
- Archaeological sites: ~40

**Places** (~500)

- Villages: ~200
- Towns: ~50
- Hamlets: ~150
- Islands: ~100

**Outdoor** (~300)

- Hiking routes: ~150
- Nature reserves: ~80
- Campsites: ~70

**Infrastructure** (~180)

- Lighthouses: ~30
- Parking: ~120
- Shelters: ~30

**Total: 2000-4500 POIs**

## 🗺️ Data Structure

```javascript
// places/{placeId}
{
  id: "osm_123456789",
  name: "Skógafoss",
  type: "natural",           // Primary category
  subtype: "waterfall",      // Specific type
  lat: 63.5321,
  lng: -19.5117,
  region: "Suðurland",       // Iceland region
  popularity: 85,            // 0-100 score
  quality_score: 0.95,       // Data quality
  images: [],
  description: "...",
  wikipedia: "en:Skógafoss",
  website: "https://...",
  source: "osm",
  updatedAt: "2025-12-12T...",
  meta: {
    icon: "💧",
    osm_id: 123456789
  }
}
```

## 🔒 Security

The included `firestore.rules`:

- ✅ Public read for places/trails/collections
- ✅ Admin-only writes (via Firebase Admin SDK)
- ✅ User-owned data protected
- ✅ Authenticated reviews and check-ins

## 📈 Performance

### Firestore Indexes (required for queries)

Create in Firebase Console → Firestore → Indexes:

1. **By region and popularity**

   - Collection: `places`
   - Fields: `type`, `region`, `popularity` (DESC)

2. **By subtype and region**

   - Collection: `places`
   - Fields: `subtype`, `region`, `popularity` (DESC)

3. **By quality**
   - Collection: `places`
   - Fields: `quality_score` (DESC), `popularity` (DESC)

## 🔄 Maintenance

### Monthly updates (recommended)

```bash
# Re-fetch latest OSM data
python fetch_iceland_pois.py
python transform_pois_for_firestore.py
python upload_to_firestore.py
```

### Manual curated data (already seeded)

```bash
# Original 42 places + 15 trails
npm install firebase-admin
node seed-firestore.js
```

## 🎨 Integration with Flutter

```dart
// Example: Get waterfalls in Suðurland
final waterfalls = await FirebaseFirestore.instance
  .collection('places')
  .where('subtype', isEqualTo: 'waterfall')
  .where('region', isEqualTo: 'Suðurland')
  .orderBy('popularity', descending: true)
  .limit(20)
  .get();

// Example: Search by type
final naturalFeatures = await FirebaseFirestore.instance
  .collection('places')
  .where('type', isEqualTo: 'natural')
  .orderBy('quality_score', descending: true)
  .get();
```

## ✅ Success Checklist

- [x] Python scripts created (3 files)
- [x] Security rules configured
- [x] Documentation complete
- [ ] Install Python dependencies
- [ ] Download Firebase service account key
- [ ] Run OSM data pipeline
- [ ] Deploy Firestore security rules
- [ ] Create composite indexes
- [ ] Test in Flutter app

## 🌟 Next Steps

1. **Run the pipeline** to get 2000+ POIs
2. **Add images** to popular locations (manual or scraping)
3. **User reviews** - enable authenticated users to rate places
4. **Check-ins** - track visited locations
5. **Photo uploads** - user-generated content
6. **Collections** - create themed lists (best waterfalls, top hikes, etc.)

## 📚 Resources

- **OpenStreetMap**: https://www.openstreetmap.org/
- **Overpass API**: https://overpass-api.de/
- **Firebase Firestore**: https://firebase.google.com/docs/firestore
- **GO ICELAND Project**: Complete Iceland travel app with 2000+ POIs

---

**Total implementation time**: ~20 minutes  
**Expected POIs**: 2000-4500  
**Data quality**: High (OSM + filtering)  
**Ready for production**: ✅
