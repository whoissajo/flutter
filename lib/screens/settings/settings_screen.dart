import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/user_model.dart';

/// Settings screen for app preferences and account management
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider);
    final isDarkMode = ref.watch(isDarkModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        children: [
          // Account Section
          _buildSectionHeader(context, 'Account'),
          _buildAccountSettings(context, user),
          
          const SizedBox(height: 24),
          
          // Appearance Section
          _buildSectionHeader(context, 'Appearance'),
          _buildAppearanceSettings(context, isDarkMode),
          
          const SizedBox(height: 24),
          
          // AI Settings Section
          _buildSectionHeader(context, 'AI Settings'),
          _buildAISettings(context),
          
          const SizedBox(height: 24),
          
          // Privacy & Security Section
          _buildSectionHeader(context, 'Privacy & Security'),
          _buildPrivacySettings(context, user),
          
          const SizedBox(height: 24),
          
          // About Section
          _buildSectionHeader(context, 'About'),
          _buildAboutSettings(context),
          
          const SizedBox(height: 32),
          
          // Danger Zone
          _buildDangerZone(context, user),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildAccountSettings(BuildContext context, UserModel? user) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Profile'),
            subtitle: const Text('Manage your profile information'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => context.push('/profile'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.email_outlined),
            title: const Text('Email'),
            subtitle: Text(user?.email ?? 'Not set'),
            trailing: user?.emailVerified == true
                ? Icon(Icons.verified, color: Colors.green, size: 20)
                : Icon(Icons.warning, color: Colors.orange, size: 20),
            onTap: () => _showEmailSettings(context, user),
          ),
          if (user?.isEmailUser == true) ...[
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.lock_outline),
              title: const Text('Change Password'),
              subtitle: const Text('Update your password'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showChangePasswordDialog(context),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAppearanceSettings(BuildContext context, bool isDarkMode) {
    return Card(
      child: Column(
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode_outlined),
            title: const Text('Dark Mode'),
            subtitle: const Text('Switch between light and dark themes'),
            value: isDarkMode,
            onChanged: (value) {
              ref.read(themeNotifierProvider.notifier).toggleTheme();
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Theme Color'),
            subtitle: const Text('Choose your preferred color scheme'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showThemeColorPicker(context),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.text_fields),
            title: const Text('Font Size'),
            subtitle: const Text('Adjust text size for better readability'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showFontSizeSettings(context),
          ),
        ],
      ),
    );
  }

  Widget _buildAISettings(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.smart_toy_outlined),
            title: const Text('AI Model'),
            subtitle: const Text('DeepSeek R1 - Advanced reasoning model'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showAIModelSettings(context),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.mic_outlined),
            title: const Text('Voice Input'),
            subtitle: const Text('Configure speech-to-text settings'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showVoiceSettings(context),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Chat History'),
            subtitle: const Text('Manage conversation history'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showChatHistorySettings(context),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacySettings(BuildContext context, UserModel? user) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.security_outlined),
            title: const Text('Privacy Policy'),
            subtitle: const Text('Read our privacy policy'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showPrivacyPolicy(context),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Terms of Service'),
            subtitle: const Text('Read our terms of service'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showTermsOfService(context),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.download_outlined),
            title: const Text('Export Data'),
            subtitle: const Text('Download your data'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _exportUserData(context),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSettings(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('App Version'),
            subtitle: const Text('1.0.0 (Build 1)'),
            onTap: () => _showAppInfo(context),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help & Support'),
            subtitle: const Text('Get help and contact support'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showHelpSupport(context),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.star_outline),
            title: const Text('Rate App'),
            subtitle: const Text('Rate us on the app store'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _rateApp(context),
          ),
        ],
      ),
    );
  }

  Widget _buildDangerZone(BuildContext context, UserModel? user) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.errorContainer.withValues(alpha: 0.1),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.warning_outlined, color: theme.colorScheme.error),
                const SizedBox(width: 12),
                Text(
                  'Danger Zone',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.logout, color: theme.colorScheme.error),
            title: Text(
              'Sign Out',
              style: TextStyle(color: theme.colorScheme.error),
            ),
            subtitle: const Text('Sign out of your account'),
            onTap: () => _signOut(context),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.delete_forever, color: theme.colorScheme.error),
            title: Text(
              'Delete Account',
              style: TextStyle(color: theme.colorScheme.error),
            ),
            subtitle: const Text('Permanently delete your account'),
            onTap: () => _showDeleteAccountDialog(context),
          ),
        ],
      ),
    );
  }

  // Action methods
  void _showEmailSettings(BuildContext context, UserModel? user) {
    // TODO: Implement email settings
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Email settings coming soon!')),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    // TODO: Implement change password
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Change password coming soon!')),
    );
  }

  void _showThemeColorPicker(BuildContext context) {
    // TODO: Implement theme color picker
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Theme color picker coming soon!')),
    );
  }

  void _showFontSizeSettings(BuildContext context) {
    // TODO: Implement font size settings
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Font size settings coming soon!')),
    );
  }

  void _showAIModelSettings(BuildContext context) {
    // TODO: Implement AI model settings
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('AI model settings coming soon!')),
    );
  }

  void _showVoiceSettings(BuildContext context) {
    // TODO: Implement voice settings
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Voice settings coming soon!')),
    );
  }

  void _showChatHistorySettings(BuildContext context) {
    // TODO: Implement chat history settings
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chat history settings coming soon!')),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    // TODO: Implement privacy policy
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Privacy policy coming soon!')),
    );
  }

  void _showTermsOfService(BuildContext context) {
    // TODO: Implement terms of service
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Terms of service coming soon!')),
    );
  }

  void _exportUserData(BuildContext context) {
    // TODO: Implement data export
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data export coming soon!')),
    );
  }

  void _showAppInfo(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Flutter AI Template',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2024 Flutter AI Template',
      children: [
        const Text('A comprehensive Flutter template with AI integration, authentication, and modern UI components.'),
      ],
    );
  }

  void _showHelpSupport(BuildContext context) {
    // TODO: Implement help & support
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Help & support coming soon!')),
    );
  }

  void _rateApp(BuildContext context) {
    // TODO: Implement app rating
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('App rating coming soon!')),
    );
  }

  void _signOut(BuildContext context) async {
    final authNotifier = ref.read(authNotifierProvider.notifier);
    final result = await authNotifier.signOut();

    if (mounted) {
      if (result.success) {
        context.go(AppConstants.loginRoute);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.errorMessage ?? 'Failed to sign out'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _showDeleteAccountDialog(BuildContext context) {
    // TODO: Implement delete account
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Delete account coming soon!')),
    );
  }
}
