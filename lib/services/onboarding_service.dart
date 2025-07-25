import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

/// Service to manage onboarding state using SharedPreferences
class OnboardingService {
  static OnboardingService? _instance;
  static SharedPreferences? _prefs;

  OnboardingService._();

  /// Singleton instance getter
  static OnboardingService get instance {
    _instance ??= OnboardingService._();
    return _instance!;
  }

  /// Initialize the service with SharedPreferences
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Check if onboarding has been completed
  Future<bool> isOnboardingCompleted() async {
    await _ensureInitialized();
    return _prefs!.getBool(AppConstants.onboardingCompletedKey) ?? false;
  }

  /// Mark onboarding as completed
  Future<bool> setOnboardingCompleted() async {
    await _ensureInitialized();
    return await _prefs!.setBool(AppConstants.onboardingCompletedKey, true);
  }

  /// Reset onboarding status (useful for testing or user preference)
  Future<bool> resetOnboardingStatus() async {
    await _ensureInitialized();
    return await _prefs!.remove(AppConstants.onboardingCompletedKey);
  }

  /// Get the current onboarding status as a string (for debugging)
  Future<String> getOnboardingStatusString() async {
    final isCompleted = await isOnboardingCompleted();
    return isCompleted ? 'Completed' : 'Not Completed';
  }

  /// Ensure SharedPreferences is initialized
  Future<void> _ensureInitialized() async {
    if (_prefs == null) {
      await init();
    }
  }

  /// Clear all onboarding related data
  Future<void> clearOnboardingData() async {
    await _ensureInitialized();
    await _prefs!.remove(AppConstants.onboardingCompletedKey);
  }
}
