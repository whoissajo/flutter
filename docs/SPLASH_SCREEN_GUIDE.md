# 🎨 Splash Screen Configuration Guide

## 📋 **Overview**

The splash screen is the first thing users see when launching your app. This guide provides detailed instructions for customizing the splash screen with your own branding, including image specifications, color schemes, and configuration options.

## 🖼️ **Image Requirements & Specifications**

### **Primary Logo Image**

#### **File Specifications**
- **File Name**: `splash_logo.png`
- **Location**: `assets/splash/splash_logo.png`
- **Format**: PNG with transparent background
- **Recommended Size**: 512x512 pixels
- **Aspect Ratio**: 1:1 (square)
- **Color Mode**: RGBA (with alpha channel for transparency)
- **File Size**: Keep under 500KB for optimal loading

#### **Design Guidelines**
- **Simplicity**: Use a clean, simple version of your logo
- **Contrast**: Ensure logo is visible on both light and dark backgrounds
- **Scalability**: Logo should look good at different sizes
- **Brand Consistency**: Use your official brand colors and typography

### **Background Image (Optional)**

#### **File Specifications**
- **File Name**: `splash_background.png`
- **Location**: `assets/splash/splash_background.png`
- **Format**: PNG or JPG
- **Size**: 1080x1920 pixels (9:16 aspect ratio)
- **Alternative Sizes**: 
  - 1440x2560px (for high-density screens)
  - 720x1280px (for lower-density screens)

#### **Design Guidelines**
- **Subtle**: Should not compete with your logo
- **Brand Colors**: Use your brand's color palette
- **Gradient**: Consider subtle gradients for modern look
- **Texture**: Light textures can add depth without distraction

### **Icon Variants**

#### **Small Icon Version**
- **File Name**: `splash_icon.png`
- **Size**: 192x192 pixels
- **Purpose**: Used in some Android versions and as fallback
- **Design**: Simplified version of your main logo

#### **Adaptive Icon (Android)**
- **Foreground**: `splash_icon_foreground.png` (108x108dp safe area within 192x192px)
- **Background**: `splash_icon_background.png` (192x192px solid color or simple pattern)

## 📱 **Platform-Specific Requirements**

### **Android Specifications**

#### **Standard Densities**
| Density | Folder | Logo Size | Background Size |
|---------|--------|-----------|-----------------|
| mdpi | `android/app/src/main/res/drawable-mdpi/` | 128x128px | 320x480px |
| hdpi | `android/app/src/main/res/drawable-hdpi/` | 192x192px | 480x800px |
| xhdpi | `android/app/src/main/res/drawable-xhdpi/` | 256x256px | 640x960px |
| xxhdpi | `android/app/src/main/res/drawable-xxhdpi/` | 384x384px | 960x1600px |
| xxxhdpi | `android/app/src/main/res/drawable-xxxhdpi/` | 512x512px | 1080x1920px |

#### **Android 12+ Specifications**
- **Logo**: 288x288dp (approximately 432x432px at xxhdpi)
- **Background**: Full screen with safe areas
- **Animation**: Optional animated vector drawable

### **iOS Specifications** (if supporting iOS)

#### **Launch Images**
| Device | Size | File Name |
|--------|------|-----------|
| iPhone SE | 640x1136px | `LaunchImage-568h@2x.png` |
| iPhone 8 | 750x1334px | `LaunchImage-667h@2x.png` |
| iPhone 8 Plus | 1242x2208px | `LaunchImage-736h@3x.png` |
| iPhone X/11/12 | 1125x2436px | `LaunchImage-1125h@3x.png` |
| iPhone 12 Pro Max | 1284x2778px | `LaunchImage-1284h@3x.png` |

## ⚙️ **Configuration Steps**

### **Step 1: Prepare Your Images**

#### **Using Design Tools**
1. **Adobe Illustrator/Photoshop**:
   - Create artboard at 512x512px
   - Design your logo with transparent background
   - Export as PNG with transparency

