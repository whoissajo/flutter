@echo off
echo Deploying Firestore Rules and Indexes...
echo.

REM Check if Firebase CLI is installed
firebase --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Firebase CLI is not installed!
    echo.
    echo Please install Firebase CLI first:
    echo 1. Install Node.js from https://nodejs.org/
    echo 2. Run: npm install -g firebase-tools
    echo 3. Run: firebase login
    echo 4. Then run this script again
    echo.
    pause
    exit /b 1
)

echo Firebase CLI found!
echo.

REM Check if user is logged in
firebase projects:list >nul 2>&1
if %errorlevel% neq 0 (
    echo You need to login to Firebase first.
    echo Running: firebase login
    echo.
    firebase login
    if %errorlevel% neq 0 (
        echo Login failed!
        pause
        exit /b 1
    )
)

echo Checking Firebase project...
firebase use --add
if %errorlevel% neq 0 (
    echo Failed to set Firebase project!
    echo.
    echo Please make sure you have access to the project: flutter-template-3887d
    pause
    exit /b 1
)

echo.
echo Deploying Firestore rules...
firebase deploy --only firestore:rules
if %errorlevel% neq 0 (
    echo Failed to deploy Firestore rules!
    pause
    exit /b 1
)

echo.
echo Deploying Firestore indexes...
firebase deploy --only firestore:indexes
if %errorlevel% neq 0 (
    echo Failed to deploy Firestore indexes!
    echo Note: This might be normal if indexes already exist.
)

echo.
echo ========================================
echo Firestore deployment completed!
echo ========================================
echo.
echo Your Firestore rules have been deployed successfully.
echo You can now test your app with the new security rules.
echo.
echo Next steps:
echo 1. Install the updated APK on your device
echo 2. Sign in to your app
echo 3. Send some chat messages
echo 4. Check Firebase Console to see the data
echo.
pause
