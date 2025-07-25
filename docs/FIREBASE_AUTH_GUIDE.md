# 🔐 Firebase Authentication Guide

## 📋 **Overview**

This guide covers the complete Firebase Authentication implementation, including email/password authentication, Google Sign-In, user management, and security best practices.

## 🏗️ **Architecture Overview**

### **Core Components**

#### **1. AuthService**
```dart
// lib/services/auth_service.dart
class AuthService {
  // Core authentication methods
  Future<AuthResult> signUpWithEmail(String email, String password);
  Future<AuthResult> signInWithEmail(String email, String password);
  Future<AuthResult> signInWithGoogle();
  Future<void> signOut();
  Future<void> sendPasswordResetEmail(String email);
  Future<void> sendEmailVerification();
}
```

#### **2. AuthProvider**
```dart
// lib/providers/auth_provider.dart
final authStateProvider;           // Current auth state
final currentUserProvider;         // Current user data
final authNotifierProvider;        // Auth operations
```

#### **3. User Model**
```dart
// lib/models/user_model.dart
class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoURL;
  final bool emailVerified;
}
```

## 🚀 **Firebase Setup**

### **Step 1: Firebase Project Configuration**

#### **Create Firebase Project**
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Create a project" or use existing: `flutter-template-3887d`
3. Enable Google Analytics (optional)
4. Wait for project creation

#### **Enable Authentication**
1. In Firebase Console, go to **Authentication**
2. Click **Get started**
3. Go to **Sign-in method** tab
4. Enable these providers:
   - **Email/Password**: Enable both Email/Password and Email link
   - **Google**: Enable and configure

### **Step 2: Android Configuration**

#### **Add Android App**
1. In Firebase Console, click **Add app** → **Android**
2. **Android package name**: `com.tmc.fluttertemplate` (or your package)
3. **App nickname**: `Flutter Template` (optional)
4. **Debug signing certificate SHA-1**: Generate using our script

#### **Download Configuration**
1. **Download `google-services.json`**
2. **Place in**: `android/app/google-services.json`
3. **Never commit this file** to public repositories

#### **Update Android Configuration**
Ensure these are in `android/app/build.gradle`:
```gradle
android {
    compileSdk 34
    
    defaultConfig {
        applicationId "com.tmc.fluttertemplate"
        minSdk 21
        targetSdk 34
        multiDexEnabled true
    }
}

dependencies {
    implementation 'com.google.firebase:firebase-auth'
    implementation 'com.google.android.gms:play-services-auth'
}
```

### **Step 3: SHA-1 Fingerprint Generation**

#### **Debug Fingerprint (Development)**
Use our provided script:
```bash
powershell -ExecutionPolicy Bypass -File generate_sha1.ps1
```

**Manual method:**
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

#### **Release Fingerprint (Production)**
Use our provided script:
```bash
powershell -ExecutionPolicy Bypass -File generate_release_keystore.ps1
```

#### **Add to Firebase**
1. Firebase Console → **Project Settings**
2. Select your Android app
3. **Add fingerprint** in SHA certificate fingerprints
4. **Download updated `google-services.json`**

### **Step 4: Google Sign-In Configuration**

#### **Configure OAuth Consent Screen**
1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Select your Firebase project
3. **APIs & Services** → **OAuth consent screen**
4. Fill required information:
   - **App name**: Your app name
   - **User support email**: Your email
   - **Developer contact**: Your email

#### **Configure OAuth Client**
1. **APIs & Services** → **Credentials**
2. Find the auto-created OAuth 2.0 client
3. **Add authorized redirect URIs** (if needed)
4. **Download client configuration** (optional)

## 🔧 **Implementation Details**

### **Email/Password Authentication**

#### **Sign Up Process**
```dart
// lib/services/auth_service.dart
Future<AuthResult> signUpWithEmail(String email, String password) async {
  try {
    // Validate input
    if (!_isEmailValid(email)) {
      return AuthResult.failure('Please enter a valid email address');
    }
    
    if (!_isPasswordValid(password)) {
      return AuthResult.failure('Password must be at least 8 characters with uppercase and number');
    }
    
    // Create user
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    // Send verification email
    await credential.user?.sendEmailVerification();
    
    // Create user document in Firestore
    if (credential.user != null) {
      await _createUserDocument(credential.user!);
    }
    
    return AuthResult.success('Account created successfully! Please verify your email.');
    
  } on FirebaseAuthException catch (e) {
    return AuthResult.failure(_getErrorMessage(e.code));
  } catch (e) {
    return AuthResult.failure('An unexpected error occurred');
  }
}
```

#### **Password Validation**
```dart
bool _isPasswordValid(String password) {
  // Minimum 8 characters
  if (password.length < 8) return false;
  
  // At least one uppercase letter
  if (!password.contains(RegExp(r'[A-Z]'))) return false;
  
  // At least one number
  if (!password.contains(RegExp(r'[0-9]'))) return false;
  
  // Optional: Special character
  // if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) return false;
  
  return true;
}
```

#### **Email Validation**
```dart
bool _isEmailValid(String email) {
  return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
}
```

### **Google Sign-In Implementation**

