# PowerShell script to generate release keystore and SHA-1 fingerprint
Write-Host "Creating Release Keystore for Production..." -ForegroundColor Green
Write-Host ""

# Find keytool (reuse the function from previous script)
function Find-Keytool {
    try {
        $null = Get-Command keytool -ErrorAction Stop
        return "keytool"
    } catch {}
    
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

$keytoolPath = Find-Keytool
if (-not $keytoolPath) {
    Write-Host "ERROR: keytool not found!" -ForegroundColor Red
    exit 1
}

Write-Host "Found keytool at: $keytoolPath" -ForegroundColor Green
Write-Host ""

# Create android directory if it doesn't exist
$androidDir = "$env:USERPROFILE\.android"
if (-not (Test-Path $androidDir)) {
    New-Item -ItemType Directory -Path $androidDir -Force | Out-Null
}

$releaseKeystorePath = "$androidDir\release.keystore"

# Check if release keystore already exists
if (Test-Path $releaseKeystorePath) {
    Write-Host "Release keystore already exists at: $releaseKeystorePath" -ForegroundColor Yellow
    $response = Read-Host "Do you want to create a new one? (y/N)"
    if ($response -ne "y" -and $response -ne "Y") {
        Write-Host "Using existing keystore..." -ForegroundColor Green
    } else {
        Remove-Item $releaseKeystorePath -Force
        Write-Host "Deleted existing keystore." -ForegroundColor Yellow
    }
}

# Create release keystore if it doesn't exist
if (-not (Test-Path $releaseKeystorePath)) {
    Write-Host "Creating release keystore..." -ForegroundColor Cyan
    Write-Host "Please provide the following information for your release keystore:" -ForegroundColor Yellow
    Write-Host ""
    
    # Get keystore information
    $keystorePassword = Read-Host "Enter keystore password (remember this!)" -AsSecureString
    $keystorePasswordPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($keystorePassword))
    
    $keyPassword = Read-Host "Enter key password (can be same as keystore password)" -AsSecureString
    $keyPasswordPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($keyPassword))
    
    $firstName = Read-Host "Enter your first name"
    $lastName = Read-Host "Enter your last name"
    $organization = Read-Host "Enter your organization (or press Enter for 'Flutter Template')"
    if ([string]::IsNullOrWhiteSpace($organization)) { $organization = "Flutter Template" }
    
    $city = Read-Host "Enter your city"
    $state = Read-Host "Enter your state/province"
    $country = Read-Host "Enter your country code (e.g., US, UK, CA)"
    
    # Create the distinguished name
    $dname = "CN=$firstName $lastName, O=$organization, L=$city, ST=$state, C=$country"
    
    Write-Host ""
    Write-Host "Creating keystore with the following information:" -ForegroundColor Cyan
    Write-Host "Distinguished Name: $dname" -ForegroundColor Gray
    Write-Host ""
    
    try {
        & $keytoolPath -genkey -v -keystore $releaseKeystorePath -alias release -keyalg RSA -keysize 2048 -validity 10000 -storepass $keystorePasswordPlain -keypass $keyPasswordPlain -dname $dname
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host ""
            Write-Host "Release keystore created successfully!" -ForegroundColor Green
            
            # Save keystore info to a file
            $keystoreInfo = @"
# Release Keystore Information
# Generated on: $(Get-Date)
# 
# Keystore Path: $releaseKeystorePath
# Keystore Password: $keystorePasswordPlain
# Key Alias: release
# Key Password: $keyPasswordPlain
# Distinguished Name: $dname
#
# IMPORTANT: Keep this information secure and backed up!
# You will need this information to sign your app for production.
"@
            $keystoreInfo | Out-File -FilePath "$androidDir\release_keystore_info.txt" -Encoding UTF8
            Write-Host "Keystore information saved to: $androidDir\release_keystore_info.txt" -ForegroundColor Yellow
            Write-Host "IMPORTANT: Keep this file secure and backed up!" -ForegroundColor Red
        } else {
            Write-Host "Failed to create keystore!" -ForegroundColor Red
            exit 1
        }
    } catch {
        Write-Host "Error creating keystore: $_" -ForegroundColor Red
        exit 1
    }
}

