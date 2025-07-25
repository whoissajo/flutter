@echo off
echo 🚀 Flutter AI Template Setup
echo ==============================
echo.

REM Check if Flutter is installed
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Flutter is not installed or not in PATH
    echo Please install Flutter from https://flutter.dev/docs/get-started/install
    pause
    exit /b 1
)

echo ✅ Flutter found
flutter --version | findstr "Flutter"
echo.

REM Check if config file exists
if not exist "lib\config\api_config.dart" (
    echo 📝 Creating API configuration file...
    copy "lib\config\api_config.dart.template" "lib\config\api_config.dart" >nul
    echo ✅ Created lib\config\api_config.dart
    echo.
    echo ⚠️  IMPORTANT: Please edit lib\config\api_config.dart with your API keys
    echo    - OpenRouter API key for AI features
    echo    - Firebase project ID
    echo    - Your app domain and name
    echo.
) else (
    echo ✅ API configuration file already exists
    echo.
)

REM Install dependencies
echo 📦 Installing Flutter dependencies...
flutter pub get

if %errorlevel% neq 0 (
    echo ❌ Failed to install dependencies
    pause
    exit /b 1
)

echo ✅ Dependencies installed successfully
echo.

REM Check for Firebase configuration
echo 🔥 Checking Firebase configuration...

if not exist "android\app\google-services.json" (
    echo ⚠️  Missing: android\app\google-services.json
    echo    Please download from Firebase Console and place it in android\app\
)

if not exist "ios\Runner\GoogleService-Info.plist" (
    echo ⚠️  Missing: ios\Runner\GoogleService-Info.plist
    echo    Please download from Firebase Console and place it in ios\Runner\
)

echo.

REM Check API configuration
echo 🔑 Checking API configuration...
findstr /C:"YOUR_OPENROUTER_API_KEY_HERE" "lib\config\api_config.dart" >nul 2>&1
if %errorlevel% equ 0 (
    echo ⚠️  Please update your OpenRouter API key in lib\config\api_config.dart
)

findstr /C:"your-firebase-project-id" "lib\config\api_config.dart" >nul 2>&1
if %errorlevel% equ 0 (
    echo ⚠️  Please update your Firebase project ID in lib\config\api_config.dart
)

echo.

REM Generate project files if needed
echo 🔧 Generating project files...
dart --version >nul 2>&1
if %errorlevel% equ 0 (
    dart run build_runner build --delete-conflicting-outputs
    echo ✅ Generated project files
) else (
    echo ⚠️  Dart not found, skipping code generation
)

echo.

REM Final instructions
echo 🎉 Setup Complete!
echo ==================
echo.
echo Next steps:
echo 1. 🔥 Set up Firebase project (see docs\FIREBASE_AUTH_GUIDE.md)
echo 2. 🔑 Add your API keys to lib\config\api_config.dart
echo 3. 🎨 Customize app branding in lib\constants\app_constants.dart
echo 4. 📱 Run the app: flutter run
echo.
echo 📚 Documentation: Check the docs\ folder for detailed guides
echo 🐛 Issues: Create an issue on GitHub if you need help
echo.
echo Happy coding! 🚀
echo.
pause