#### **Google Sign-In Flow**
```dart
Future<AuthResult> signInWithGoogle() async {
  try {
    // Trigger Google Sign-In flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    
    if (googleUser == null) {
      return AuthResult.failure('Google Sign-In was cancelled');
    }
    
    // Obtain auth details
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    
    // Create Firebase credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    
    // Sign in to Firebase
    final userCredential = await _auth.signInWithCredential(credential);
    
    // Create or update user document
    if (userCredential.user != null) {
      await _createOrUpdateUserDocument(userCredential.user!);
    }
    
    return AuthResult.success('Signed in successfully!');
    
  } catch (e) {
    return AuthResult.failure('Google Sign-In failed: ${e.toString()}');
  }
}
```

### **User Document Management**

#### **Create User Document**
```dart
Future<void> _createUserDocument(User user) async {
  final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
  
  final userData = {
    'uid': user.uid,
    'email': user.email,
    'displayName': user.displayName ?? _extractNameFromEmail(user.email!),
    'photoURL': user.photoURL,
    'emailVerified': user.emailVerified,
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
    'lastSignIn': FieldValue.serverTimestamp(),
    'authProvider': 'email', // or 'google'
  };
  
  await userDoc.set(userData, SetOptions(merge: true));
}
```

#### **Extract Name from Email**
```dart
String _extractNameFromEmail(String email) {
  final username = email.split('@')[0];
  // Convert "john.doe" to "John Doe"
  return username
      .split('.')
      .map((part) => part.isNotEmpty 
          ? part[0].toUpperCase() + part.substring(1).toLowerCase()
          : '')
      .join(' ');
}
```

## 🎨 **UI Implementation**

### **Login Screen Customization**

#### **Email/Password Form**
```dart
// lib/screens/auth/login_screen.dart
Form(
  key: _formKey,
  child: Column(
    children: [
      // Email field
      TextFormField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          labelText: 'Email',
          hintText: 'Enter your email address',
          prefixIcon: Icon(Icons.email_outlined),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your email';
          }
          if (!_isEmailValid(value)) {
            return 'Please enter a valid email';
          }
          return null;
        },
      ),
      
      SizedBox(height: 16),
      
      // Password field
      TextFormField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        decoration: InputDecoration(
          labelText: 'Password',
          hintText: 'Enter your password',
          prefixIcon: Icon(Icons.lock_outlined),
          suffixIcon: IconButton(
            icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your password';
          }
          return null;
        },
      ),
    ],
  ),
)
```

#### **Google Sign-In Button**
```dart
Container(
  width: double.infinity,
  height: 56,
  child: OutlinedButton.icon(
    onPressed: _isLoading ? null : _signInWithGoogle,
    icon: Image.asset(
      'assets/images/google_logo.png',
      height: 24,
      width: 24,
    ),
    label: Text(
      'Continue with Google',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
    style: OutlinedButton.styleFrom(
      side: BorderSide(color: Colors.grey.shade300),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
),
```

### **Registration Screen**

#### **Password Strength Indicator**
```dart
class PasswordStrengthIndicator extends StatelessWidget {
  final String password;
  
  @override
  Widget build(BuildContext context) {
    final strength = _calculatePasswordStrength(password);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: strength / 4,
          backgroundColor: Colors.grey.shade300,
          valueColor: AlwaysStoppedAnimation<Color>(
            _getStrengthColor(strength),
          ),
        ),
        SizedBox(height: 8),
        Text(
          _getStrengthText(strength),
          style: TextStyle(
            fontSize: 12,
            color: _getStrengthColor(strength),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
  
  int _calculatePasswordStrength(String password) {
    int strength = 0;
    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;
    return strength;
  }
  
  Color _getStrengthColor(int strength) {
    switch (strength) {
      case 0:
      case 1: return Colors.red;
      case 2: return Colors.orange;
      case 3: return Colors.yellow.shade700;
      case 4: return Colors.green;
      default: return Colors.grey;
    }
  }
  
  String _getStrengthText(int strength) {
    switch (strength) {
      case 0:
      case 1: return 'Weak password';
      case 2: return 'Fair password';
      case 3: return 'Good password';
      case 4: return 'Strong password';
      default: return '';
    }
  }
}
```

## 🔒 **Security Best Practices**

### **Password Security**
```dart
class PasswordSecurity {
  // Minimum requirements
  static const int minLength = 8;
  static const int maxLength = 128;
  
  // Validation rules
  static bool hasUppercase(String password) => password.contains(RegExp(r'[A-Z]'));
  static bool hasLowercase(String password) => password.contains(RegExp(r'[a-z]'));
  static bool hasDigits(String password) => password.contains(RegExp(r'[0-9]'));
  static bool hasSpecialCharacters(String password) => password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
  
  // Common password check
  static bool isCommonPassword(String password) {
    final commonPasswords = [
      'password', '123456', '123456789', 'qwerty', 'abc123',
      'password123', 'admin', 'letmein', 'welcome', 'monkey'
    ];
    return commonPasswords.contains(password.toLowerCase());
  }
  
  // Comprehensive validation
  static String? validatePassword(String password) {
    if (password.length < minLength) {
      return 'Password must be at least $minLength characters';
    }
    if (password.length > maxLength) {
      return 'Password must be less than $maxLength characters';
    }
    if (!hasUppercase(password)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!hasLowercase(password)) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!hasDigits(password)) {
      return 'Password must contain at least one number';
    }
    if (isCommonPassword(password)) {
      return 'Please choose a less common password';
    }
    return null; // Password is valid
  }
}
```

