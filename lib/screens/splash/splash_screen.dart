import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_constants.dart';
import '../../providers/onboarding_provider.dart';

/// Splash screen that shows app logo and navigates directly to home
/// No auth required for local storage app
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _navigateAfterDelay();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: AppConstants.defaultAnimationDuration,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    _animationController.forward();
  }

  void _navigateAfterDelay() async {
    // Wait for splash duration
    await Future.delayed(AppConstants.splashDuration);
    if (!mounted) return;
    
    // Check onboarding status for local user
    final onboardingStatus = await ref.read(onboardingStatusProvider.future);
    if (!mounted) return;
    
    // Navigate based on onboarding status - always to home since no auth needed
    if (onboardingStatus) {
      // User has completed onboarding, go to home
      context.go(AppConstants.homeRoute);
    } else {
      // User hasn't completed onboarding, show onboarding
      context.go(AppConstants.onboardingRoute);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App logo
                    _buildLogo(context, size),
                    const SizedBox(height: 24),
                    // App name
                    Text(
                      AppConstants.appName,
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // App version
                    Text(
                      'v${AppConstants.appVersion}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 48),
                    // Loading indicator
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLogo(BuildContext context, Size size) {
    final theme = Theme.of(context);
    return Container(
      width: size.width * 0.3,
      height: size.width * 0.3,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius * 2),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius * 2),
        child: Image.asset(
          AppConstants.splashLogoPath,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            // Fallback logo when image is not found
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius * 2),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                  ],
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.flutter_dash,
                  size: size.width * 0.15,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
