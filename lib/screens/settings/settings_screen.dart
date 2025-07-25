import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_constants.dart';
import '../../providers/theme_provider.dart';

/// Settings screen for local storage app - no auth required
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = ref.watch(themeProvider).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        children: [
          // Theme settings
          _buildThemeSettings(context, theme, isDarkMode),
          const SizedBox(height: 16),
          // Chat settings
          _buildChatSettings(context, theme),
          const SizedBox(height: 16),
          // App info
          _buildAppInfo(context, theme),
        ],
      ),
    );
  }

  Widget _buildThemeSettings(BuildContext context, ThemeData theme, bool isDarkMode) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Theme',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle: const Text('Toggle between light and dark themes'),
              value: isDarkMode,
              onChanged: (value) {
                ref.read(themeProvider.notifier).toggleTheme();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatSettings(BuildContext context, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chat Settings',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Clear All Conversations'),
              subtitle: const Text('Delete all chat history'),
              leading: const Icon(Icons.delete_outline),
              textColor: theme.colorScheme.error,
              iconColor: theme.colorScheme.error,
              onTap: () => _showClearConversationsDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppInfo(BuildContext context, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'App Information',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Version'),
              subtitle: const Text('v1.0.0'),
              leading: const Icon(Icons.info_outline),
            ),
            ListTile(
              title: const Text('Local Storage'),
              subtitle: const Text('All data stored locally on device'),
              leading: const Icon(Icons.storage),
            ),
            ListTile(
              title: const Text('OpenRouter AI'),
              subtitle: const Text('Powered by DeepSeek R1'),
              leading: const Icon(Icons.smart_toy),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearConversationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Conversations'),
        content: const Text(
          'This will delete all your chat history. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement clear all conversations
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All conversations cleared'),
                ),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