### **Email Verification**

#### **Send Verification Email**
```dart
Future<void> sendEmailVerification() async {
  final user = _auth.currentUser;
  if (user != null && !user.emailVerified) {
    await user.sendEmailVerification();
  }
}
```

#### **Check Verification Status**
```dart
Future<bool> checkEmailVerification() async {
  final user = _auth.currentUser;
  if (user != null) {
    await user.reload();
    return user.emailVerified;
  }
  return false;
}
```

### **Account Security**

#### **Re-authentication for Sensitive Operations**
```dart
Future<bool> reauthenticateUser(String password) async {
  try {
    final user = _auth.currentUser;
    if (user?.email == null) return false;
    
    final credential = EmailAuthProvider.credential(
      email: user!.email!,
      password: password,
    );
    
    await user.reauthenticateWithCredential(credential);
    return true;
  } catch (e) {
    return false;
  }
}
```

#### **Delete Account**
```dart
Future<AuthResult> deleteAccount(String password) async {
  try {
    // Re-authenticate first
    final reauthenticated = await reauthenticateUser(password);
    if (!reauthenticated) {
      return AuthResult.failure('Please enter your current password');
    }
    
    final user = _auth.currentUser;
    if (user == null) {
      return AuthResult.failure('No user found');
    }
    
    // Delete user data from Firestore
    await FirestoreService().deleteUserDocument(user.uid);
    
    // Delete Firebase Auth account
    await user.delete();
    
    return AuthResult.success('Account deleted successfully');
  } catch (e) {
    return AuthResult.failure('Failed to delete account: ${e.toString()}');
  }
}
```

## 🧪 **Testing Authentication**

### **Test Scenarios**

#### **Email/Password Testing**
- [ ] Valid email and password registration
- [ ] Invalid email format rejection
- [ ] Weak password rejection
- [ ] Duplicate email registration
- [ ] Email verification flow
- [ ] Password reset flow
- [ ] Login with verified account
- [ ] Login with unverified account

#### **Google Sign-In Testing**
- [ ] First-time Google Sign-In
- [ ] Returning Google user
- [ ] Google Sign-In cancellation
- [ ] Network error handling
- [ ] Account linking (if applicable)

#### **Security Testing**
- [ ] Password strength validation
- [ ] Email verification requirement
- [ ] Session persistence
- [ ] Automatic logout on token expiry
- [ ] Re-authentication for sensitive operations

### **Debug Tools**

#### **Auth State Debugging**
```dart
// Add to main.dart for debugging
if (kDebugMode) {
  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    print('Auth State Changed: ${user?.uid ?? 'No user'}');
    print('Email Verified: ${user?.emailVerified ?? false}');
  });
}
```

#### **Test User Creation**
```dart
// For testing purposes only
Future<void> createTestUser() async {
  if (kDebugMode) {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: 'test@example.com',
        password: 'TestPassword123',
      );
    } catch (e) {
      print('Test user creation failed: $e');
    }
  }
}
```

## 📊 **Error Handling**

### **Firebase Auth Error Codes**
```dart
String _getErrorMessage(String errorCode) {
  switch (errorCode) {
    case 'weak-password':
      return 'The password provided is too weak.';
    case 'email-already-in-use':
      return 'An account already exists for this email.';
    case 'invalid-email':
      return 'The email address is not valid.';
    case 'user-disabled':
      return 'This account has been disabled.';
    case 'user-not-found':
      return 'No account found for this email.';
    case 'wrong-password':
      return 'Incorrect password.';
    case 'too-many-requests':
      return 'Too many failed attempts. Please try again later.';
    case 'operation-not-allowed':
      return 'This sign-in method is not enabled.';
    case 'network-request-failed':
      return 'Network error. Please check your connection.';
    default:
      return 'An error occurred. Please try again.';
  }
}
```

## 🚀 **Production Deployment**

### **Environment Configuration**
```dart
// lib/config/environment.dart
class Environment {
  static const bool isDevelopment = bool.fromEnvironment('DEVELOPMENT', defaultValue: true);
  static const bool isProduction = bool.fromEnvironment('PRODUCTION', defaultValue: false);

  // Firebase configuration
  static String get firebaseProjectId {
    if (isProduction) {
      return 'your-production-project-id';
    }
    return 'flutter-template-3887d'; // Development
  }
}
```

### **Security Checklist**
- [ ] Enable App Check for production
- [ ] Configure proper Firebase Security Rules
- [ ] Enable multi-factor authentication (optional)
- [ ] Set up monitoring and alerts
- [ ] Configure proper CORS settings
- [ ] Enable audit logging
- [ ] Set up backup authentication methods

Your Firebase Authentication system is now fully configured and ready for production! 🚀
