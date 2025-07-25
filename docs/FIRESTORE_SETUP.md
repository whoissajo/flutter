# Firestore Setup Guide

## Quick Setup Steps

### 1. 🔥 **Firebase Console Setup**

1. **Go to Firebase Console**: https://console.firebase.google.com
2. **Select your project**: `flutter-template-3887d`
3. **Navigate to Firestore Database**
4. **Click "Create database"** (if not already created)
5. **Choose "Start in test mode"** (we'll update rules later)
6. **Select a location** (choose closest to your users)

### 2. 📋 **Deploy Firestore Rules**

#### Option A: Using Firebase CLI (Recommended)
```bash
# Install Firebase CLI if not already installed
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase in your project (if not done)
firebase init firestore

# Deploy the rules
firebase deploy --only firestore:rules
```

#### Option B: Manual Copy-Paste
1. **Open Firebase Console** → **Firestore Database** → **Rules**
2. **Copy the content** from `firestore.rules` file
3. **Paste into the rules editor**
4. **Click "Publish"**

### 3. 🔧 **Verify Setup**

1. **Test Authentication**: Sign in to your app
2. **Send a Chat Message**: This will create your first Firestore document
3. **Check Firebase Console**: Verify data appears in Firestore
4. **Test Offline**: Turn off internet, app should still work

### 4. 📊 **Monitor Usage**

- **Firebase Console** → **Firestore Database** → **Usage**
- **Monitor read/write operations**
- **Set up billing alerts** if needed

## Firestore Rules Explanation

```javascript
// Users can only access their own data
match /users/{userId} {
  allow read, write: if request.auth != null && request.auth.uid == userId;
  
  // Nested collections inherit parent permissions
  match /{collection}/{document} {
    allow read, write: if request.auth != null && request.auth.uid == userId;
  }
}
```

### 🔒 **Security Features**
- **User Isolation**: Each user can only access their own data
- **Authentication Required**: All operations require valid login
- **Data Validation**: Ensures proper data structure
- **Nested Security**: Subcollections inherit parent permissions

## Testing Your Setup

### ✅ **Verification Checklist**

1. **Authentication Works**
   - [ ] User can sign up
   - [ ] User can sign in
   - [ ] User can sign out

2. **Firestore Integration**
   - [ ] Chat messages are saved
   - [ ] Messages persist after app restart
   - [ ] Real-time updates work
   - [ ] Offline mode works

3. **Security Rules**
   - [ ] Users can't access other users' data
   - [ ] Unauthenticated users can't read/write
   - [ ] Data validation works

### 🧪 **Test Commands**

```bash
# Test Firestore rules locally
firebase emulators:start --only firestore

# Run your app against local emulator
# (Update Firestore settings to use emulator)
```

## Production Considerations

### 🚀 **Before Going Live**

1. **Review Security Rules**
   - Test with different user scenarios
   - Ensure no data leakage
   - Validate all data inputs

2. **Set Up Monitoring**
   - Enable Firebase Performance Monitoring
   - Set up error reporting
   - Configure usage alerts

3. **Backup Strategy**
   - Enable automatic backups
   - Test restore procedures
   - Document recovery processes

4. **Optimize Performance**
   - Create necessary indexes
   - Implement pagination
   - Monitor query performance

### 💰 **Cost Management**

- **Free Tier Limits**: 50K reads, 20K writes per day
- **Monitor Usage**: Set up billing alerts
- **Optimize Queries**: Reduce unnecessary reads
- **Use Offline Persistence**: Reduce network calls

## Troubleshooting

### ❌ **Common Issues**

1. **"Permission denied" errors**
   - Check if user is authenticated
   - Verify Firestore rules are deployed
   - Ensure user ID matches in rules

2. **Data not appearing**
   - Check internet connection
   - Verify Firebase project configuration
   - Check browser console for errors

3. **Offline mode not working**
   - Ensure persistence is enabled
   - Check if data was cached before going offline
   - Verify offline settings in FirestoreService

### 🔧 **Debug Steps**

1. **Check Firebase Console**
   - View actual data in Firestore
   - Check authentication users
   - Review security rule logs

2. **Enable Debug Logging**
   ```dart
   // Add to main.dart for debugging
   FirebaseFirestore.instance.settings = const Settings(
     persistenceEnabled: true,
     cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
   );
   ```

3. **Test with Emulator**
   ```bash
   firebase emulators:start --only firestore,auth
   ```

## Next Steps

Once Firestore is set up:

1. **Customize Data Models**: Add your own data types
2. **Implement Search**: Add full-text search capabilities
3. **Add Analytics**: Track user behavior
4. **Scale Security**: Implement role-based access
5. **Optimize Performance**: Add indexes and caching

Your Firestore database is now ready to store any type of app data with proper security and offline support! 🎉
