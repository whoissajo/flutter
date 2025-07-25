# 🚀 Flutter AI Template

A comprehensive, production-ready Flutter template for building AI-powered mobile applications with Firebase backend, featuring authentication, real-time chat, and modern UI components.

> **⚠️ Important**: This template contains configuration files that need to be customized with your own API keys and Firebase project. Please follow the setup instructions carefully.

## ✨ **Features**

### 🎨 **User Experience**
- **Professional Splash Screen** with customizable branding
- **Interactive Onboarding** with smooth animations
- **Material Design 3** with light/dark theme support
- **Responsive Design** that works on all screen sizes

### 🔐 **Authentication**
- **Firebase Authentication** with email/password
- **Google Sign-In** integration
- **Apple Sign-In** support
- **Email verification** and password reset
- **Secure session management** and auto-login

### 👤 **Profile & Settings**
- **Comprehensive profile management** with editable information
- **Settings system** with appearance, AI, and privacy controls
- **Dark/Light mode** with custom theme colors
- **Font size adjustment** for accessibility
- **Account security** and data management

### 🤖 **AI Integration**
- **OpenRouter API** with multiple AI models
- **DeepSeek R1** for advanced reasoning
- **Real-time chat interface** with typing indicators
- **Voice input** with speech-to-text functionality (ready to enable)
- **Message persistence** and conversation management

### 🗄️ **Database**
- **Firestore Database** with offline support
- **Real-time synchronization** across devices
- **Flexible repository pattern** for any data type
- **User-based security** with comprehensive rules

## 📱 **Screenshots**

| Splash Screen | Onboarding | Authentication | AI Chat |
|---------------|------------|----------------|---------|
| ![Splash](docs/images/splash.png) | ![Onboarding](docs/images/onboarding.png) | ![Auth](docs/images/auth.png) | ![Chat](docs/images/chat.png) |

## 🚀 **Quick Start**

### **Prerequisites**
- **Flutter SDK** 3.24.0 or higher
- **Dart SDK** 3.5.0 or higher
- **Android Studio** or **VS Code** with Flutter extensions
- **Firebase Account** (free tier available)
- **OpenRouter Account** for AI features (optional)

### **1. Clone the Repository**
```bash
git clone https://github.com/yourusername/flutter-ai-template.git
cd flutter-ai-template
```

### **2. Install Dependencies**
```bash
# Install Flutter dependencies
flutter pub get

# For iOS (if developing for iOS)
cd ios && pod install && cd ..
```

### **3. Configure API Keys**
```bash
# Copy the template configuration file
cp lib/config/api_config.dart.template lib/config/api_config.dart

# Edit the configuration file with your API keys
# See detailed instructions below
```

### **4. Set Up Firebase**
Follow the [Firebase Setup Guide](docs/FIREBASE_AUTH_GUIDE.md) to:
1. Create a Firebase project
2. Add your app to Firebase
3. Download configuration files
4. Enable Authentication and Firestore

### **5. Run the App**
```bash
# Debug mode
flutter run

# Release mode
flutter run --release

# Build APK
flutter build apk --release
```

## 🔧 **Detailed Setup Instructions**

### **Step 1: Firebase Configuration**

#### **1.1 Create Firebase Project**
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Create a project"
3. Enter project name (e.g., "my-ai-app")
4. Enable Google Analytics (optional)
5. Create project

#### **1.2 Add Android App**
1. Click "Add app" → Android
2. Enter package name: `com.example.flutterTemplate` (or your custom package)
3. Download `google-services.json`
4. Place it in `android/app/google-services.json`

#### **1.3 Add iOS App (if needed)**
1. Click "Add app" → iOS
2. Enter bundle ID: `com.example.flutterTemplate`
3. Download `GoogleService-Info.plist`
4. Place it in `ios/Runner/GoogleService-Info.plist`

#### **1.4 Enable Authentication**
1. Go to Authentication → Sign-in method
2. Enable Email/Password
3. Enable Google (optional)
4. Enable Apple (optional, iOS only)

