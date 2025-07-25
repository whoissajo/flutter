#!/bin/bash

# Flutter AI Template Setup Script
# This script helps you set up the template with your own configuration

echo "🚀 Flutter AI Template Setup"
echo "=============================="
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed or not in PATH"
    echo "Please install Flutter from https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo "✅ Flutter found: $(flutter --version | head -n 1)"
echo ""

# Check if config file exists
if [ ! -f "lib/config/api_config.dart" ]; then
    echo "📝 Creating API configuration file..."
    cp lib/config/api_config.dart.template lib/config/api_config.dart
    echo "✅ Created lib/config/api_config.dart"
    echo ""
    echo "⚠️  IMPORTANT: Please edit lib/config/api_config.dart with your API keys"
    echo "   - OpenRouter API key for AI features"
    echo "   - Firebase project ID"
    echo "   - Your app domain and name"
    echo ""
else
    echo "✅ API configuration file already exists"
    echo ""
fi

# Install dependencies
echo "📦 Installing Flutter dependencies..."
flutter pub get

if [ $? -eq 0 ]; then
    echo "✅ Dependencies installed successfully"
else
    echo "❌ Failed to install dependencies"
    exit 1
fi

echo ""

# Check for Firebase configuration
echo "🔥 Checking Firebase configuration..."

if [ ! -f "android/app/google-services.json" ]; then
    echo "⚠️  Missing: android/app/google-services.json"
    echo "   Please download from Firebase Console and place it in android/app/"
fi

if [ ! -f "ios/Runner/GoogleService-Info.plist" ]; then
    echo "⚠️  Missing: ios/Runner/GoogleService-Info.plist"
    echo "   Please download from Firebase Console and place it in ios/Runner/"
fi

echo ""

# Check API configuration
echo "🔑 Checking API configuration..."
if grep -q "YOUR_OPENROUTER_API_KEY_HERE" lib/config/api_config.dart; then
    echo "⚠️  Please update your OpenRouter API key in lib/config/api_config.dart"
fi

if grep -q "your-firebase-project-id" lib/config/api_config.dart; then
    echo "⚠️  Please update your Firebase project ID in lib/config/api_config.dart"
fi

echo ""

# Generate project files if needed
echo "🔧 Generating project files..."
if command -v dart &> /dev/null; then
    dart run build_runner build --delete-conflicting-outputs
    echo "✅ Generated project files"
else
    echo "⚠️  Dart not found, skipping code generation"
fi

echo ""

# Final instructions
echo "🎉 Setup Complete!"
echo "=================="
echo ""
echo "Next steps:"
echo "1. 🔥 Set up Firebase project (see docs/FIREBASE_AUTH_GUIDE.md)"
echo "2. 🔑 Add your API keys to lib/config/api_config.dart"
echo "3. 🎨 Customize app branding in lib/constants/app_constants.dart"
echo "4. 📱 Run the app: flutter run"
echo ""
echo "📚 Documentation: Check the docs/ folder for detailed guides"
echo "🐛 Issues: Create an issue on GitHub if you need help"
echo ""
echo "Happy coding! 🚀"
