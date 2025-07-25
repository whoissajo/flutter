@echo off
echo Building Flutter APK...
flutter build apk --debug 2>&1
echo.
echo Build completed with exit code: %errorlevel%
pause