#### **1.5 Set Up Firestore**
1. Go to Firestore Database
2. Create database in test mode
3. Choose location closest to your users
4. Update security rules (see [Firestore Guide](docs/FIRESTORE_INTEGRATION.md))

### **Step 2: API Configuration**

#### **2.1 OpenRouter Setup (for AI features)**
1. Sign up at [OpenRouter](https://openrouter.ai)
2. Get your API key (starts with `sk-or-v1-`)
3. Choose your preferred AI model

#### **2.2 Configure API Keys**
Edit `lib/config/api_config.dart`:
```dart
class ApiConfig {
  // Replace with your actual OpenRouter API key
  static const String openRouterApiKey = 'sk-or-v1-your-actual-key-here';
  
  // Choose your preferred AI model
  static const String defaultAiModel = 'deepseek/deepseek-r1-0528';
  
  // Your app information
  static const String siteUrl = 'https://your-app-domain.com';
  static const String siteName = 'Your App Name';
  
  // Your Firebase project ID
  static const String firebaseProjectId = 'your-firebase-project-id';
}
```

### **Step 3: Customization**

#### **3.1 App Branding**
```dart
// lib/constants/app_constants.dart
class AppConstants {
  static const String appName = 'Your App Name';
  static const String appVersion = '1.0.0';
  // ... other constants
}
```

#### **3.2 Splash Screen**
Replace assets in `assets/images/splash/`:
- `splash_logo.png` (512x512px)
- Update colors in `lib/screens/splash/splash_screen.dart`

#### **3.3 Onboarding**
Update content in `lib/constants/onboarding_data.dart`:
```dart
final List<OnboardingData> onboardingPages = [
  OnboardingData(
    title: 'Your Feature Title',
    description: 'Your feature description',
    imagePath: 'assets/images/onboarding/your_image.png',
  ),
  // Add more pages...
];
```

#### **3.4 App Icons**
Replace app icons in:
- `android/app/src/main/res/mipmap-*/ic_launcher.png`
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

### **Step 4: Package Name & Bundle ID**

#### **4.1 Android Package Name**
1. Update `android/app/build.gradle.kts`:
```kotlin
android {
    namespace = "com.yourcompany.yourapp"
    // ...
}
```

2. Update `android/app/src/main/AndroidManifest.xml`:
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.yourcompany.yourapp">
```

#### **4.2 iOS Bundle ID**
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select Runner → General
3. Change Bundle Identifier to `com.yourcompany.yourapp`

### **Step 5: Build & Deploy**

#### **5.1 Debug Build**
```bash
flutter run
```

#### **5.2 Release Build**
```bash
# Android APK
flutter build apk --release

# Android App Bundle (for Play Store)
flutter build appbundle --release

# iOS (requires Xcode)
flutter build ios --release
```

## 📚 **Documentation**

### **Setup Guides**
- 📖 [**Complete Setup Guide**](docs/COMPLETE_SETUP_GUIDE.md) - Comprehensive setup instructions
- 🎨 [**Splash Screen Guide**](docs/SPLASH_SCREEN_GUIDE.md) - Customize splash screen and branding
- 🎯 [**Onboarding Guide**](docs/ONBOARDING_GUIDE.md) - Configure first-time user experience
- 🔐 [**Firebase Auth Guide**](docs/FIREBASE_AUTH_GUIDE.md) - Authentication setup and customization
- 🤖 [**AI Integration Guide**](docs/AI_INTEGRATION_GUIDE.md) - OpenRouter API and chat features
- 👤 [**Profile & Settings Guide**](docs/PROFILE_SETTINGS_GUIDE.md) - User management and customization
- 🗄️ [**Firestore Integration**](docs/FIRESTORE_INTEGRATION.md) - Database setup and usage
- 🔧 [**Firestore Setup**](docs/FIRESTORE_SETUP.md) - Quick database configuration

### **Technical Documentation**
- 📚 [**Code Documentation**](docs/CODE_DOCUMENTATION.md) - Architecture and code explanations
- 🏗️ [**Architecture Overview**](docs/ARCHITECTURE.md) - System design and patterns
- 🧪 [**Testing Guide**](docs/TESTING.md) - Testing strategies and examples

## 🎯 **Customization Examples**

### **Changing App Theme**
```dart
// lib/providers/theme_provider.dart
final lightThemeProvider = Provider<ThemeData>((ref) {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.purple, // Change primary color
      brightness: Brightness.light,
    ),
    // ... other theme properties
  );
});
```

### **Adding New AI Models**
```dart
// lib/config/api_config.dart
static const String defaultAiModel = 'anthropic/claude-3-sonnet';
// or
static const String defaultAiModel = 'openai/gpt-4';
```

### **Custom Onboarding Pages**
```dart
// lib/constants/onboarding_data.dart
final List<OnboardingData> onboardingPages = [
  OnboardingData(
    title: 'Welcome to MyApp',
    description: 'Discover amazing AI-powered features',
    imagePath: 'assets/images/onboarding/welcome.png',
  ),
  // Add your custom pages...
];
```

## 📁 **Project Structure**

```
flutter_template/
├── lib/
│   ├── config/
│   │   ├── api_config.dart.template  # API configuration template
│   │   └── api_config.dart          # Your actual API keys (gitignored)
│   ├── constants/                   # App constants and configurations
│   ├── models/                      # Data models
│   ├── providers/                   # State management (Riverpod)
│   ├── screens/                     # UI screens
│   ├── services/                    # Business logic and API calls
│   ├── utils/                       # Utility functions
│   └── widgets/                     # Reusable UI components
├── assets/
│   ├── images/
│   │   ├── onboarding/             # Onboarding images
│   │   └── splash/                 # Splash screen assets
├── docs/                           # Documentation
├── android/                        # Android-specific files
├── ios/                           # iOS-specific files
└── README.md                      # This file
```

## 🧪 **Testing**

### **Run Tests**
```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/