2. **Figma** (Free alternative):
   - Create 512x512px frame
   - Design your logo
   - Export as PNG with transparent background

3. **Canva** (Online tool):
   - Use custom dimensions: 512x512px
   - Design with transparent background
   - Download as PNG

#### **Image Optimization**
```bash
# Using ImageOptim (Mac) or TinyPNG (Web)
# Reduce file size while maintaining quality
# Target: Under 500KB for splash images
```

### **Step 2: Add Images to Project**

#### **Create Directory Structure**
```
assets/
└── splash/
    ├── splash_logo.png          # Main logo (512x512px)
    ├── splash_background.png    # Background (1080x1920px) - Optional
    ├── splash_icon.png          # Small icon (192x192px)
    └── variants/                # Platform-specific variants
        ├── android/
        └── ios/
```

#### **Update pubspec.yaml**
```yaml
flutter:
  assets:
    - assets/splash/
    - assets/splash/variants/android/
    - assets/splash/variants/ios/
```

### **Step 3: Configure Splash Screen**

#### **Basic Configuration**
Edit the `flutter_native_splash` section in `pubspec.yaml`:

```yaml
flutter_native_splash:
  # Background color (use your brand color)
  color: "#FFFFFF"                           # Light mode background
  color_dark: "#000000"                      # Dark mode background (optional)
  
  # Logo image
  image: assets/splash/splash_logo.png       # Main logo
  image_dark: assets/splash/splash_logo_dark.png  # Dark mode logo (optional)
  
  # Background image (optional)
  background_image: assets/splash/splash_background.png
  background_image_dark: assets/splash/splash_background_dark.png
  
  # Platform-specific settings
  android_12:
    image: assets/splash/splash_logo.png
    color: "#FFFFFF"
    image_dark: assets/splash/splash_logo_dark.png
    color_dark: "#000000"
  
  # Disable web splash (optional)
  web: false
```

#### **Advanced Configuration**
```yaml
flutter_native_splash:
  # Logo positioning
  android_gravity: center                    # center, top, bottom, left, right
  ios_content_mode: center                   # center, scaleToFill, scaleAspectFit, scaleAspectFill
  
  # Logo sizing
  fill: false                                # true = fill screen, false = maintain aspect ratio
  
  # Branding image (additional image, like company name)
  branding: assets/splash/branding.png
  branding_dark: assets/splash/branding_dark.png
  branding_bottom_padding: 24                # Padding from bottom
  
  # Full screen mode
  fullscreen: true                           # Hide status bar during splash
  
  # Platform-specific overrides
  android:
    gravity: center
    image: assets/splash/android_logo.png
  ios:
    content_mode: center
    image: assets/splash/ios_logo.png
```

### **Step 4: Generate Splash Screen**

#### **Run Generation Command**
```bash
# Generate splash screen files
flutter pub run flutter_native_splash:create

# Clean previous builds
flutter clean

# Get dependencies
flutter pub get
```

#### **Verify Generation**
Check that these files were created:
```
android/app/src/main/res/
├── drawable/launch_background.xml
├── drawable-v21/launch_background.xml
├── drawable-night/launch_background.xml
├── drawable-night-v21/launch_background.xml
├── values/colors.xml
├── values-night/colors.xml
└── mipmap-*/splash.png

ios/Runner/
├── Assets.xcassets/LaunchImage.imageset/
└── Base.lproj/LaunchScreen.storyboard
```

## 🎨 **Design Best Practices**

### **Color Guidelines**

#### **Brand Consistency**
```yaml
# Use your exact brand colors
color: "#6366F1"        # Your primary brand color
color_dark: "#4F46E5"   # Darker variant for dark mode
```

#### **Accessibility**
- **Contrast Ratio**: Ensure 4.5:1 minimum contrast between logo and background
- **Color Blindness**: Test with color blindness simulators
- **Dark Mode**: Provide appropriate dark mode variants

### **Logo Design Tips**

