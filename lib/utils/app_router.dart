import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/home/home_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/edit_profile_screen.dart';

/// App router configuration for local storage app
final GoRouter appRouter = GoRouter(
  routes: [
    // Splash screen (initial route)
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    
    // Home screen (main chat screen)
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    
    // Profile screen
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    
    // Edit profile screen
    GoRoute(
      path: '/edit-profile',
      builder: (context, state) => const EditProfileScreen(),
    ),
    
    // Settings screen
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
  
  // Custom error page
  errorPageBuilder: (context, state) => MaterialPage(
    key: state.pageKey,
    child: Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('404 - Page not found'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  ),
  
  // Redirect logic - no auth needed for local storage app
  redirect: (context, state) {
    return null; // No redirects needed for local storage app
  },
);
