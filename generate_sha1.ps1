# PowerShell script to generate SHA-1 fingerprint for Firebase
Write-Host "Generating SHA-1 Fingerprints for Firebase..." -ForegroundColor Green
Write-Host ""

# Function to find keytool
function Find-Keytool {
    # Check if keytool is in PATH
    try {
        $null = Get-Command keytool -ErrorAction Stop
        return "keytool"
    } catch {
        # Not in PATH, search for it
    }
    
    # Common Java installation paths
    $javaPaths = @(
        "C:\Program Files\Java\*\bin\keytool.exe",
        "C:\Program Files (x86)\Java\*\bin\keytool.exe",
        "C:\Program Files\Android\Android Studio\jre\bin\keytool.exe",
        "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe"
    )
    
    foreach ($path in $javaPaths) {
        $found = Get-ChildItem -Path $path -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($found) {
            return $found.FullName
        }
    }
    
    return $null
}

# Find keytool
$keytoolPath = Find-Keytool

if (-not $keytoolPath) {
    Write-Host "ERROR: keytool not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install Java JDK or Android Studio" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Manual instructions:" -ForegroundColor Cyan
    Write-Host "1. Install Java JDK from https://www.oracle.com/java/technologies/downloads/"
    Write-Host "2. Or install Android Studio from https://developer.android.com/studio"
    Write-Host "3. Then run this command manually:"
    Write-Host "   keytool -list -v -keystore `"$env:USERPROFILE\.android\debug.keystore`" -alias androiddebugkey -storepass android -keypass android"
    exit 1
}

Write-Host "Found keytool at: $keytoolPath" -ForegroundColor Green
Write-Host ""

# Check if debug keystore exists
$keystorePath = "$env:USERPROFILE\.android\debug.keystore"
$androidDir = "$env:USERPROFILE\.android"

if (-not (Test-Path $androidDir)) {
    Write-Host "Creating .android directory..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $androidDir -Force | Out-Null
}

if (-not (Test-Path $keystorePath)) {
    Write-Host "Debug keystore not found. Creating one..." -ForegroundColor Yellow
    & $keytoolPath -genkey -v -keystore $keystorePath -storepass android -alias androiddebugkey -keypass android -keyalg RSA -keysize 2048 -validity 10000 -dname "CN=Android Debug,O=Android,C=US"
    Write-Host ""
}

Write-Host "Generating DEBUG SHA-1 fingerprint..." -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

try {
    $output = & $keytoolPath -list -v -keystore $keystorePath -alias androiddebugkey -storepass android -keypass android 2>&1
    $sha1Line = $output | Where-Object { $_ -match "SHA1:" }
    
    if ($sha1Line) {
        Write-Host $sha1Line -ForegroundColor Green
        $sha1 = ($sha1Line -split "SHA1:")[1].Trim()
        Write-Host ""
        Write-Host "Your SHA-1 fingerprint is: $sha1" -ForegroundColor Yellow
    } else {
        Write-Host "Full output:" -ForegroundColor Gray
        $output | ForEach-Object { Write-Host $_ }
    }
} catch {
    Write-Host "Error generating fingerprint: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Copy the SHA1 fingerprint above"
Write-Host "2. Go to Firebase Console: https://console.firebase.google.com"
Write-Host "3. Select your project: flutter-template-3887d"
Write-Host "4. Go to Project Settings (gear icon)"
Write-Host "5. Select your Android app (com.tmc.fluttertemplate)"
Write-Host "6. Add the SHA1 fingerprint"
Write-Host "7. Download the updated google-services.json (optional)"
Write-Host ""
Read-Host "Press Enter to continue..."
