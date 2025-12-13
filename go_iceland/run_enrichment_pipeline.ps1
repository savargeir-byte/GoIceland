# 🔥 DATA ENRICHMENT PIPELINE
# Sækir sögu, lýsingar, þjónustu frá Wikipedia, OSM
# Merger allt saman í ríkan JSON
# Uploadar í Firebase

Write-Host "🔥 STARTING DATA ENRICHMENT PIPELINE" -ForegroundColor Cyan
Write-Host ""

# 1. Check if data exists
if (-not (Test-Path "data/iceland_places_master.json")) {
    Write-Host "❌ iceland_places_master.json not found!" -ForegroundColor Red
    Write-Host "   Run: python etl/fetch_iceland_pois.py first" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Found base data: iceland_places_master.json" -ForegroundColor Green
Write-Host ""

# 2. Run enrichment
Write-Host "🌐 STEP 1: Enriching with Wikipedia, services, visit info..." -ForegroundColor Cyan
python etl/enrich_full_details.py

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Enrichment failed!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "✅ Enrichment complete: data/iceland_enriched_full.json" -ForegroundColor Green
Write-Host ""

# 3. Upload to Firebase
Write-Host "📤 STEP 2: Uploading to Firebase..." -ForegroundColor Cyan

# Check if we should upload
$upload = Read-Host "Upload to Firebase now? (y/n)"

if ($upload -eq 'y') {
    # Copy enriched data to master
    Copy-Item "data/iceland_enriched_full.json" "data/iceland_places_master.json" -Force
    
    # Upload
    python firebase/upload_to_firestore.py
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Upload failed!" -ForegroundColor Red
        exit 1
    }
    
    Write-Host ""
    Write-Host "🎉 PIPELINE COMPLETE!" -ForegroundColor Green
    Write-Host "   ✅ Data enriched with Wikipedia, services, visit info" -ForegroundColor Green
    Write-Host "   ✅ Uploaded to Firebase" -ForegroundColor Green
    Write-Host ""
    Write-Host "📱 Next: Rebuild app and install on phone" -ForegroundColor Cyan
    Write-Host "   flutter build apk --release" -ForegroundColor Yellow
    Write-Host "   adb install build/app/outputs/flutter-apk/app-release.apk" -ForegroundColor Yellow
    
}
else {
    Write-Host ""
    Write-Host "✅ Enrichment complete!" -ForegroundColor Green
    Write-Host "📋 Review data in: data/iceland_enriched_full.json" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "To upload later, run:" -ForegroundColor Yellow
    Write-Host "   python firebase/upload_to_firestore.py" -ForegroundColor Yellow
}
