# 👤 **Profile & Settings Guide**

## **Overview**
The Flutter AI Template includes a comprehensive profile management and settings system that allows users to customize their experience and manage their account information.

## 🎯 **Features**

### **Profile Management**
- ✅ **Profile Viewing** - Display user information and avatar
- ✅ **Profile Editing** - Update display name, first/last name, bio
- ✅ **Quick Actions** - Easy access to settings, help, and sharing
- ✅ **Account Information** - View account details and creation date
- ✅ **Profile Picture** - Display user avatar with initials fallback

### **Settings System**
- ✅ **Account Settings** - Email verification, password management
- ✅ **Appearance Settings** - Dark mode, theme colors, font size
- ✅ **AI Settings** - Model configuration, voice input, chat history
- ✅ **Privacy & Security** - Privacy policy, terms, data export
- ✅ **About Section** - App info, help & support, rating

## 📱 **Navigation Structure**

```
Home Screen
├── Profile Icon (Top Right) → Profile Screen
│   ├── Settings Icon → Settings Screen
│   ├── Edit Icon → Edit Profile Screen
│   ├── Quick Actions
│   │   ├── Settings
│   │   ├── Help
│   │   └── Share
│   └── Account Actions
│       ├── Account Info
│       ├── Sign Out
│       └── Delete Account
└── Menu → Profile/Settings Options
```

## 🔧 **Implementation Details**

### **1. Profile Screen** (`lib/screens/profile/profile_screen.dart`)

#### **Key Components:**
- **Profile Header** - Avatar, name, email display
- **Quick Actions** - Settings, Help, Share buttons
- **Profile Form** - Editable user information
- **Account Actions** - Account management options

#### **Features:**
```dart
// Profile header with avatar
CircleAvatar(
  radius: 50,
  backgroundImage: user.photoURL != null ? NetworkImage(user.photoURL!) : null,
  child: user.photoURL == null ? Text(user.initials) : null,
)

// Quick action buttons
_buildQuickActionButton(
  context,
  icon: Icons.settings,
  label: 'Settings',
  onTap: () => context.push('/settings'),
)
```

### **2. Settings Screen** (`lib/screens/settings/settings_screen.dart`)

#### **Settings Categories:**

**Account Settings:**
- Profile management
- Email verification status
- Password change (for email users)

**Appearance Settings:**
- Dark/Light mode toggle
- Theme color selection
- Font size adjustment

**AI Settings:**
- AI model configuration
- Voice input settings
- Chat history management

**Privacy & Security:**
- Privacy policy access
- Terms of service
- Data export functionality

**About Section:**
- App version information
- Help & support
- App rating

### **3. Edit Profile Screen** (`lib/screens/profile/edit_profile_screen.dart`)

#### **Editable Fields:**
- Display Name (required)
- First Name
- Last Name
- Phone Number (optional)
- Bio (200 character limit)
- Profile Picture (coming soon)

#### **Validation:**
```dart
TextFormField(
  controller: _displayNameController,
  validator: (value) {
    if (value == null || value.trim().isEmpty) {
      return 'Display name is required';
    }
    return null;
  },
)
```

### **4. Theme System** (`lib/providers/theme_provider.dart`)

#### **Theme Features:**
- **Theme Modes**: Light, Dark, System
- **Custom Colors**: Multiple color schemes
- **Font Scaling**: Adjustable text sizes
- **Persistent Settings**: Saved to SharedPreferences

#### **Usage:**
```dart
// Toggle theme
ref.read(themeNotifierProvider.notifier).toggleTheme();

// Set specific color
ref.read(themeNotifierProvider.notifier).setPrimaryColor(Colors.purple);

// Adjust font size
ref.read(themeNotifierProvider.notifier).setFontSize(16.0);
```

## 🎨 **UI/UX Design**

### **Design Principles:**
- **Material 3** design system
- **Consistent spacing** using AppConstants
- **Accessible colors** with proper contrast
- **Responsive layouts** for different screen sizes
- **Smooth animations** and transitions

