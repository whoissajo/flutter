# 🔧 **Environment Setup Guide**

This guide helps you set up your development environment and configure the Flutter AI Template with your own credentials.

## 🚨 **Important Security Notice**

This template includes configuration files that **MUST** be customized with your own credentials:

- ✅ **Safe to commit**: Template files (`.template` extension)
- ❌ **Never commit**: Actual configuration files with real API keys
- ✅ **Gitignored**: All sensitive files are already in `.gitignore`

## 📋 **Prerequisites**

### **Required Software**
- **Flutter SDK** 3.24.0+
- **Dart SDK** 3.5.0+
- **Android Studio** or **VS Code**
- **Git** for version control

### **Required Accounts**
- **Firebase Account** (free tier available)
- **OpenRouter Account** (for AI features)
- **Google Cloud Account** (for Google Sign-In)

## 🔧 **Step-by-Step Setup**

### **Step 1: Clone and Initial Setup**

```bash
# Clone the repository
git clone https://github.com/yourusername/flutter-ai-template.git
cd flutter-ai-template

# Run setup script (Linux/Mac)
chmod +x setup.sh
./setup.sh

# Or run setup script (Windows)
setup.bat
```

### **Step 2: Configure API Keys**

#### **2.1 Create Configuration File**
```bash
# Copy template to actual config file
cp lib/config/api_config.dart.template lib/config/api_config.dart
```

#### **2.2 Edit Configuration**
Open `lib/config/api_config.dart` and update:

```dart
class ApiConfig {
  // 🔑 OpenRouter API Key (get from https://openrouter.ai)
  static const String openRouterApiKey = 'sk-or-v1-YOUR_ACTUAL_KEY_HERE';
  
  // 🤖 AI Model (choose your preferred model)
  static const String defaultAiModel = 'deepseek/deepseek-r1-0528';
  
  // 🌐 Your App Information
  static const String siteUrl = 'https://your-app-domain.com';
  static const String siteName = 'Your App Name';
  
  // 🔥 Firebase Project ID
  static const String firebaseProjectId = 'your-firebase-project-id';
}
```

### **Step 3: Firebase Setup**

#### **3.1 Create Firebase Project**
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Create a project"
3. Enter your project name
4. Enable/disable Google Analytics as needed
5. Create project

#### **3.2 Add Android App**
1. Click "Add app" → Android (🤖)
2. **Package name**: `com.yourcompany.yourapp`
3. **App nickname**: Your App Name
4. Download `google-services.json`
5. Place in `android/app/google-services.json`

#### **3.3 Add iOS App**
1. Click "Add app" → iOS (🍎)
2. **Bundle ID**: `com.yourcompany.yourapp`
3. **App nickname**: Your App Name
4. Download `GoogleService-Info.plist`
5. Place in `ios/Runner/GoogleService-Info.plist`

#### **3.4 Enable Authentication**
1. Go to **Authentication** → **Sign-in method**
2. Enable **Email/Password**
3. Enable **Google** (optional)
4. Enable **Apple** (optional, iOS only)

#### **3.5 Set Up Firestore**
1. Go to **Firestore Database**
2. Create database in **test mode**
3. Choose location closest to your users
4. Update security rules (see below)

### **Step 4: Update Package Names**

#### **4.1 Android Package Name**
Edit `android/app/build.gradle.kts`:
```kotlin
android {
    namespace = "com.yourcompany.yourapp"
    compileSdk = flutter.compileSdkVersion
    // ...
}
```

Edit `android/app/src/main/AndroidManifest.xml`:
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.yourcompany.yourapp">
```

#### **4.2 iOS Bundle ID**
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select **Runner** → **General**
3. Change **Bundle Identifier** to `com.yourcompany.yourapp`

### **Step 5: Customize App Branding**

#### **5.1 App Constants**
Edit `lib/constants/app_constants.dart`:
```dart
class AppConstants {
  static const String appName = 'Your App Name';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Your app description';
}
```

#### **5.2 Splash Screen**
Replace `assets/images/splash/splash_logo.png` with your logo (512x512px)

#### **5.3 App Icons**
Replace app icons in:
- `android/app/src/main/res/mipmap-*/ic_launcher.png`
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

#### **5.4 Onboarding Content**
Edit `lib/constants/onboarding_data.dart`:
```dart
final List<OnboardingData> onboardingPages = [
  OnboardingData(
    title: 'Welcome to Your App',
    description: 'Your app description here',
    imagePath: 'assets/images/onboarding/welcome.png',
  ),
  // Add more pages...
];
```

## 🔒 **Security Configuration**

### **Firestore Security Rules**
Update your Firestore rules in Firebase Console:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Chat messages - users can only access their own
    match /chats/{userId}/messages/{messageId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### **Environment Variables (Production)**
For production builds, use environment variables:

```bash
# Build with environment variables
flutter build apk --dart-define=OPENROUTER_API_KEY=your-key \
                  --dart-define=FIREBASE_PROJECT_ID=your-project-id
```

## 🧪 **Testing Your Setup**

### **1. Run the App**
```bash
flutter run
```

### **2. Test Features**
- ✅ Splash screen displays
- ✅ Onboarding works
- ✅ Authentication (sign up/login)
- ✅ AI chat responds
- ✅ Profile management
- ✅ Settings work

### **3. Check Logs**
```bash
# View logs
flutter logs

# Debug mode with verbose logging
flutter run --debug --verbose
```

## 🚀 **Deployment Preparation**

### **1. Production Firebase Project**
Create separate Firebase projects for:
- **Development**: `your-app-dev`
- **Production**: `your-app-prod`

### **2. Release Build Configuration**
```bash
# Android release
flutter build apk --release

# iOS release
flutter build ios --release
```

### **3. Environment-Specific Builds**
```bash
# Development build
flutter build apk --dart-define=ENVIRONMENT=development

# Production build
flutter build apk --dart-define=ENVIRONMENT=production
```

## 🔍 **Troubleshooting**

### **Common Issues**

#### **"API key not configured" Error**
- Check `lib/config/api_config.dart` exists
- Verify API key is not the template placeholder
- Ensure file is not gitignored accidentally

#### **Firebase Connection Issues**
- Verify `google-services.json` is in `android/app/`
- Check package name matches Firebase configuration
- Ensure Firebase project is active

#### **Build Errors**
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

#### **Authentication Not Working**
- Check Firebase Authentication is enabled
- Verify SHA-1 fingerprint is added to Firebase
- Test with a simple email/password first

### **Getting Help**
1. Check the [documentation](../README.md)
2. Search [GitHub Issues](https://github.com/yourusername/flutter-ai-template/issues)
3. Create a new issue with:
   - Error message
   - Steps to reproduce
   - Your environment details

## 📚 **Next Steps**

After setup is complete:
1. 📖 Read the [Complete Setup Guide](COMPLETE_SETUP_GUIDE.md)
2. 🎨 Customize your [Splash Screen](SPLASH_SCREEN_GUIDE.md)
3. 🤖 Configure [AI Integration](AI_INTEGRATION_GUIDE.md)
4. 👤 Set up [Profile & Settings](PROFILE_SETTINGS_GUIDE.md)

---

**🎉 Congratulations!** Your Flutter AI Template is now configured and ready for development!
