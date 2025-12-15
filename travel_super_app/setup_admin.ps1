# 🚀 Go Iceland Admin Panel - Quick Setup Script
# This script automates the admin panel setup process

Write-Host "🔥 GO ICELAND - Admin Panel Setup" -ForegroundColor Blue
Write-Host "=================================" -ForegroundColor Blue
Write-Host ""

# Check if in correct directory
if (-not (Test-Path "pubspec.yaml")) {
    Write-Host "❌ Error: Must run from travel_super_app directory" -ForegroundColor Red
    Write-Host "   cd travel_super_app" -ForegroundColor Yellow
    exit 1
}

Write-Host "📦 Step 1: Installing Flutter dependencies..." -ForegroundColor Cyan
flutter pub get

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to install dependencies" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Dependencies installed" -ForegroundColor Green
Write-Host ""

# Check if Firebase CLI is installed
Write-Host "🔍 Step 2: Checking Firebase CLI..." -ForegroundColor Cyan
$firebaseInstalled = Get-Command firebase -ErrorAction SilentlyContinue

if (-not $firebaseInstalled) {
    Write-Host "⚠️  Firebase CLI not found" -ForegroundColor Yellow
    Write-Host "   Install: npm install -g firebase-tools" -ForegroundColor Yellow
    $installFirebase = Read-Host "Install Firebase CLI now? (y/n)"
    
    if ($installFirebase -eq "y") {
        npm install -g firebase-tools
        if ($LASTEXITCODE -ne 0) {
            Write-Host "❌ Failed to install Firebase CLI" -ForegroundColor Red
            exit 1
        }
    }
    else {
        Write-Host "⏭️  Skipping Firebase CLI installation" -ForegroundColor Yellow
    }
}
else {
    Write-Host "✅ Firebase CLI found: $($firebaseInstalled.Version)" -ForegroundColor Green
}

Write-Host ""

# Firebase login
Write-Host "🔐 Step 3: Firebase authentication..." -ForegroundColor Cyan
$loginChoice = Read-Host "Login to Firebase? (y/n)"

if ($loginChoice -eq "y") {
    firebase login
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Firebase login failed" -ForegroundColor Red
        exit 1
    }
    Write-Host "✅ Firebase login successful" -ForegroundColor Green
}

Write-Host ""

# Deploy security rules
Write-Host "🔒 Step 4: Deploy Firestore security rules..." -ForegroundColor Cyan
$deployRules = Read-Host "Deploy security rules to Firebase? (y/n)"

if ($deployRules -eq "y") {
    firebase deploy --only firestore:rules
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Failed to deploy security rules" -ForegroundColor Red
        exit 1
    }
    Write-Host "✅ Security rules deployed" -ForegroundColor Green
}

Write-Host ""

# Create admin user
Write-Host "👤 Step 5: Create admin user..." -ForegroundColor Cyan
$createUser = Read-Host "Create admin user now? (y/n)"

if ($createUser -eq "y") {
    if (Test-Path "../go_iceland/firebase/serviceAccountKey.json") {
        cd scripts
        node create_admin_user.js
        cd ..
        Write-Host "✅ Admin user creation complete" -ForegroundColor Green
    }
    else {
        Write-Host "⚠️  Service account key not found" -ForegroundColor Yellow
        Write-Host "   Download from Firebase Console → Project Settings → Service Accounts" -ForegroundColor Yellow
        Write-Host "   Save to: go_iceland/firebase/serviceAccountKey.json" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "🎯 Setup Options:" -ForegroundColor Blue
Write-Host "=================================" -ForegroundColor Blue
Write-Host ""
Write-Host "1️⃣  Run admin panel locally (web):" -ForegroundColor White
Write-Host "   flutter run -d chrome --target lib/main_admin.dart" -ForegroundColor Gray
Write-Host ""
Write-Host "2️⃣  Build for web deployment:" -ForegroundColor White
Write-Host "   flutter build web --release --target lib/main_admin.dart" -ForegroundColor Gray
Write-Host "   firebase deploy --only hosting" -ForegroundColor Gray
Write-Host ""
Write-Host "3️⃣  Build for Windows:" -ForegroundColor White
Write-Host "   flutter build windows --release --target lib/main_admin.dart" -ForegroundColor Gray
Write-Host ""
Write-Host "📚 Documentation:" -ForegroundColor Blue
Write-Host "   - ADMIN_PANEL_README.md    (Features & Usage)" -ForegroundColor Gray
Write-Host "   - ADMIN_DEPLOYMENT.md      (Deployment Guide)" -ForegroundColor Gray
Write-Host ""

$runNow = Read-Host "🚀 Run admin panel now? (y/n)"

if ($runNow -eq "y") {
    Write-Host "🌐 Starting admin panel on Chrome..." -ForegroundColor Cyan
    flutter run -d chrome --target lib/main_admin.dart
}

Write-Host ""
Write-Host "✨ Setup complete! Happy managing! 🎉" -ForegroundColor Green
