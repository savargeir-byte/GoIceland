# GO ICELAND - Full ETL Pipeline Runner
# Runs all steps automatically after fetch completes

Write-Host "🌋 GO ICELAND - Full Pipeline" -ForegroundColor Cyan
Write-Host "=" * 50

# Check if virtual environment is active
if (-not $env:VIRTUAL_ENV) {
    Write-Host "Activating virtual environment..." -ForegroundColor Yellow
    .\venv\Scripts\Activate.ps1
}

# Step 1: Fetch (skip if already running)
$rawFile = ".\data\iceland_raw.json"
if (-not (Test-Path $rawFile)) {
    Write-Host "`n[1/5] 🌍 Fetching POIs from OpenStreetMap..." -ForegroundColor Cyan
    python etl/fetch_iceland_pois.py
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Fetch failed!" -ForegroundColor Red
        exit 1
    }
}
else {
    Write-Host "`n[1/5] ✅ Raw data exists, skipping fetch" -ForegroundColor Green
}

# Step 2: Enrich & Clean
Write-Host "`n[2/5] 🧹 Enriching and cleaning POIs..." -ForegroundColor Cyan
python etl/enrich_pois.py

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Enrichment failed!" -ForegroundColor Red
    exit 1
}

# Step 3: Add Geohash
Write-Host "`n[3/5] 📍 Adding geohash encoding..." -ForegroundColor Cyan
python etl/utils_geohash.py

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Geohash failed!" -ForegroundColor Red
    exit 1
}

# Step 4: Optional - Download Previews
if ($env:MAPBOX_TOKEN) {
    Write-Host "`n[4/5] 📸 Downloading map previews..." -ForegroundColor Cyan
    python etl/download_previews.py
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "⚠️ Preview download failed, continuing..." -ForegroundColor Yellow
    }
}
else {
    Write-Host "`n[4/5] ⏭️ Skipping previews (no MAPBOX_TOKEN)" -ForegroundColor Yellow
}

# Step 5: Upload to Firestore
Write-Host "`n[5/5] 🔥 Uploading to Firestore..." -ForegroundColor Cyan
python firebase/upload_to_firestore.py

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Upload failed!" -ForegroundColor Red
    exit 1
}

Write-Host "`n==================================================`n" -ForegroundColor White
Write-Host "✅ Pipeline complete!" -ForegroundColor Green
Write-Host "Check your data at:" -ForegroundColor Cyan
Write-Host "https://console.firebase.google.com/project/go-iceland/firestore`n" -ForegroundColor White