# Widget tests
flutter test test/widget_test.dart
```

### **Test Coverage**
```bash
# Generate coverage report
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## 🚀 **Deployment**

### **Android Play Store**
1. Create app bundle: `flutter build appbundle --release`
2. Upload to Play Console
3. Follow Play Store guidelines

### **iOS App Store**
1. Build iOS app: `flutter build ios --release`
2. Open Xcode and archive
3. Upload to App Store Connect

### **Firebase Hosting (Web)**
```bash
flutter build web
firebase deploy --only hosting
```

## 🤝 **Contributing**

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### **Code Style**
- Follow [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use meaningful variable names
- Add documentation for public APIs
- Write tests for new features

## 📄 **License**

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 **Acknowledgments**

- **Flutter Team** for the amazing framework
- **Firebase** for backend services
- **OpenRouter** for AI API access
- **Riverpod** for state management
- **Material Design** for UI guidelines

## 📞 **Support**

### **Documentation**
- 📖 Check the [docs/](docs/) folder for detailed guides
- 🔍 Search existing [GitHub Issues](https://github.com/yourusername/flutter-ai-template/issues)
- 💬 Join our [Discord Community](https://discord.gg/your-invite)

### **Getting Help**
1. **Read the documentation** in the `docs/` folder
2. **Check the code comments** for implementation details
3. **Create an issue** if you find a bug
4. **Start a discussion** for feature requests

### **Common Issues**
- **Build errors**: Run `flutter clean && flutter pub get`
- **Firebase issues**: Check `google-services.json` placement
- **AI not working**: Verify OpenRouter API key in `api_config.dart`
- **Authentication issues**: Check Firebase project configuration

## 🎯 **Roadmap**

### **Current Features**
- [x] Splash Screen & Onboarding
- [x] Firebase Authentication
- [x] AI Chat Integration
- [x] Profile & Settings management
- [x] Voice input (ready to enable)
- [x] Firestore Database
- [x] Dark/Light themes

### **Upcoming Features**
- [ ] Push notifications
- [ ] File sharing in chat
- [ ] Multi-language support
- [ ] Advanced AI features
- [ ] Analytics integration
- [ ] Payment integration
- [ ] Social features

---

**Made with ❤️ by the Flutter Community**

*Star ⭐ this repository if it helped you build something awesome!*
