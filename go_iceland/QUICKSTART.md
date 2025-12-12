# GO ICELAND - Data Pipeline Quickstart

## Þú ert með núna

```
✅ 4972 POIs í Firestore (places collection)
✅ Flutter app tengdur (Hotels, Restaurants sections)
✅ Cloud Functions tilbúnar (monthly updater)
✅ Master JSON export (5014 places)
```

## Pipeline yfirlit

```
fetch_iceland_pois.py → enrich_pois.py → utils_geohash.py
         ↓                     ↓                  ↓
   5015 raw POIs      4972 cleaned POIs    + geohash

         ↓ (optional)
get_osm_images.py → get_photos_wikimedia.py → download_previews.py
         ↓                     ↓                      ↓
    OSM image tags      Wikimedia images       Mapbox previews

         ↓
upload_to_firestore.py → Firestore (4972 docs)
         ↓
export_master_json.py → iceland_places_master.json (5014 places)
         ↓
Cloud Functions (monthly updater)
```

## Hvernig að keyra

### 1. Grunnur (core pipeline)

```powershell
cd c:\GitHub\Travel_App\go_iceland

# Virtual environment
python -m venv venv
.\venv\Scripts\Activate.ps1
pip install -r requirements.txt

# Fetch POIs from OpenStreetMap
python etl/fetch_iceland_pois.py
# → data/iceland_pois_raw.json (5015 POIs)

# Clean + categorize + dedupe
python etl/enrich_pois.py
# → data/iceland_pois_enriched.json (4972 POIs)

# Add geohash for geoflutterfire
python etl/utils_geohash.py
# → data/iceland_pois_enriched.json (updated with geohash)

# Upload to Firestore
python firebase/upload_to_firestore.py
# → Firestore places collection (4972 docs)
```

### 2. Myndir (optional)

```powershell
# Extract OSM image tags
python etl/get_osm_images.py
# → data/iceland_pois_with_osm_images.json

# Fetch Wikimedia Commons images (takes ~30-60 min)
python etl/get_photos_wikimedia.py
# → data/iceland_pois_with_wikimedia.json

# Download Mapbox static map previews (requires MAPBOX_TOKEN)
python etl/download_previews.py
# → uploads to Firebase Storage
```

### 3. Master JSON export

```powershell
# Export Firestore → JSON for Cloud Functions
python firebase/export_master_json.py
# → data/iceland_places_master.json (5014 places)
```

### 4. Deploy Cloud Functions (monthly auto-update)

```powershell
cd c:\GitHub\Travel_App\travel_super_app

# 1. Host master JSON publicly (GitHub raw, Cloud Storage, etc)
# 2. Update functions/index.js line 22:
#    const dataUrl = "https://your-url/iceland_places_master.json"

# 3. Deploy
firebase deploy --only functions
# → 4 functions deployed (monthly updater, manual trigger, stats, health)
```

## Environment variables

`.env` skrá í `go_iceland/`:

```env
# Required for fetch
OVERPASS_API=https://overpass-api.de/api/interpreter

# Optional for Mapbox previews
MAPBOX_TOKEN=pk.YOUR_TOKEN

# Required for Firestore upload
FIREBASE_SERVICE_ACCOUNT=./firebase/serviceAccountKey.json
```

## Skrár sem þú þarft að búa til

1. **serviceAccountKey.json** - Firebase Admin SDK credentials

   - Firebase Console → Project Settings → Service Accounts → Generate new private key
   - Vista í `go_iceland/firebase/serviceAccountKey.json`

2. **.env** - Environment variables (sjá að ofan)

## Hvað gerir hvert skript?

