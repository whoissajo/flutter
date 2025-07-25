@echo off
echo Generating SHA-1 Fingerprints for Firebase...
echo.

REM Try to find keytool in common Java locations
set KEYTOOL_PATH=""

REM Check Java installation paths
if exist "C:\Program Files\Java\jdk*\bin\keytool.exe" (
    for /d %%i in ("C:\Program Files\Java\jdk*") do (
        if exist "%%i\bin\keytool.exe" (
            set KEYTOOL_PATH="%%i\bin\keytool.exe"
            goto :found
        )
    )
)

if exist "C:\Program Files\Java\jre*\bin\keytool.exe" (
    for /d %%i in ("C:\Program Files\Java\jre*") do (
        if exist "%%i\bin\keytool.exe" (
            set KEYTOOL_PATH="%%i\bin\keytool.exe"
            goto :found
        )
    )
)

REM Check Android Studio JRE
if exist "C:\Program Files\Android\Android Studio\jre\bin\keytool.exe" (
    set KEYTOOL_PATH="C:\Program Files\Android\Android Studio\jre\bin\keytool.exe"
    goto :found
)

REM Check if keytool is in PATH
keytool -help >nul 2>&1
if %errorlevel% == 0 (
    set KEYTOOL_PATH=keytool
    goto :found
)

echo ERROR: keytool not found!
echo Please install Java JDK or add keytool to your PATH
echo.
echo Manual instructions:
echo 1. Find your Java installation directory
echo 2. Navigate to the bin folder
echo 3. Run this command:
echo    keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
echo.
pause
exit /b 1

:found
echo Found keytool at: %KEYTOOL_PATH%
echo.

REM Check if debug keystore exists
if not exist "%USERPROFILE%\.android\debug.keystore" (
    echo Creating .android directory...
    mkdir "%USERPROFILE%\.android" 2>nul
    
    echo Debug keystore not found. Creating one...
    %KEYTOOL_PATH% -genkey -v -keystore "%USERPROFILE%\.android\debug.keystore" -storepass android -alias androiddebugkey -keypass android -keyalg RSA -keysize 2048 -validity 10000 -dname "CN=Android Debug,O=Android,C=US"
    echo.
)

echo Generating DEBUG SHA-1 fingerprint...
echo =====================================
%KEYTOOL_PATH% -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android | findstr SHA1
echo.

echo.
echo Copy the SHA1 fingerprint above and add it to your Firebase project:
echo 1. Go to Firebase Console (https://console.firebase.google.com)
echo 2. Select your project: flutter-template-3887d
echo 3. Go to Project Settings (gear icon)
echo 4. Select your Android app
echo 5. Add the SHA1 fingerprint
echo 6. Download the updated google-services.json
echo.
pause
