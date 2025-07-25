import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:go_router/go_router.dart';

import '../../constants/onboarding_data.dart';
import '../../constants/app_constants.dart';
import '../../providers/onboarding_provider.dart';
import '../../widgets/onboarding_page_widget.dart';

/// Main onboarding screen with swipe-through interface
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentPageIndex = ref.watch(onboardingPageProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            _buildTopBar(context),
            
            // Page view
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  ref.read(onboardingPageProvider.notifier).setPage(index);
                },
                itemCount: OnboardingData.pageCount,
                itemBuilder: (context, index) {
                  return OnboardingPageWidget(
                    page: OnboardingData.getPage(index),
                  );
                },
              ),
            ),
            
            // Bottom section with indicators and buttons
            _buildBottomSection(context, currentPageIndex),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: _completeOnboarding,
            child: Text(
              'Skip',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection(BuildContext context, int currentPageIndex) {
    final theme = Theme.of(context);
    final isLastPage = OnboardingData.isLastPage(currentPageIndex);

    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        children: [
          // Page indicators
          SmoothPageIndicator(
            controller: _pageController,
            count: OnboardingData.pageCount,
            effect: WormEffect(
              dotHeight: 8,
              dotWidth: 8,
              activeDotColor: theme.colorScheme.primary,
              dotColor: theme.colorScheme.primary.withOpacity(0.3),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Navigation buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Previous button
              if (currentPageIndex > 0)
                TextButton(
                  onPressed: _previousPage,
                  child: Text(
                    'Previous',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                )
              else
                const SizedBox(width: 80), // Placeholder for alignment
              
              // Next/Get Started button
              ElevatedButton(
                onPressed: isLastPage ? _completeOnboarding : _nextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  minimumSize: const Size(120, AppConstants.buttonHeight),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                  ),
                ),
                child: Text(
                  isLastPage ? 'Get Started' : 'Next',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: AppConstants.onboardingTransitionDuration,
      curve: Curves.easeInOut,
    );
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: AppConstants.onboardingTransitionDuration,
      curve: Curves.easeInOut,
    );
  }

  void _completeOnboarding() async {
    // Mark onboarding as completed
    final completeOnboarding = ref.read(onboardingCompletionProvider);
    await completeOnboarding();
    
    // Navigate to login screen
    if (mounted) {
      context.go(AppConstants.loginRoute);
    }
  }
}
