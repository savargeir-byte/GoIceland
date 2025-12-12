# 🌋 GO ICELAND - Data Pipeline

Complete ETL pipeline for fetching, enriching, and uploading 2000-4500 Icelandic POIs to Firestore.

## 📁 Structure

```
go_iceland/
├── etl/                        # Data processing scripts
│   ├── fetch_iceland_pois.py   # Fetch from OpenStreetMap
│   ├── enrich_pois.py          # Clean & categorize
│   ├── utils_geohash.py        # Add geohash encoding
│   └── download_previews.py    # Mapbox static images
│
├── firebase/                   # Firebase integration
│   ├── upload_to_firestore.py  # Upload to Firestore
│   ├── firestore.rules         # Security rules
│   └── serviceAccountKey.json  # Your Firebase key (REQUIRED)
│
├── data/                       # Generated data files
│   ├── iceland_raw.json        # Raw OSM data
│   ├── iceland_clean.json      # Cleaned & categorized
│   ├── iceland_clean_geohash.json  # With geohash
│   └── categories.json         # Category definitions
│
├── previews/                   # Map preview images
├── icons/                      # Category icons (SVG)
├── requirements.txt            # Python dependencies
└── .env.example                # Environment template
```

## 🚀 Quick Start

### 1. Setup Environment

```powershell
# Create virtual environment
python -m venv venv
.\venv\Scripts\Activate.ps1

# Install dependencies
pip install -r requirements.txt

# Copy environment template
cp .env.example .env
```

### 2. Get Firebase Service Account Key

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project (go-iceland)
3. Settings → Service Accounts → Generate New Private Key
4. Save as `firebase/serviceAccountKey.json`

### 3. Run the Pipeline

```powershell
# Step 1: Fetch POIs from OpenStreetMap (5-10 minutes)
python etl/fetch_iceland_pois.py

# Step 2: Clean and categorize
python etl/enrich_pois.py

# Step 3: Add geohash for proximity queries
python etl/utils_geohash.py

# Step 4 (Optional): Download map previews
# Requires MAPBOX_TOKEN in .env
python etl/download_previews.py

# Step 5: Upload to Firestore
python firebase/upload_to_firestore.py
```

### One-Command Pipeline

```powershell
python etl/fetch_iceland_pois.py ; python etl/enrich_pois.py ; python etl/utils_geohash.py ; python firebase/upload_to_firestore.py
```

## 📊 Data Output

### Raw OSM Data (`iceland_raw.json`)

```json
{
  "name": "Seljalandsfoss",
  "lat": 63.6156,
  "lng": -19.9889,
  "category": "node[\"natural\"=\"waterfall\"]",
  "rating": null,
  "thumbnail": null,
  "description": null
}
```

### Cleaned Data (`iceland_clean.json`)

```json
{
  "id": "a1b2c3d4e5f6",
  "name": "Seljalandsfoss",
  "lat": 63.6156,
  "lng": -19.9889,
  "category": "waterfall",
  "region": "South",
  "rating": null,
  "description": null,
  "popularity": 0.5
}
```

### Geohash Enhanced (`iceland_clean_geohash.json`)

```json
{
  "id": "a1b2c3d4e5f6",
  "name": "Seljalandsfoss",
  "lat": 63.6156,
  "lng": -19.9889,
  "category": "waterfall",
  "region": "South",
  "geohash": "geb9xr",
  "geohashes": {
    "g5": "geb9x",
    "g6": "geb9xr",
    "g7": "geb9xrq",
    "g8": "geb9xrq5",
    "g9": "geb9xrq5e"
  },
  "location": {
    "geopoint": {
      "_latitude": 63.6156,
      "_longitude": -19.9889
    },
    "geohash": "geb9xr"
  }
}
```

## 🎯 Categories

- `waterfall` - Waterfalls (fossar)
- `hot_spring` - Hot springs & geysers
- `viewpoint` - Scenic viewpoints
- `museum` - Museums
- `restaurant` - Restaurants & cafes
- `landmark` - Historic landmarks
- `hiking_route` - Hiking trails
- `peak` - Mountain peaks
- `volcano` - Volcanoes
- `accommodation` - Hotels & hostels
- `camping` - Campsites
- `beach` - Beaches
- `cave` - Caves

## 🗺️ Regions

- Capital Region
- South
- Southeast
- East
- North
- Northeast
- Northwest
- Westfjords
- West

## 🔧 Configuration

### Environment Variables (`.env`)

```env
MAPBOX_TOKEN=pk.your_token          # For map previews
FIRESTORE_PROJECT_ID=go-iceland
BATCH_SIZE=500                      # Upload batch size
GEOHASH_PRECISION=6                 # 5km-1.2km precision
```

### Firestore Security Rules

Deploy rules:

```powershell
firebase deploy --only firestore:rules
```

## 📈 Expected Results

- **POIs**: 2000-4500 locations
- **Categories**: 13+ categories
- **Regions**: 9 Iceland regions
- **Processing Time**: 10-15 minutes
- **Firestore Docs**: ~3000 documents
- **Map Previews**: Optional (requires Mapbox token)

## 🔍 Geohash Precision

| Level | Precision | Use Case        |
| ----- | --------- | --------------- |
| g5    | ~5 km     | Regional search |
| g6    | ~1.2 km   | City area       |
| g7    | ~150 m    | Neighborhood    |
| g8    | ~38 m     | Street level    |
| g9    | ~5 m      | Exact location  |

## 🚨 Troubleshooting

### Overpass API Timeout

```powershell
# Reduce concurrent queries or add longer delays
# Edit fetch_iceland_pois.py: sleep(3)
```

### Firebase Permission Denied

```powershell
# Verify serviceAccountKey.json has correct permissions
# Check Firebase project ID matches
```

### Missing Dependencies

```powershell
pip install --upgrade -r requirements.txt
```

## 🔗 Resources

- [OpenStreetMap Overpass API](https://overpass-api.de/)
- [Firebase Console](https://console.firebase.google.com/)
- [Mapbox Static Images](https://docs.mapbox.com/api/maps/static-images/)
- [Geohash Algorithm](https://en.wikipedia.org/wiki/Geohash)

## 📝 License

MIT License - Free to use for GO ICELAND app

---

**Last Updated**: December 12, 2025  
**Status**: Production Ready ✅
