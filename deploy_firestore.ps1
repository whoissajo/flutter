# PowerShell script to deploy Firestore rules and indexes
Write-Host "Deploying Firestore Rules and Indexes..." -ForegroundColor Green
Write-Host ""

# Check if Firebase CLI is installed
try {
    $firebaseVersion = firebase --version 2>$null
    Write-Host "Firebase CLI found: $firebaseVersion" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Firebase CLI is not installed!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install Firebase CLI first:" -ForegroundColor Yellow
    Write-Host "1. Install Node.js from https://nodejs.org/"
    Write-Host "2. Run: npm install -g firebase-tools"
    Write-Host "3. Run: firebase login"
    Write-Host "4. Then run this script again"
    Write-Host ""
    Read-Host "Press Enter to exit..."
    exit 1
}

Write-Host ""

# Check if user is logged in
try {
    $projects = firebase projects:list 2>$null
    Write-Host "Firebase authentication verified!" -ForegroundColor Green
} catch {
    Write-Host "You need to login to Firebase first." -ForegroundColor Yellow
    Write-Host "Running: firebase login" -ForegroundColor Cyan
    Write-Host ""
    
    firebase login
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Login failed!" -ForegroundColor Red
        Read-Host "Press Enter to exit..."
        exit 1
    }
}

Write-Host ""
Write-Host "Setting up Firebase project..." -ForegroundColor Cyan

# Set the Firebase project
try {
    firebase use flutter-template-3887d --token $env:FIREBASE_TOKEN 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Setting project interactively..." -ForegroundColor Yellow
        firebase use --add
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Failed to set Firebase project!" -ForegroundColor Red
            Write-Host ""
            Write-Host "Please make sure you have access to the project: flutter-template-3887d" -ForegroundColor Yellow
            Read-Host "Press Enter to exit..."
            exit 1
        }
    }
    Write-Host "Firebase project set successfully!" -ForegroundColor Green
} catch {
    Write-Host "Error setting Firebase project: $_" -ForegroundColor Red
    Read-Host "Press Enter to exit..."
    exit 1
}

Write-Host ""
Write-Host "Deploying Firestore rules..." -ForegroundColor Cyan

try {
    firebase deploy --only firestore:rules
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Firestore rules deployed successfully!" -ForegroundColor Green
    } else {
        Write-Host "Failed to deploy Firestore rules!" -ForegroundColor Red
        Read-Host "Press Enter to exit..."
        exit 1
    }
} catch {
    Write-Host "Error deploying Firestore rules: $_" -ForegroundColor Red
    Read-Host "Press Enter to exit..."
    exit 1
}

Write-Host ""
Write-Host "Deploying Firestore indexes..." -ForegroundColor Cyan

try {
    firebase deploy --only firestore:indexes
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Firestore indexes deployed successfully!" -ForegroundColor Green
    } else {
        Write-Host "Warning: Firestore indexes deployment had issues." -ForegroundColor Yellow
        Write-Host "This might be normal if indexes already exist." -ForegroundColor Yellow
    }
} catch {
    Write-Host "Warning: Error deploying Firestore indexes: $_" -ForegroundColor Yellow
    Write-Host "This might be normal if indexes already exist." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "Firestore deployment completed!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Your Firestore rules have been deployed successfully." -ForegroundColor Cyan
Write-Host "You can now test your app with the new security rules." -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Install the updated APK on your device"
Write-Host "2. Sign in to your app"
Write-Host "3. Send some chat messages"
Write-Host "4. Check Firebase Console to see the data"
Write-Host ""
Read-Host "Press Enter to continue..."