# Generate SHA-1 fingerprint for release keystore
Write-Host ""
Write-Host "Generating RELEASE SHA-1 fingerprint..." -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

if (Test-Path "$androidDir\release_keystore_info.txt") {
    $keystoreInfo = Get-Content "$androidDir\release_keystore_info.txt"
    $passwordLine = $keystoreInfo | Where-Object { $_ -match "Keystore Password:" }
    if ($passwordLine) {
        $password = ($passwordLine -split "Keystore Password:")[1].Trim()
        
        try {
            $output = & $keytoolPath -list -v -keystore $releaseKeystorePath -alias release -storepass $password 2>&1
            $sha1Line = $output | Where-Object { $_ -match "SHA1:" }
            
            if ($sha1Line) {
                Write-Host $sha1Line -ForegroundColor Green
                $sha1 = ($sha1Line -split "SHA1:")[1].Trim()
                Write-Host ""
                Write-Host "Your RELEASE SHA-1 fingerprint is: $sha1" -ForegroundColor Yellow
                
                # Save SHA-1 to file
                Add-Content -Path "$androidDir\release_keystore_info.txt" -Value ""
                Add-Content -Path "$androidDir\release_keystore_info.txt" -Value "# SHA-1 Fingerprint: $sha1"
                
            } else {
                Write-Host "Could not extract SHA-1 fingerprint. Full output:" -ForegroundColor Red
                $output | ForEach-Object { Write-Host $_ }
            }
        } catch {
            Write-Host "Error generating fingerprint: $_" -ForegroundColor Red
        }
    } else {
        Write-Host "Could not find keystore password in info file." -ForegroundColor Red
        $manualPassword = Read-Host "Please enter the keystore password"
        
        try {
            $output = & $keytoolPath -list -v -keystore $releaseKeystorePath -alias release -storepass $manualPassword 2>&1
            $sha1Line = $output | Where-Object { $_ -match "SHA1:" }
            
            if ($sha1Line) {
                Write-Host $sha1Line -ForegroundColor Green
                $sha1 = ($sha1Line -split "SHA1:")[1].Trim()
                Write-Host ""
                Write-Host "Your RELEASE SHA-1 fingerprint is: $sha1" -ForegroundColor Yellow
            }
        } catch {
            Write-Host "Error generating fingerprint: $_" -ForegroundColor Red
        }
    }
} else {
    Write-Host "Keystore info file not found. Please enter keystore password manually." -ForegroundColor Yellow
    $manualPassword = Read-Host "Enter keystore password"
    
    try {
        $output = & $keytoolPath -list -v -keystore $releaseKeystorePath -alias release -storepass $manualPassword 2>&1
        $sha1Line = $output | Where-Object { $_ -match "SHA1:" }
        
        if ($sha1Line) {
            Write-Host $sha1Line -ForegroundColor Green
            $sha1 = ($sha1Line -split "SHA1:")[1].Trim()
            Write-Host ""
            Write-Host "Your RELEASE SHA-1 fingerprint is: $sha1" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "Error generating fingerprint: $_" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Summary:" -ForegroundColor Cyan
Write-Host "========" -ForegroundColor Cyan
Write-Host "DEBUG SHA-1:   9B:8F:6F:F5:78:94:6A:36:35:29:4B:FC:9E:DE:F0:DA:6D:FA:74:A3" -ForegroundColor Green
if ($sha1) {
    Write-Host "RELEASE SHA-1: $sha1" -ForegroundColor Green
}
Write-Host ""
Write-Host "Add BOTH fingerprints to your Firebase project!" -ForegroundColor Yellow
Write-Host ""
Read-Host "Press Enter to continue..."
