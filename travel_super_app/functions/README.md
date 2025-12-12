# Firebase Cloud Functions - Deployment Guide

## 📦 Setup

```bash
cd functions
npm install
```

## 🚀 Deploy Functions

### Deploy all functions

```bash
firebase deploy --only functions
```

### Deploy specific function

```bash
firebase deploy --only functions:monthlyUpdatePlaces
firebase deploy --only functions:updatePlaceStats
```

## 🧪 Test Locally

### Start emulator

```bash
npm run serve
```

### Test in shell

```bash
npm run shell
```

## 📅 Scheduled Functions

### 1. Monthly Update (Auto)

- **Schedule**: 1st of month at 3 AM Iceland time
- **Function**: `monthlyUpdatePlaces`
- **Purpose**: Updates all places from master JSON
- **Cron**: `0 3 1 * *`

### 2. Daily Stats (Auto)

- **Schedule**: Every day at 4 AM Iceland time
- **Function**: `updatePlaceStats`
- **Purpose**: Updates place statistics
- **Cron**: `0 4 * * *`

## 🔧 Manual Update

### Trigger HTTP endpoint

```bash
curl https://YOUR_REGION-go-iceland.cloudfunctions.net/manualUpdatePlaces
```

Or open in browser for testing.

## 📊 Monitor Functions

### View logs

```bash
firebase functions:log
```

### View logs for specific function

```bash
firebase functions:log --only monthlyUpdatePlaces
```

### Check last update status

Go to Firestore Console → `system/last_update`

## ⚙️ Configuration

### Update data source URL

Edit `functions/index.js`:

```javascript
const dataUrl = "https://your-url.com/iceland_places.json";
```

### Change schedule

```javascript
// Monthly: 1st at 3 AM
.schedule("0 3 1 * *")

// Weekly: Every Monday at 2 AM
.schedule("0 2 * * 1")

// Daily: Every day at midnight
.schedule("0 0 * * *")
```

## 🔥 Firestore Structure

```
/places/{placeId}
  - name
  - category
  - region
  - coordinates {lat, lng}
  - lastUpdated (timestamp)
  - autoUpdated (boolean)

/system/last_update
  - timestamp
  - placesUpdated
  - status
  - dataSource

/system/stats
  - totalPlaces
  - byCategory {}
  - byRegion {}
  - lastUpdated
```

## 💰 Costs

- **Scheduled functions**: Included in Spark plan (limited)
- **Firestore writes**: $0.18 per 100k writes
- **Estimated monthly cost**: ~$5-10 for 5000 places

Upgrade to Blaze plan for production use.

## 🔐 Security

Functions run with admin privileges. Ensure:

1. Data source URL is trusted
2. Input validation in place
3. Error handling implemented

## 📝 Logs

Check Firebase Console → Functions → Logs for:

- Execution time
- Memory usage
- Errors
- Success/failure status

---

**Last updated**: December 12, 2025
