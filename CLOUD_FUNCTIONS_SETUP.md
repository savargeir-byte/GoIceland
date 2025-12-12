# 🔥 Firebase Cloud Functions Setup

## ✅ Hvað er búið til:

### 1. Cloud Functions

- **`monthlyUpdatePlaces`** - Keyrir 1. dag hvers mánaðar kl 03:00
- **`manualUpdatePlaces`** - HTTP endpoint fyrir manual uppfærslur
- **`updatePlaceStats`** - Daglegar statistics uppfærslur
- **`healthCheck`** - Health check endpoint

### 2. Master JSON Generator

- **`export_master_json.py`** - Býr til master JSON frá Firestore

### 3. Files Created

```
functions/
├── index.js          (4 Cloud Functions)
├── package.json      (dependencies)
├── .gitignore
└── README.md         (deployment guide)

go_iceland/firebase/
└── export_master_json.py

go_iceland/data/
└── iceland_places_master.json (sample)
```

## 🚀 Deployment Steps

### Step 1: Generate Master JSON

```bash
cd c:\GitHub\Travel_App\go_iceland\firebase
.\venv\Scripts\Activate.ps1
python export_master_json.py
```

This creates `iceland_places_master.json` with all 4972 places.

### Step 2: Host JSON File

Upload `iceland_places_master.json` to:

- GitHub repo (recommended)
- Firebase Storage
- CDN
- Any public URL

Example GitHub URL:

```
https://raw.githubusercontent.com/YOUR_USERNAME/iceland-poi/main/iceland_places_master.json
```

### Step 3: Install Function Dependencies

```bash
cd c:\GitHub\Travel_App\travel_super_app\functions
npm install
```

### Step 4: Update Data Source

Edit `functions/index.js`, replace:

```javascript
const dataUrl = "https://YOUR_URL_HERE/iceland_places_master.json";
```

### Step 5: Deploy to Firebase

```bash
cd c:\GitHub\Travel_App\travel_super_app
firebase deploy --only functions
```

## 📅 How It Works

### Monthly Automatic Update

```
Day 1 of month, 3:00 AM Iceland time
         ↓
Cloud Function triggers
         ↓
Fetches master JSON
         ↓
Updates all 4972 places in Firestore
         ↓
App automatically gets new data
```

### Manual Update Anytime

```bash
curl https://europe-west1-go-iceland.cloudfunctions.net/manualUpdatePlaces
```

## 📊 Monitor Updates

### Check last update in Firestore:

```
/system/last_update
  timestamp: 2025-12-12T03:00:00Z
  placesUpdated: 4972
  status: "success"
```

### View logs:

```bash
firebase functions:log
```

## 💡 Benefits

✅ **Zero Manual Work** - Runs automatically every month
✅ **Always Fresh Data** - Users get latest info
✅ **Version Control** - Track changes in master JSON
✅ **Rollback Support** - Keep old JSON versions
✅ **Statistics** - Daily stats updates

## 🔧 Customize Schedule

Edit schedule in `functions/index.js`:

```javascript
// Weekly (every Monday)
.schedule("0 3 * * 1")

// Twice per month (1st and 15th)
.schedule("0 3 1,15 * *")

// Daily
.schedule("0 3 * * *")
```

## 📝 Example Master JSON Structure

```json
{
  "updated": "2025-12-12T00:00:00Z",
  "version": "1.0",
  "total": 4972,
  "places": [
    {
      "id": "skogafoss",
      "name": "Skógafoss",
      "category": "waterfall",
      "region": "South",
      "coordinates": { "lat": 63.5321, "lng": -19.5115 },
      "description": "Famous 60m waterfall",
      "rating": 4.8,
      "metadata": {
        "difficulty": "easy",
        "parking": true
      }
    }
  ]
}
```

---

**Ready to deploy!** 🚀

Run: `firebase deploy --only functions`
