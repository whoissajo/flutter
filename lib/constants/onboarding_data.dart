import '../models/onboarding_page.dart';

/// Static data for onboarding pages
class OnboardingData {
  static const List<OnboardingPage> pages = [
    OnboardingPage(
      title: 'Welcome to Flutter Template',
      description: 'A comprehensive Flutter app template with modern features and best practices built-in.',
      imagePath: 'assets/images/onboarding_1.png',
    ),
    OnboardingPage(
      title: 'AI-Powered Features',
      description: 'Integrated with OpenRouter API for seamless AI functionality and dynamic model selection.',
      imagePath: 'assets/images/onboarding_2.png',
    ),
    OnboardingPage(
      title: 'Secure & Scalable',
      description: 'Built with Firebase authentication, Neon.tech database, and modern state management.',
      imagePath: 'assets/images/onboarding_3.png',
    ),
  ];

  /// Get the total number of onboarding pages
  static int get pageCount => pages.length;

  /// Check if the given index is the last page
  static bool isLastPage(int index) => index == pages.length - 1;

  /// Get a specific page by index
  static OnboardingPage getPage(int index) {
    if (index < 0 || index >= pages.length) {
      throw ArgumentError('Index $index is out of bounds for onboarding pages');
    }
    return pages[index];
  }
}