| Skript                    | Input            | Output                              | Tími       |
| ------------------------- | ---------------- | ----------------------------------- | ---------- |
| `fetch_iceland_pois.py`   | OSM Overpass API | `iceland_pois_raw.json` (5015)      | ~5 min     |
| `enrich_pois.py`          | Raw POIs         | `iceland_pois_enriched.json` (4972) | ~5 sec     |
| `utils_geohash.py`        | Enriched POIs    | Same file + geohash                 | ~2 sec     |
| `get_osm_images.py`       | Enriched POIs    | With OSM image URLs                 | ~2 sec     |
| `get_photos_wikimedia.py` | Enriched POIs    | With Wikimedia images               | ~30-60 min |
| `download_previews.py`    | Enriched POIs    | With Mapbox previews                | ~2-3 hours |
| `upload_to_firestore.py`  | Final JSON       | Firestore collection                | ~30 sec    |
| `export_master_json.py`   | Firestore        | Master JSON                         | ~10 sec    |

## Cloud Functions

**Deployed functions:**

1. **monthlyUpdatePlaces** - Scheduled monthly (1st @ 3 AM Iceland time)

   - Fetches master JSON
   - Batch updates Firestore (500 docs/batch)
   - Logs to `/system/last_update`

2. **manualUpdatePlaces** - HTTP endpoint for manual triggers

   - Same as monthly, triggered on demand
   - `curl https://REGION-go-iceland.cloudfunctions.net/manualUpdatePlaces`

3. **updatePlaceStats** - Daily stats update (4 AM)

   - Counts by category, region
   - Saves to `/system/stats`

4. **healthCheck** - HTTP health endpoint
   - Returns service status
   - `curl https://REGION-go-iceland.cloudfunctions.net/healthCheck`

## Costs áætlun

- **Overpass API**: Free (rate-limited)
- **Wikimedia**: Free (CC-BY-SA)
- **Mapbox Static**: $0.50 per 1000 requests (~$2.50 for 5000 POIs)
- **Firebase Storage**: ~$0.026/GB/month (~50 MB images = $0.001)
- **Cloud Functions**: ~$0.40/million invocations (monthly = $0.01/year)
- **Firestore**: ~5000 reads/day = $0.36/day, writes free up to 20K/day

**Samtals**: ~$10-15/mánuð (með Mapbox previews)

## Attribution

⚠️ **Nauðsynlegt**: OSM data er **CC-BY-SA** license.

Bættu við í app:

```dart
// lib/features/about/about_screen.dart
Text('Data: © OpenStreetMap contributors'),
Text('Images: Wikimedia Commons (CC-BY-SA)'),
```

## Testing

```powershell
# Test á minni bbox fyrst (Reykjavík area)
# Breyttu BBOX í fetch_iceland_pois.py:
# BBOX = "(64.0,-22.0,64.2,-21.7)"  # Reykjavík only

python etl/fetch_iceland_pois.py
# → ~500-800 POIs í stað 5015

# Skoða JSON output
code data/iceland_pois_raw.json

# Upload test data
python firebase/upload_to_firestore.py

# Check Flutter app
# → TestPOIScreen should show ~500-800 POIs
```

## Troubleshooting

**Overpass 429 rate limit:**

```
⚠️ Overpass API rate limit hit
Solution: Wait 30 seconds, script retries automatically
```

**Firebase permission denied:**

```
❌ Firebase Admin SDK error
Solution: Check serviceAccountKey.json path in .env
```

**Mapbox 401 unauthorized:**

```
❌ Mapbox token invalid
Solution: Get token from https://account.mapbox.com/access-tokens/
```

**Node version mismatch:**

```
⚠️ Functions require Node 18, found Node 22
Solution: Works with warnings, or use nvm: nvm install 18
```

## Næstu skref

1. ✅ **Deploy Cloud Functions** (sjá að ofan)
2. ⏳ **Add Wikimedia images** (optional, ~1 hour)
3. ⏳ **Add Mapbox previews** (optional, ~3 hours + $2.50)
4. 🎯 **Test Flutter app** - TestPOIScreen + Explore feed

## Aukaverkefni

- **Vegagerðin road alerts API** integration
- **Premium home screen** refactor
- **Weather data** from Icelandic Met Office
- **Trail difficulty ratings** with GPX analysis
- **User-generated content** (reviews, photos, tips)