#### **Simplification**
- Remove fine details that won't be visible at small sizes
- Use bold, clear typography
- Avoid complex gradients or shadows
- Ensure logo works in monochrome

#### **Sizing Guidelines**
- **Mobile**: Logo should occupy 20-30% of screen width
- **Tablet**: Logo can be slightly larger relative to screen
- **Padding**: Maintain at least 48dp padding around logo

### **Animation Considerations**

#### **Android 12+ Animated Splash**
```xml
<!-- res/drawable/splash_animated.xml -->
<animated-vector xmlns:android="http://schemas.android.com/apk/res/android">
    <target android:name="logo">
        <aapt:attr name="android:animation">
            <objectAnimator
                android:propertyName="alpha"
                android:duration="1000"
                android:valueFrom="0"
                android:valueTo="1" />
        </aapt:attr>
    </target>
</animated-vector>
```

## 🧪 **Testing Your Splash Screen**

### **Testing Checklist**
- [ ] Logo appears correctly on different screen sizes
- [ ] Colors match your brand guidelines
- [ ] Dark mode variant works properly
- [ ] Animation is smooth (if implemented)
- [ ] Loading time is reasonable (under 3 seconds)
- [ ] Works on different Android versions
- [ ] No pixelation or distortion

### **Testing Commands**
```bash
# Test on different devices
flutter run --release                    # Test release build
flutter run --debug                      # Test debug build

# Test specific platforms
flutter run -d android                   # Android only
flutter run -d ios                       # iOS only (if configured)
```

### **Device Testing**
Test on various screen densities:
- **Low density**: 120dpi (ldpi)
- **Medium density**: 160dpi (mdpi)
- **High density**: 240dpi (hdpi)
- **Extra high density**: 320dpi (xhdpi)
- **Extra extra high density**: 480dpi (xxhdpi)
- **Extra extra extra high density**: 640dpi (xxxhdpi)

## 🔧 **Troubleshooting**

### **Common Issues**

#### **Logo Not Appearing**
1. Check file path in pubspec.yaml
2. Verify image exists in assets/splash/
3. Run `flutter pub get` after changes
4. Regenerate splash: `flutter pub run flutter_native_splash:create`

#### **Wrong Colors**
1. Verify hex color format: "#RRGGBB"
2. Check for typos in color values
3. Ensure colors.xml was generated correctly

#### **Pixelated Logo**
1. Use higher resolution source image
2. Ensure PNG format with transparency
3. Check if image is being scaled incorrectly

#### **Splash Not Updating**
1. Run `flutter clean`
2. Delete build folders
3. Regenerate splash screen
4. Rebuild app completely

### **Debug Commands**
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter pub run flutter_native_splash:create
flutter build apk --debug

# Check generated files
ls android/app/src/main/res/drawable*/
ls android/app/src/main/res/values*/colors.xml
```

## 📊 **Performance Optimization**

### **Image Optimization**
- **Compression**: Use tools like TinyPNG or ImageOptim
- **Format**: PNG for logos with transparency, JPG for backgrounds
- **Size**: Keep total splash assets under 2MB

### **Loading Time**
- **Minimize**: Keep splash simple to reduce loading time
- **Preload**: Critical app resources during splash display
- **Transition**: Smooth transition from splash to main app

## 🎯 **Examples**

### **Minimal Setup**
```yaml
flutter_native_splash:
  color: "#FFFFFF"
  image: assets/splash/logo.png
```

### **Complete Setup**
```yaml
flutter_native_splash:
  color: "#6366F1"
  color_dark: "#1E293B"
  image: assets/splash/logo.png
  image_dark: assets/splash/logo_dark.png
  background_image: assets/splash/background.png
  branding: assets/splash/company_name.png
  android_12:
    image: assets/splash/logo.png
    color: "#6366F1"
  fullscreen: true
  android_gravity: center
  ios_content_mode: center
```

Your splash screen is now ready to make a great first impression! 🚀
