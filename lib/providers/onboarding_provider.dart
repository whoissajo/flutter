import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/onboarding_service.dart';

/// Provider for OnboardingService instance
final onboardingServiceProvider = Provider<OnboardingService>((ref) {
  return OnboardingService.instance;
});

/// Provider to check if onboarding is completed
final onboardingStatusProvider = FutureProvider<bool>((ref) async {
  final service = ref.read(onboardingServiceProvider);
  return await service.isOnboardingCompleted();
});

/// Provider for onboarding completion action
final onboardingCompletionProvider = Provider<Future<bool> Function()>((ref) {
  final service = ref.read(onboardingServiceProvider);
  return () async {
    final result = await service.setOnboardingCompleted();
    // Invalidate the status provider to refresh the state
    ref.invalidate(onboardingStatusProvider);
    return result;
  };
});

/// Provider for resetting onboarding status (useful for testing)
final onboardingResetProvider = Provider<Future<bool> Function()>((ref) {
  final service = ref.read(onboardingServiceProvider);
  return () async {
    final result = await service.resetOnboardingStatus();
    // Invalidate the status provider to refresh the state
    ref.invalidate(onboardingStatusProvider);
    return result;
  };
});

/// State notifier for managing current onboarding page index
class OnboardingPageNotifier extends StateNotifier<int> {
  OnboardingPageNotifier() : super(0);

  void nextPage() {
    state = state + 1;
  }

  void previousPage() {
    if (state > 0) {
      state = state - 1;
    }
  }

  void setPage(int index) {
    state = index;
  }

  void reset() {
    state = 0;
  }
}

/// Provider for onboarding page index state
final onboardingPageProvider = StateNotifierProvider<OnboardingPageNotifier, int>((ref) {
  return OnboardingPageNotifier();
});
