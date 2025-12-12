# 🚀 Firebase Cloud Functions - Manual Deployment Leiðbeiningar

## ⚠️ PowerShell terminal vandamál

VS Code PowerShell terminal virðist hafa vandamál með að halda working directory fyrir Firebase CLI.

## ✅ Lausn: Deploy handvirkt

### Option 1: Windows Terminal (AUÐVELDAST)

```powershell
# 1. Opna Windows Terminal eða nýjan PowerShell glugga
# 2. Keyra:

cd c:\GitHub\Travel_App\travel_super_app
firebase use go-iceland
firebase deploy --only functions

# Þetta ætti að virka!
```

### Option 2: Firebase Console (VISUAL)

1. **Opna Firebase Console**:

   - https://console.firebase.google.com/project/go-iceland/functions

2. **Sjá núverandi functions** (ef einhverjar eru deployed)

3. **Deploy handvirkt með Windows Terminal** (sjá að ofan)

### Option 3: VS Code Integrated Terminal Bug Workaround

```powershell
# Í VS Code terminal:
$Env:FIREBASE_PROJECT = "go-iceland"
Set-Location -Path "c:\GitHub\Travel_App\travel_super_app"
& "C:\Users\Computer\AppData\Roaming\npm\firebase.cmd" deploy --only functions
```

## 📋 Verify Deployment

Eftir successful deployment, athugaðu:

```powershell
# List deployed functions
firebase functions:list --project go-iceland

# Expected output:
# ┌──────────────────────────┬────────────┬────────────┐
# │ Function Name            │ Region     │ Runtime    │
# ├──────────────────────────┼────────────┼────────────┤
# │ healthCheck              │ us-central1│ nodejs20   │
# │ manualUpdatePlaces       │ us-central1│ nodejs20   │
# │ monthlyUpdatePlaces      │ us-central1│ nodejs20   │
# │ updatePlaceStats         │ us-central1│ nodejs20   │
# └──────────────────────────┴────────────┴────────────┘
```

## 🧪 Test Functions

### 1. Test Health Check

```powershell
curl https://us-central1-go-iceland.cloudfunctions.net/healthCheck
```

**Expected response:**

```json
{
  "status": "ok",
  "service": "GO ICELAND Cloud Functions",
  "version": "1.0.0",
  "timestamp": "2025-12-12T..."
}
```

### 2. Test Manual Update (IMPORTANT: Host JSON first!)

```powershell
# First, update functions/index.js with your hosted JSON URL
# Then run:
curl https://us-central1-go-iceland.cloudfunctions.net/manualUpdatePlaces
```

## 📝 TODO Before Testing Manual Update

**⚠️ CRITICAL:** Þú verður að hosta `iceland_places_master.json` fyrst!

### Quick GitHub Gist Setup:

1. **Create Gist:**

   ```powershell
   # If you have GitHub CLI:
   gh gist create c:\GitHub\Travel_App\go_iceland\data\iceland_places_master.json --public

   # Or manually:
   # 1. Go to: https://gist.github.com/
   # 2. New gist → Paste JSON → Create public gist
   # 3. Click "Raw" → Copy URL
   ```

2. **Update functions/index.js:**

   ```javascript
   // Line ~33:
   const dataUrl =
     "https://gist.githubusercontent.com/YOUR_USERNAME/GIST_ID/raw/iceland_places_master.json";
   ```

3. **Re-deploy:**
   ```powershell
   firebase deploy --only functions --project go-iceland
   ```

## 🎯 Next Steps Efter Deployment

1. ✅ **Verify functions deployed** - `firebase functions:list`
2. ✅ **Test health check** - curl healthCheck URL
3. 🔧 **Host master JSON** - GitHub Gist/repo/Firebase Storage
4. 📝 **Update dataUrl** - Edit functions/index.js
5. 🚀 **Re-deploy** - `firebase deploy --only functions`
6. 🧪 **Test manual update** - curl manualUpdatePlaces URL
7. 📊 **Check Firestore** - Verify POIs updated
8. 🎉 **Done!** - Monthly updates automatic

## 📞 Debugging

### Check logs:

```powershell
firebase functions:log --project go-iceland

# Or specific function:
firebase functions:log --only monthlyUpdatePlaces --project go-iceland
```

### Common errors:

**"Not in a Firebase app directory"**

```powershell
# Make sure you're in the right directory:
cd c:\GitHub\Travel_App\travel_super_app
Test-Path firebase.json  # Should return: True
```

**"No active project"**

```powershell
firebase use go-iceland
```

**"Node 18 decommissioned"**

```javascript
// Already fixed! Using Node 20 now
// Check: functions/package.json → "node": "20"
```

## 🔗 Useful Links

- **Firebase Console**: https://console.firebase.google.com/project/go-iceland
- **Functions Dashboard**: https://console.firebase.google.com/project/go-iceland/functions
- **Firestore**: https://console.firebase.google.com/project/go-iceland/firestore
- **Usage & Billing**: https://console.firebase.google.com/project/go-iceland/usage

---

## ⚡ TL;DR - Quick Deploy

```powershell
# Open NEW Windows Terminal (not VS Code):
cd c:\GitHub\Travel_App\travel_super_app
firebase use go-iceland
firebase deploy --only functions
```

Þetta ætti að virka! 🎉
