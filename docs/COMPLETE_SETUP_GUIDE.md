# 📱 Flutter AI Template - Complete Setup Guide

## 🎯 **Overview**

This Flutter template provides a complete foundation for building AI-powered mobile applications with:
- **Splash Screen & Onboarding**: Professional first-time user experience
- **Firebase Authentication**: Email/password + Google Sign-In
- **AI Integration**: OpenRouter API with DeepSeek R1 model
- **Firestore Database**: Flexible data storage with offline support
- **Material Design 3**: Modern, responsive UI

## 📋 **Table of Contents**

1. [Project Setup](#1-project-setup)
2. [Splash Screen Configuration](#2-splash-screen-configuration)
3. [Onboarding Setup](#3-onboarding-setup)
4. [Firebase Authentication](#4-firebase-authentication)
5. [AI Integration (OpenRouter)](#5-ai-integration-openrouter)
6. [Firestore Database](#6-firestore-database)
7. [Customization Guide](#7-customization-guide)
8. [Testing & Deployment](#8-testing--deployment)

---

## 1. 🚀 **Project Setup**

### **Prerequisites**
- Flutter SDK 3.24.0 or higher
- Android Studio / VS Code
- Firebase account
- OpenRouter account (for AI features)

### **Initial Setup**
```bash
# Clone or download the template
git clone <your-template-repo>
cd flutter_template

# Install dependencies
flutter pub get

# Generate necessary files
flutter packages pub run build_runner build
```

### **Project Structure**
```
lib/
├── constants/          # App-wide constants
├── models/            # Data models
├── providers/         # Riverpod state management
├── repositories/      # Data access layer
├── screens/          # UI screens
├── services/         # Business logic services
├── utils/            # Utility functions
├── widgets/          # Reusable UI components
└── main.dart         # App entry point

assets/
├── images/           # Image assets
├── icons/           # Icon assets
└── splash/          # Splash screen assets

docs/                # Documentation
```

---

## 2. 🎨 **Splash Screen Configuration**

### **Image Requirements**

#### **Android Splash Images**
Create these images and place them in `assets/splash/`:

| File Name | Resolution | Purpose |
|-----------|------------|---------|
| `splash_logo.png` | 512x512px | Main logo (square) |
| `splash_background.png` | 1080x1920px | Background image (optional) |
| `splash_icon.png` | 192x192px | Small icon version |

#### **iOS Splash Images** (if supporting iOS)
| File Name | Resolution | Device |
|-----------|------------|--------|
| `splash_1x.png` | 320x568px | iPhone SE |
| `splash_2x.png` | 750x1334px | iPhone 8 |
| `splash_3x.png` | 1242x2208px | iPhone 8 Plus |

### **Configuration Steps**

#### **Step 1: Add Images**
1. Create your splash screen images with the specifications above
2. Place them in the `assets/splash/` directory
3. Ensure images are PNG format with transparent backgrounds

#### **Step 2: Update pubspec.yaml**
The template already includes splash configuration:
```yaml
flutter_native_splash:
  color: "#FFFFFF"                    # Background color
  image: assets/splash/splash_logo.png # Your logo
  android_12:
    image: assets/splash/splash_logo.png
    color: "#FFFFFF"
  web: false
```

#### **Step 3: Generate Splash Screen**
```bash
flutter pub run flutter_native_splash:create
```

### **Customization Options**

#### **Colors**
Edit in `pubspec.yaml`:
```yaml
flutter_native_splash:
  color: "#YOUR_HEX_COLOR"           # Background color
  color_dark: "#YOUR_DARK_COLOR"     # Dark mode background
```

#### **Logo Positioning**
```yaml
flutter_native_splash:
  image: assets/splash/splash_logo.png
  fill: true                         # Fill entire screen
  # OR
  android_gravity: center            # Logo position
  ios_content_mode: center
```

### **Brand Guidelines**
- **Logo**: Should be your app's primary logo
- **Colors**: Match your brand colors
- **Simplicity**: Keep it clean and professional
- **Contrast**: Ensure logo is visible on background

---

## 3. 🎯 **Onboarding Setup**

### **Current Onboarding Screens**

The template includes 3 onboarding screens:

#### **Screen 1: Welcome**
- **Title**: "Welcome to Flutter Template"
- **Description**: App introduction
- **Image**: `assets/images/onboarding_1.png`

#### **Screen 2: Features**
- **Title**: "Powerful Features"
- **Description**: Key app features
- **Image**: `assets/images/onboarding_2.png`

#### **Screen 3: Get Started**
- **Title**: "Get Started"
- **Description**: Ready to begin
- **Image**: `assets/images/onboarding_3.png`

### **Customizing Onboarding**

#### **Step 1: Replace Images**
Create and add your onboarding images:

| File Name | Resolution | Purpose |
|-----------|------------|---------|
| `onboarding_1.png` | 300x300px | First screen illustration |
| `onboarding_2.png` | 300x300px | Second screen illustration |
| `onboarding_3.png` | 300x300px | Third screen illustration |

#### **Step 2: Update Content**
Edit `lib/constants/app_constants.dart`:

```dart
class AppConstants {
  // Onboarding content
  static const List<OnboardingPage> onboardingPages = [
    OnboardingPage(
      title: 'Your App Title',
      description: 'Your app description here...',
      imagePath: 'assets/images/onboarding_1.png',
    ),
    OnboardingPage(
      title: 'Your Second Screen',
      description: 'Second screen description...',
      imagePath: 'assets/images/onboarding_2.png',
    ),
    OnboardingPage(
      title: 'Get Started',
      description: 'Ready to begin your journey...',
      imagePath: 'assets/images/onboarding_3.png',
    ),
  ];
}
```

#### **Step 3: Customize Colors**
Edit the theme in `lib/utils/app_theme.dart`:

```dart
static const Color primaryColor = Color(0xFF6366F1);     // Your primary color
static const Color secondaryColor = Color(0xFF8B5CF6);   // Your secondary color
static const Color accentColor = Color(0xFF06B6D4);      // Your accent color
```

### **Adding More Onboarding Screens**

To add more screens:

1. **Add more OnboardingPage objects** to the list in `app_constants.dart`
2. **Add corresponding images** to `assets/images/`
3. **Update pubspec.yaml** to include new images

### **Onboarding Logic**

The onboarding system automatically:
- Shows on first app launch
- Saves completion state to SharedPreferences
- Skips on subsequent launches
- Can be reset for testing

---

## 4. 🔐 **Firebase Authentication**

### **Setup Requirements**

#### **Step 1: Firebase Project Setup**
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create new project or use existing: `flutter-template-3887d`
3. Enable Authentication
4. Enable Email/Password and Google Sign-In providers

#### **Step 2: Android Configuration**
1. **Download `google-services.json`** from Firebase Console
2. **Place it in**: `android/app/google-services.json`
3. **Add SHA-1 fingerprint** for Google Sign-In (see SHA-1 generation guide below)

#### **Step 3: iOS Configuration** (if supporting iOS)
1. **Download `GoogleService-Info.plist`** from Firebase Console
2. **Place it in**: `ios/Runner/GoogleService-Info.plist`

### **SHA-1 Fingerprint Generation**

#### **For Debug (Development)**
Run the PowerShell script we created:
```bash
powershell -ExecutionPolicy Bypass -File generate_sha1.ps1
```

Or manually:
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

#### **For Release (Production)**
Run the release keystore script:
```bash
powershell -ExecutionPolicy Bypass -File generate_release_keystore.ps1
```

#### **Add to Firebase**
1. Go to Firebase Console → Project Settings
2. Select your Android app
3. Add the SHA-1 fingerprint
4. Download updated `google-services.json`

### **Authentication Features**

#### **Email/Password Authentication**
- User registration with email verification
- Secure password requirements
- Password reset functionality
- Profile management

#### **Google Sign-In**
- One-tap Google authentication
- Automatic profile information retrieval
- Seamless user experience

#### **User Profile Management**
- Display name editing
- Profile photo support
- Email verification status
- Account deletion

### **Customizing Authentication**

#### **Password Requirements**
Edit in `lib/services/auth_service.dart`:
```dart
bool _isPasswordValid(String password) {
  return password.length >= 8 &&           // Minimum length
         password.contains(RegExp(r'[A-Z]')) &&  // Uppercase letter
         password.contains(RegExp(r'[0-9]'));    // Number
}
```

#### **Email Validation**
```dart
bool _isEmailValid(String email) {
  return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
}
```

---

## 5. 🤖 **AI Integration (OpenRouter)**

### **OpenRouter Setup**

#### **Step 1: Get API Key**
1. Sign up at [OpenRouter](https://openrouter.ai)
2. Get your API key: `sk-or-v1-...`
3. Choose your preferred model (default: DeepSeek R1)

#### **Step 2: Configure API Key**
Edit `lib/services/openrouter_service.dart`:
```dart
class OpenRouterService {
  static const String _apiKey = 'YOUR_OPENROUTER_API_KEY_HERE';
  static const String _defaultModel = 'deepseek/deepseek-r1-0528';
}
```

### **Supported AI Models**

| Model | Description | Cost per 1K tokens |
|-------|-------------|-------------------|
| `deepseek/deepseek-r1-0528` | Advanced reasoning | $0.14 |
| `openai/gpt-4o` | OpenAI's latest | $5.00 |
| `openai/gpt-3.5-turbo` | Fast and efficient | $0.50 |
| `anthropic/claude-3-haiku` | Anthropic's model | $0.25 |

### **Customizing AI Behavior**

#### **System Prompt**
Edit in `lib/services/openrouter_service.dart`:
```dart
ChatMessage createSystemMessage() {
  return ChatMessage.system(
    'You are a helpful AI assistant for [YOUR APP NAME]. '
    'Provide concise, helpful responses related to [YOUR DOMAIN]. '
    'Keep answers brief unless detailed explanations are requested.'
  );
}
```

#### **Model Parameters**
```dart
final response = await sendMessage(
  messages: messages,
  model: 'deepseek/deepseek-r1-0528',
  maxTokens: 1000,        // Response length limit
  temperature: 0.7,       // Creativity (0.0-1.0)
  topP: 1.0,             // Nucleus sampling
);
```

### **Chat Interface Customization**

#### **Message Styling**
Edit `lib/screens/home/home_screen.dart`:
```dart
// User message bubble color
color: isUser 
    ? theme.colorScheme.primary      // Your brand color
    : theme.colorScheme.surface,     // AI message color

// Message text styling
style: theme.textTheme.bodyMedium?.copyWith(
  color: isUser 
      ? theme.colorScheme.onPrimary 
      : theme.colorScheme.onSurface,
  fontSize: 16,                      // Adjust font size
),
```

#### **Chat Suggestions**
Update the empty state suggestions:
```dart
...[
  '• "What is [your domain]?"',
  '• "How do I [common task]?"',
  '• "Help me with [your feature]"',
  '• "Tell me about [your service]"',
].map((suggestion) => ...)
```

---

## 6. 🗄️ **Firestore Database**

### **Database Structure**

```
/users/{userId}/
├── conversations/{conversationId}/
│   ├── title: string
│   ├── model: string
│   ├── messageCount: number
│   ├── createdAt: timestamp
│   ├── updatedAt: timestamp
│   └── messages/{messageId}/
│       ├── role: "user" | "assistant" | "system"
│       ├── content: string
│       └── timestamp: timestamp
│
├── settings/{settingId}/
│   └── [user preferences]
│
└── [customCollection]/{documentId}/
    └── [your custom data]
```

### **Security Rules Deployment**

#### **Manual Method** (Recommended)
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project
3. Go to Firestore Database → Rules
4. Copy content from `firestore.rules` file
5. Paste and publish

#### **Automated Method**
```bash
# If you have Firebase CLI installed
firebase deploy --only firestore:rules
```

### **Adding Custom Data Types**

#### **Step 1: Create Data Model**
```dart
// lib/models/your_model.dart
class YourModel {
  final String id;
  final String name;
  final DateTime createdAt;

  // Firestore serialization
  Map<String, dynamic> toFirestore() => {
    'name': name,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  factory YourModel.fromFirestore(String id, Map<String, dynamic> data) {
    return YourModel(
      id: id,
      name: data['name'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
```

#### **Step 2: Create Repository**
```dart
// lib/repositories/your_repository.dart
class YourRepository extends BaseRepository<YourModel> {
  @override
  CollectionReference<Map<String, dynamic>> get collection {
    return FirestoreService().getUserCollection('yourCollection');
  }

  @override
  YourModel fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    return YourModel.fromFirestore(doc.id, doc.data()!);
  }

  @override
  Map<String, dynamic> toFirestore(YourModel item) => item.toFirestore();
}
```

#### **Step 3: Create Provider**
```dart
// lib/providers/your_provider.dart
final yourRepositoryProvider = Provider<YourRepository>((ref) {
  return YourRepository();
});
```

### **Offline Support**

The template includes automatic offline support:
- **Automatic caching** of read data
- **Offline writes** queued until connection returns
- **Conflict resolution** handled automatically
- **Real-time sync** when connection restored

---

## 7. 🎨 **Customization Guide**

### **Branding & Colors**

#### **App Colors**
Edit `lib/utils/app_theme.dart`:
```dart
// Light theme colors
static const Color primaryColor = Color(0xFF6366F1);     // Your primary
static const Color secondaryColor = Color(0xFF8B5CF6);   // Your secondary
static const Color backgroundColor = Color(0xFFF8FAFC);  // Background
static const Color surfaceColor = Color(0xFFFFFFFF);     // Cards/surfaces
static const Color errorColor = Color(0xFFEF4444);       // Error states

// Dark theme colors
static const Color darkPrimaryColor = Color(0xFF818CF8);
static const Color darkBackgroundColor = Color(0xFF0F172A);
static const Color darkSurfaceColor = Color(0xFF1E293B);
```

#### **App Name & Package**
1. **Update pubspec.yaml**:
```yaml
name: your_app_name
description: Your app description
```

2. **Update Android package** in `android/app/build.gradle`:
```gradle
android {
    namespace "com.yourcompany.yourapp"
    // ...
}
```

3. **Update app name** in `android/app/src/main/AndroidManifest.xml`:
```xml
<application
    android:label="Your App Name"
    // ...
```

### **App Icon**

#### **Icon Requirements**
| Platform | Size | File |
|----------|------|------|
| Android | 192x192px | `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png` |
| Android | 144x144px | `android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png` |
| Android | 96x96px | `android/app/src/main/res/mipmap-xhdpi/ic_launcher.png` |
| Android | 72x72px | `android/app/src/main/res/mipmap-hdpi/ic_launcher.png` |
| Android | 48x48px | `android/app/src/main/res/mipmap-mdpi/ic_launcher.png` |

#### **Automated Icon Generation**
1. **Add flutter_launcher_icons** to pubspec.yaml:
```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1

flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icons/app_icon.png"  # 1024x1024px
```

2. **Generate icons**:
```bash
flutter pub run flutter_launcher_icons
```

### **Typography**

Edit font styles in `lib/utils/app_theme.dart`:
```dart
static TextTheme get textTheme => const TextTheme(
  headlineLarge: TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  ),
  headlineMedium: TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
  ),
  bodyLarge: TextStyle(
    fontSize: 16,
    height: 1.5,
  ),
  bodyMedium: TextStyle(
    fontSize: 14,
    height: 1.4,
  ),
);
```

---

## 8. 🧪 **Testing & Deployment**

### **Testing Checklist**

#### **Authentication Testing**
- [ ] Email/password registration
- [ ] Email verification
- [ ] Login/logout functionality
- [ ] Google Sign-In
- [ ] Password reset
- [ ] Profile management

#### **AI Integration Testing**
- [ ] Send messages to AI
- [ ] Receive AI responses
- [ ] Error handling (network issues)
- [ ] Different AI models
- [ ] Message persistence

#### **Database Testing**
- [ ] Data saves to Firestore
- [ ] Real-time updates
- [ ] Offline functionality
- [ ] Data security (user isolation)
- [ ] Cross-device synchronization

#### **UI/UX Testing**
- [ ] Splash screen displays correctly
- [ ] Onboarding flow works
- [ ] Responsive design on different screen sizes
- [ ] Dark/light theme support
- [ ] Loading states and error handling

### **Building for Release**

#### **Android Release Build**
```bash
# Build release APK
flutter build apk --release

# Build App Bundle (recommended for Play Store)
flutter build appbundle --release
```

#### **Release Checklist**
- [ ] Update version in pubspec.yaml
- [ ] Test on physical devices
- [ ] Verify all API keys are production-ready
- [ ] Test offline functionality
- [ ] Verify Firebase security rules
- [ ] Test payment flows (if applicable)
- [ ] Performance testing
- [ ] Security audit

### **Deployment**

#### **Google Play Store**
1. **Create Play Console account**
2. **Upload App Bundle** (`.aab` file)
3. **Configure store listing**
4. **Set up app signing**
5. **Submit for review**

#### **Firebase Hosting** (for web version)
```bash
flutter build web
firebase deploy --only hosting
```

---

## 🎯 **Next Steps**

After completing this setup:

1. **Customize branding** (colors, logo, app name)
2. **Add your specific features** using the repository pattern
3. **Configure production Firebase** settings
4. **Set up analytics** and crash reporting
5. **Implement push notifications** (if needed)
6. **Add payment integration** (if needed)
7. **Set up CI/CD pipeline** for automated builds

## 📞 **Support**

For questions or issues:
- Check the documentation in the `docs/` folder
- Review code comments for implementation details
- Test with the provided example data
- Verify all configuration steps are completed

This template provides a solid foundation for any AI-powered Flutter application! 🚀
