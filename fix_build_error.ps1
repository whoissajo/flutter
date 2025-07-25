Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Flutter Build Error Fix Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Step 1: Cleaning Flutter cache..." -ForegroundColor Yellow
flutter clean
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Flutter clean failed" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Host "Step 2: Clearing pub cache..." -ForegroundColor Yellow
flutter pub cache clean
if ($LASTEXITCODE -ne 0) {
    Write-Host "WARNING: Pub cache clean failed, continuing..." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Step 3: Removing build directory..." -ForegroundColor Yellow
if (Test-Path "build") {
    Remove-Item -Recurse -Force "build"
    Write-Host "Build directory removed" -ForegroundColor Green
} else {
    Write-Host "Build directory not found" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Step 4: Removing .dart_tool directory..." -ForegroundColor Yellow
if (Test-Path ".dart_tool") {
    Remove-Item -Recurse -Force ".dart_tool"
    Write-Host ".dart_tool directory removed" -ForegroundColor Green
} else {
    Write-Host ".dart_tool directory not found" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Step 5: Getting dependencies..." -ForegroundColor Yellow
flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Flutter pub get failed" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Host "Step 6: Building APK (debug)..." -ForegroundColor Yellow
flutter build apk --debug --no-shrink
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: APK build failed" -ForegroundColor Red
    Write-Host ""
    Write-Host "Trying with different flags..." -ForegroundColor Yellow
    flutter build apk --debug --no-obfuscate --no-shrink
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Alternative build also failed" -ForegroundColor Red
        Write-Host ""
        Write-Host "Please try the manual solutions below:" -ForegroundColor Yellow
        Write-Host "1. Move project to C: drive"
        Write-Host "2. Or move Flutter SDK to F: drive"
        Write-Host "3. Or use Android Studio to build"
        Read-Host "Press Enter to exit"
        exit 1
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "BUILD SUCCESSFUL!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "APK Location: build\app\outputs\flutter-apk\app-debug.apk" -ForegroundColor Cyan
Write-Host ""
Read-Host "Press Enter to exit"
