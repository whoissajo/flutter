/// Application-wide constants
class AppConstants {
  // App Information
  static const String appName = 'Flutter Template';
  static const String appVersion = '1.0.0';
  
  // Shared Preferences Keys
  static const String onboardingCompletedKey = 'onboarding_completed';
  static const String userTokenKey = 'user_token';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language_code';
  
  // Animation Durations
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration splashDuration = Duration(seconds: 2);
  static const Duration onboardingTransitionDuration = Duration(milliseconds: 400);
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 12.0;
  static const double buttonHeight = 48.0;
  
  // Asset Paths
  static const String splashLogoPath = 'assets/images/splash_logo.png';
  static const String onboardingImagesPath = 'assets/images/';
  static const String iconsPath = 'assets/icons/';
  
  // Route Names
  static const String splashRoute = '/splash';
  static const String onboardingRoute = '/onboarding';
  static const String loginRoute = '/login';
  static const String signupRoute = '/signup';
  static const String homeRoute = '/home';
  
  // Error Messages
  static const String genericErrorMessage = 'Something went wrong. Please try again.';
  static const String networkErrorMessage = 'Please check your internet connection.';
  static const String authErrorMessage = 'Authentication failed. Please try again.';
}
