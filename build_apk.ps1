Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Flutter AI Template - APK Build Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Step 1: Cleaning previous builds..." -ForegroundColor Yellow
flutter clean
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Flutter clean failed" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Host "Step 2: Getting dependencies..." -ForegroundColor Yellow
flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Flutter pub get failed" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Host "Step 3: Running code generation..." -ForegroundColor Yellow
flutter packages pub run build_runner build --delete-conflicting-outputs
if ($LASTEXITCODE -ne 0) {
    Write-Host "WARNING: Code generation failed, continuing anyway..." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Step 4: Building debug APK..." -ForegroundColor Yellow
flutter build apk --debug
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: APK build failed" -ForegroundColor Red
    Write-Host ""
    Write-Host "Trying alternative build..." -ForegroundColor Yellow
    flutter build apk --debug --target-platform android-arm64
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Alternative build also failed" -ForegroundColor Red
        Write-Host ""
        Write-Host "Please check the following:" -ForegroundColor Yellow
        Write-Host "1. Android SDK is properly installed"
        Write-Host "2. Java JDK is installed and configured"
        Write-Host "3. Android licenses are accepted: flutter doctor --android-licenses"
        Write-Host "4. Run: flutter doctor -v to check setup"
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
Write-Host "You can now install this APK on your Android device:" -ForegroundColor White
Write-Host "1. Enable 'Unknown Sources' in Android Settings"
Write-Host "2. Transfer the APK to your device"
Write-Host "3. Tap the APK file to install"
Write-Host ""
Write-Host "Features included in this build:" -ForegroundColor White
Write-Host "- Splash Screen with custom branding"
Write-Host "- Onboarding flow for new users"
Write-Host "- Firebase Authentication (Email/Google/Apple)"
Write-Host "- AI Chat with OpenRouter integration"
Write-Host "- Voice Input with speech-to-text"
Write-Host "- Firestore database integration"
Write-Host "- User profile management"
Write-Host ""
Read-Host "Press Enter to exit"
