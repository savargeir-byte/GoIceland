# 🇮🇸 GO ICELAND - COMPLETE DATA PIPELINE
# One-click script to fetch, enrich, and upload ALL Iceland data

Write-Host "🇮🇸 GO ICELAND - COMPLETE DATA PIPELINE" -ForegroundColor Cyan
Write-Host "=" * 60
Write-Host ""

# Check Python
$python = Get-Command python -ErrorAction SilentlyContinue
if (-not $python) {
    Write-Host "❌ Python not found. Please install Python 3.11+" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Python found" -ForegroundColor Green
Write-Host ""

# Check dependencies
Write-Host "📦 Checking dependencies..." -ForegroundColor Yellow
pip show requests firebase-admin > $null 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "Installing dependencies..." -ForegroundColor Yellow
    pip install requests firebase-admin
}

Write-Host ""
Write-Host "=" * 60
Write-Host "STEP 1: FETCH ALL PLACES (2000-4000+ POIs)" -ForegroundColor Cyan
Write-Host "=" * 60
Write-Host ""

python etl/fetch_all_places.py

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to fetch places" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "=" * 60
Write-Host "STEP 2: FETCH ALL TRAILS (400+ with polylines)" -ForegroundColor Cyan
Write-Host "=" * 60
Write-Host ""

python etl/fetch_all_trails.py

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to fetch trails" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "=" * 60
Write-Host "STEP 3: ENRICH ALL WITH SAGA & CULTURE" -ForegroundColor Cyan
Write-Host "=" * 60
Write-Host ""

python etl/enrich_all_descriptions.py

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to enrich places" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "=" * 60
Write-Host "STEP 4: UPLOAD TO FIRESTORE" -ForegroundColor Cyan
Write-Host "=" * 60
Write-Host ""

# Check for service account key
if (-not (Test-Path "firebase/serviceAccountKey.json")) {
    Write-Host "⚠️  Service account key not found" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "To upload to Firebase:" -ForegroundColor White
    Write-Host "1. Download key from Firebase Console" -ForegroundColor White
    Write-Host "2. Save as firebase/serviceAccountKey.json" -ForegroundColor White
    Write-Host "3. Run: python firebase/upload_all_to_firestore.py" -ForegroundColor White
    Write-Host ""
    Write-Host "✅ Data is ready in data/ directory!" -ForegroundColor Green
    exit 0
}

python firebase/upload_all_to_firestore.py

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to upload to Firestore" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "=" * 60
Write-Host "🎉 PIPELINE COMPLETE!" -ForegroundColor Green
Write-Host "=" * 60
Write-Host ""
Write-Host "✅ All places fetched and enriched" -ForegroundColor Green
Write-Host "✅ All trails fetched with polylines" -ForegroundColor Green
Write-Host "✅ Data uploaded to Firestore" -ForegroundColor Green
Write-Host ""
Write-Host "📂 Output files:" -ForegroundColor Cyan
Write-Host "   • data/iceland_places_raw.json" -ForegroundColor White
Write-Host "   • data/iceland_trails_raw.json" -ForegroundColor White
Write-Host "   • data/iceland_places_enriched.json" -ForegroundColor White
Write-Host ""
Write-Host "🇮🇸 GO ICELAND = BEST ferðamanna-app á Íslandi!" -ForegroundColor Green
Write-Host ""