### **Visual Elements:**
- **Cards** for grouped content
- **List tiles** for settings options
- **Floating action buttons** for primary actions
- **Chips** for tags and categories
- **Snackbars** for feedback messages

## 🔐 **Security Features**

### **Account Protection:**
- **Email verification** status display
- **Password change** for email users
- **Sign out** functionality
- **Account deletion** (with confirmation)

### **Privacy Controls:**
- **Data export** capability
- **Privacy policy** access
- **Terms of service** review
- **Account information** transparency

## 📊 **User Data Management**

### **Profile Data Structure:**
```dart
class UserModel {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoURL;
  final bool emailVerified;
  final DateTime? createdAt;
  final List<String> providerIds;
  
  // Extended fields (to be implemented)
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? bio;
}
```

### **Settings Data Structure:**
```dart
class ThemeState {
  final AppThemeMode themeMode;
  final Color primaryColor;
  final double fontSize;
}
```

## 🚀 **Getting Started**

### **1. Access Profile**
- Tap the profile icon in the top-right corner of the home screen
- Or use the popup menu to select "Profile"

### **2. Edit Profile**
- From the profile screen, tap the edit icon
- Update your information and tap "Save"

### **3. Customize Settings**
- From the profile screen, tap the settings icon
- Or tap "Settings" in the quick actions
- Adjust preferences as needed

### **4. Theme Customization**
- Go to Settings > Appearance
- Toggle dark mode
- Select theme colors
- Adjust font size

## 🔧 **Customization Options**

### **Adding New Settings:**
1. Add setting to `SettingsScreen`
2. Create corresponding provider if needed
3. Implement setting logic
4. Add persistence if required

### **Extending Profile Fields:**
1. Update `UserModel` class
2. Add fields to `EditProfileScreen`
3. Update Firestore schema
4. Implement save/load logic

### **Custom Themes:**
1. Add colors to `availableThemeColors`
2. Update theme providers
3. Test with different color schemes

## 📱 **Testing Checklist**

### **Profile Features:**
- [ ] Profile display with correct user info
- [ ] Avatar display (image or initials)
- [ ] Quick actions navigation
- [ ] Edit profile functionality
- [ ] Profile picture change (when implemented)

### **Settings Features:**
- [ ] Dark mode toggle
- [ ] Theme color selection
- [ ] Font size adjustment
- [ ] Account settings access
- [ ] Privacy policy/terms access

### **Navigation:**
- [ ] Profile icon navigation
- [ ] Settings navigation
- [ ] Edit profile navigation
- [ ] Back navigation
- [ ] Deep linking support

## 🐛 **Troubleshooting**

### **Common Issues:**

**Profile not loading:**
- Check user authentication state
- Verify Firebase connection
- Check console for errors

**Settings not persisting:**
- Verify SharedPreferences permissions
- Check theme provider implementation
- Ensure proper state management

**Navigation issues:**
- Verify route configuration
- Check GoRouter setup
- Ensure proper context usage

## 🎯 **Future Enhancements**

### **Planned Features:**
- [ ] Profile picture upload/change
- [ ] Social media links
- [ ] Privacy settings granular control
- [ ] Export/import settings
- [ ] Multiple theme presets
- [ ] Advanced accessibility options
- [ ] Notification preferences
- [ ] Language selection

### **Advanced Features:**
- [ ] Two-factor authentication
- [ ] Account linking/unlinking
- [ ] Data synchronization
- [ ] Backup/restore functionality
- [ ] Advanced user analytics
- [ ] Custom theme creation

## 📚 **Related Documentation**
- [Authentication Guide](AUTH_GUIDE.md)
- [AI Integration Guide](AI_INTEGRATION_GUIDE.md)
- [Main Documentation](../README.md)

---

Your profile and settings system is now ready for comprehensive user management! 🚀
