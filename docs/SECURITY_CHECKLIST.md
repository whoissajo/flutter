# 🔒 **Security Checklist**

Before publishing or sharing your Flutter AI Template, ensure all sensitive data is properly secured.

## ✅ **Pre-Publication Checklist**

### **🔑 API Keys & Secrets**
- [ ] Remove all hardcoded API keys from source code
- [ ] Replace actual keys with template placeholders
- [ ] Verify `lib/config/api_config.dart` is in `.gitignore`
- [ ] Check no API keys in commit history
- [ ] Ensure environment variables are documented but not committed

### **🔥 Firebase Configuration**
- [ ] Remove actual `google-services.json` from repository
- [ ] Remove actual `GoogleService-Info.plist` from repository
- [ ] Replace Firebase project IDs with placeholders
- [ ] Document Firebase setup process
- [ ] Ensure Firebase rules are secure

### **📱 App Configuration**
- [ ] Replace package names with generic examples
- [ ] Remove actual bundle IDs
- [ ] Replace app names with template names
- [ ] Remove any personal/company branding
- [ ] Clear any production URLs

### **🗂️ File System**
- [ ] Check `.gitignore` includes all sensitive files
- [ ] Remove any local configuration files
- [ ] Clear build artifacts and generated files
- [ ] Remove any backup files with sensitive data
- [ ] Check for hidden files with credentials

## 🚨 **Files to Never Commit**

### **Configuration Files**
```
lib/config/api_config.dart          # Actual API keys
android/app/google-services.json    # Firebase Android config
ios/Runner/GoogleService-Info.plist # Firebase iOS config
.env                                 # Environment variables
*.env                               # Any environment files
```

### **Build & Generated Files**
```
build/                              # Build artifacts
*.apk                              # APK files
*.aab                              # App bundles
*.ipa                              # iOS app files
android/key.properties             # Signing keys
*.keystore                         # Keystore files
*.jks                              # Java keystore files
```

### **IDE & System Files**
```
.vscode/settings.json              # Local IDE settings
.idea/workspace.xml                # IntelliJ workspace
*.log                              # Log files
.DS_Store                          # macOS system files
Thumbs.db                          # Windows system files
```

## 🔧 **Secure Configuration Setup**

### **1. Template Files**
Create template versions of sensitive files:

```bash
# API configuration template
lib/config/api_config.dart.template

# Environment template
.env.template

# Firebase config templates
android/app/google-services.json.template
ios/Runner/GoogleService-Info.plist.template
```

### **2. Documentation**
Provide clear setup instructions:
- Step-by-step configuration guide
- Required accounts and services
- Security best practices
- Environment-specific setup

### **3. Validation**
Add configuration validation:

```dart
// lib/config/api_config.dart.template
class ApiConfig {
  static bool get isConfigured {
    return openRouterApiKey != 'YOUR_OPENROUTER_API_KEY_HERE' &&
           openRouterApiKey.isNotEmpty;
  }
  
  static String get validatedApiKey {
    if (!isConfigured) {
      throw Exception('API key not configured. Please follow setup guide.');
    }
    return openRouterApiKey;
  }
}
```

## 🔍 **Security Audit Commands**

### **Check for Hardcoded Secrets**
```bash
# Search for potential API keys
grep -r "sk-" . --exclude-dir=.git
grep -r "AIza" . --exclude-dir=.git
grep -r "firebase" . --exclude-dir=.git

# Search for URLs that might contain secrets
grep -r "https://" . --exclude-dir=.git | grep -v "example\|template\|docs"

# Check for email addresses
grep -r "@" . --exclude-dir=.git | grep -v "example\|template\|docs"
```

### **Verify .gitignore**
```bash
# Test if sensitive files would be ignored
git check-ignore lib/config/api_config.dart
git check-ignore android/app/google-services.json
git check-ignore ios/Runner/GoogleService-Info.plist
```

### **Check Commit History**
```bash
# Search commit history for secrets
git log --all --full-history -- lib/config/api_config.dart
git log --all --full-history -- android/app/google-services.json

# Search for sensitive patterns in history
git log --all -S "sk-or-v1" --source --all
git log --all -S "AIza" --source --all
```

## 🛡️ **Production Security**

### **Environment Variables**
Use environment variables for production:

```dart
class ApiConfig {
  static const String openRouterApiKey = String.fromEnvironment(
    'OPENROUTER_API_KEY',
    defaultValue: 'not-configured',
  );
  
  static const String firebaseProjectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: 'your-project-id',
  );
}
```

### **Build with Environment Variables**
```bash
flutter build apk --dart-define=OPENROUTER_API_KEY=your-key \
                  --dart-define=FIREBASE_PROJECT_ID=your-project
```

### **CI/CD Security**
```yaml
# GitHub Actions example
env:
  OPENROUTER_API_KEY: ${{ secrets.OPENROUTER_API_KEY }}
  FIREBASE_PROJECT_ID: ${{ secrets.FIREBASE_PROJECT_ID }}

steps:
  - name: Build APK
    run: |
      flutter build apk --dart-define=OPENROUTER_API_KEY=$OPENROUTER_API_KEY \
                        --dart-define=FIREBASE_PROJECT_ID=$FIREBASE_PROJECT_ID
```

## 📋 **User Setup Validation**

### **Setup Script Checks**
```bash
#!/bin/bash
# setup.sh

# Check if config file exists
if [ ! -f "lib/config/api_config.dart" ]; then
    echo "Creating config file from template..."
    cp lib/config/api_config.dart.template lib/config/api_config.dart
fi

# Validate configuration
if grep -q "YOUR_OPENROUTER_API_KEY_HERE" lib/config/api_config.dart; then
    echo "⚠️  Please update your OpenRouter API key"
fi

# Check Firebase files
if [ ! -f "android/app/google-services.json" ]; then
    echo "⚠️  Missing Firebase Android configuration"
fi
```

### **Runtime Validation**
```dart
// lib/main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Validate configuration before starting app
  if (!ApiConfig.isConfigured) {
    throw Exception(
      'App not configured. Please follow the setup guide in README.md'
    );
  }
  
  runApp(MyApp());
}
```

## 🚀 **Publishing Checklist**

### **Before Publishing**
- [ ] Run security audit commands
- [ ] Verify all sensitive files are gitignored
- [ ] Test setup process on clean environment
- [ ] Update documentation with security notes
- [ ] Add setup validation scripts

### **Repository Settings**
- [ ] Enable branch protection
- [ ] Require pull request reviews
- [ ] Enable secret scanning (GitHub)
- [ ] Set up security advisories
- [ ] Configure dependabot

### **Documentation**
- [ ] Clear setup instructions
- [ ] Security best practices
- [ ] Environment configuration guide
- [ ] Troubleshooting section
- [ ] Contributing guidelines

## 🆘 **If Secrets Were Committed**

### **Immediate Actions**
1. **Revoke compromised credentials**
   - Regenerate API keys
   - Create new Firebase project
   - Update all services

2. **Clean Git history**
   ```bash
   # Remove file from history
   git filter-branch --force --index-filter \
     'git rm --cached --ignore-unmatch lib/config/api_config.dart' \
     --prune-empty --tag-name-filter cat -- --all
   
   # Force push (⚠️ destructive)
   git push origin --force --all
   ```

3. **Update security**
   - Add files to `.gitignore`
   - Implement proper configuration system
   - Add validation checks

### **Prevention**
- Use pre-commit hooks
- Regular security audits
- Team security training
- Automated secret scanning

---

**🔒 Security is everyone's responsibility. Always double-check before publishing!**
