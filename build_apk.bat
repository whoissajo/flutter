@echo off
echo ========================================
echo Flutter AI Template - APK Build Script
echo ========================================
echo.

echo Step 1: Cleaning previous builds...
flutter clean
if %errorlevel% neq 0 (
    echo ERROR: Flutter clean failed
    pause
    exit /b 1
)

echo.
echo Step 2: Getting dependencies...
flutter pub get
if %errorlevel% neq 0 (
    echo ERROR: Flutter pub get failed
    pause
    exit /b 1
)

echo.
echo Step 3: Running code generation...
flutter packages pub run build_runner build --delete-conflicting-outputs
if %errorlevel% neq 0 (
    echo WARNING: Code generation failed, continuing anyway...
)

echo.
echo Step 4: Building debug APK...
flutter build apk --debug
if %errorlevel% neq 0 (
    echo ERROR: APK build failed
    echo.
    echo Trying alternative build...
    flutter build apk --debug --target-platform android-arm64
    if %errorlevel% neq 0 (
        echo ERROR: Alternative build also failed
        echo.
        echo Please check the following:
        echo 1. Android SDK is properly installed
        echo 2. Java JDK is installed and configured
        echo 3. Android licenses are accepted: flutter doctor --android-licenses
        echo 4. Run: flutter doctor -v to check setup
        pause
        exit /b 1
    )
)

echo.
echo ========================================
echo BUILD SUCCESSFUL!
echo ========================================
echo.
echo APK Location: build\app\outputs\flutter-apk\app-debug.apk
echo.
echo You can now install this APK on your Android device:
echo 1. Enable "Unknown Sources" in Android Settings
echo 2. Transfer the APK to your device
echo 3. Tap the APK file to install
echo.
echo Features included in this build:
echo - Splash Screen with custom branding
echo - Onboarding flow for new users
echo - Firebase Authentication (Email/Google/Apple)
echo - AI Chat with OpenRouter integration
echo - Voice Input with speech-to-text
echo - Firestore database integration
echo - User profile management
echo.
pause
