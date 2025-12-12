#!/usr/bin/env pwsh
# GO ICELAND - Complete Setup Script
# Runs the entire ETL pipeline from OSM to Firestore

Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  GO ICELAND - Full Data Pipeline Setup" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

$ErrorActionPreference = "Stop"
$scriptsDir = "c:\GitHub\Travel_App\travel_super_app\scripts"
$pythonCmd = "c:/GitHub/Travel_App/.venv/Scripts/python.exe"

# Check prerequisites
Write-Host "🔍 Checking prerequisites..." -ForegroundColor Yellow
Write-Host ""

if (!(Test-Path "$scriptsDir\serviceAccountKey.json")) {
    Write-Host "❌ Missing serviceAccountKey.json" -ForegroundColor Red
    Write-Host "   Download from Firebase Console → Project Settings → Service Accounts" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Service account key found" -ForegroundColor Green

# Check Python packages
Write-Host "📦 Installing Python dependencies..." -ForegroundColor Yellow
& pip install -q requests firebase-admin python-dotenv
Write-Host "✅ Python packages ready" -ForegroundColor Green
Write-Host ""

# Step 1: Fetch from OSM (optional - can skip if already done)
Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "STEP 1: Fetch POIs from OpenStreetMap (10-15 minutes)" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

$skipFetch = Read-Host "Skip OSM fetch? (y/n) [Data already seeded with 42 places]"
if ($skipFetch -ne "y") {
    Write-Host "⏳ Fetching from OSM (this takes 10-15 minutes)..." -ForegroundColor Yellow
    & $pythonCmd "$scriptsDir\fetch_iceland_pois.py"
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "⚠️  OSM fetch had issues, continuing with existing data..." -ForegroundColor Yellow
    }
    Write-Host ""
}

# Step 2: Transform & add geohash
if (Test-Path "$scriptsDir\iceland_pois_raw.json") {
    Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "STEP 2: Transform & add GeoHash" -ForegroundColor Cyan
    Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "🔄 Transforming data..." -ForegroundColor Yellow
    & $pythonCmd "$scriptsDir\transform_pois_for_firestore.py"
    
    Write-Host "📍 Adding geohash..." -ForegroundColor Yellow
    & $pythonCmd "$scriptsDir\add_geohash.py" "$scriptsDir\places_firestore.json" "$scriptsDir\places_with_geohash.json"
    Write-Host ""
}

# Step 3: Map previews (optional)
Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "STEP 3: Download Map Previews (Optional)" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

$mapboxToken = $env:MAPBOX_TOKEN
if ([string]::IsNullOrEmpty($mapboxToken)) {
    Write-Host "⚠️  MAPBOX_TOKEN not set - skipping map previews" -ForegroundColor Yellow
    Write-Host "   To enable: `$env:MAPBOX_TOKEN='pk.your_token'" -ForegroundColor Gray
}
else {
    $downloadPreviews = Read-Host "Download map previews? (y/n) [Costs Mapbox API credits]"
    if ($downloadPreviews -eq "y") {
        Write-Host "🗺️  Downloading map previews..." -ForegroundColor Yellow
        & $pythonCmd "$scriptsDir\download_map_previews.py" "$scriptsDir\places_with_geohash.json" "$scriptsDir\places_final.json"
    }
}
Write-Host ""

# Step 4: Upload to Firestore
Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "STEP 4: Upload to Firestore" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

$finalFile = if (Test-Path "$scriptsDir\places_final.json") { 
    "$scriptsDir\places_final.json" 
}
elseif (Test-Path "$scriptsDir\places_with_geohash.json") {
    "$scriptsDir\places_with_geohash.json"
}
elseif (Test-Path "$scriptsDir\places_firestore.json") {
    "$scriptsDir\places_firestore.json"
}
else {
    $null
}

if ($finalFile) {
    Write-Host "📤 Uploading to Firestore..." -ForegroundColor Yellow
    & $pythonCmd "$scriptsDir\upload_to_firestore.py" --collection places --cred "$scriptsDir\serviceAccountKey.json"
    Write-Host ""
}
else {
    Write-Host "⚠️  No processed data found, using manual seed instead..." -ForegroundColor Yellow
    Write-Host "🌱 Running seed script..." -ForegroundColor Yellow
    Set-Location $scriptsDir
    & node seed-firestore.js
    Write-Host ""
}

# Step 5: Deploy Firestore rules
Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "STEP 5: Deploy Firestore Rules" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

Set-Location "c:\GitHub\Travel_App\travel_super_app"
Write-Host "🔐 Deploying security rules..." -ForegroundColor Yellow
& firebase deploy --only firestore

Write-Host ""
Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "  ✅ SETUP COMPLETE!" -ForegroundColor Green
Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host ""
Write-Host "🎉 Your Firebase database is ready!" -ForegroundColor Green
Write-Host ""
Write-Host "📱 Next steps:" -ForegroundColor Yellow
Write-Host "   1. Open Firebase Console: https://console.firebase.google.com/project/go-iceland/firestore" -ForegroundColor Gray
Write-Host "   2. Verify data is uploaded" -ForegroundColor Gray
Write-Host "   3. Run your Flutter app: flutter run -d chrome" -ForegroundColor Gray
Write-Host ""
Write-Host "📚 Documentation:" -ForegroundColor Yellow
Write-Host "   • Full guide: scripts/README.md" -ForegroundColor Gray
Write-Host "   • Pipeline overview: OSM_DATA_PIPELINE.md" -ForegroundColor Gray
Write-Host "   • Quick start: QUICKSTART_OSM.txt" -ForegroundColor Gray
Write-Host ""
