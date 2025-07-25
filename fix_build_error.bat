@echo off
echo ========================================
echo Flutter Build Error Fix Script
echo ========================================
echo.

echo Step 1: Cleaning Flutter cache...
flutter clean
if %errorlevel% neq 0 (
    echo ERROR: Flutter clean failed
    pause
    exit /b 1
)

echo.
echo Step 2: Clearing pub cache...
flutter pub cache clean
if %errorlevel% neq 0 (
    echo WARNING: Pub cache clean failed, continuing...
)

echo.
echo Step 3: Removing build directory...
if exist "build" (
    rmdir /s /q "build"
    echo Build directory removed
) else (
    echo Build directory not found
)

echo.
echo Step 4: Removing .dart_tool directory...
if exist ".dart_tool" (
    rmdir /s /q ".dart_tool"
    echo .dart_tool directory removed
) else (
    echo .dart_tool directory not found
)

echo.
echo Step 5: Getting dependencies...
flutter pub get
if %errorlevel% neq 0 (
    echo ERROR: Flutter pub get failed
    pause
    exit /b 1
)

echo.
echo Step 6: Building APK (debug)...
flutter build apk --debug --no-shrink
if %errorlevel% neq 0 (
    echo ERROR: APK build failed
    echo.
    echo Trying with different flags...
    flutter build apk --debug --no-obfuscate --no-shrink
    if %errorlevel% neq 0 (
        echo ERROR: Alternative build also failed
        echo.
        echo Please try the manual solutions below:
        echo 1. Move project to C: drive
        echo 2. Or move Flutter SDK to F: drive
        echo 3. Or use Android Studio to build
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
pause
