import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../models/auth_state.dart';
import '../../models/user_model.dart';

/// User profile management screen
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _displayNameController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = ref.read(currentUserProvider);
    if (user != null) {
      _displayNameController.text = user.displayName ?? '';
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider);
    final authState = ref.watch(authNotifierProvider);

    if (user == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64),
              const SizedBox(height: 16),
              Text(
                'No user found',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go(AppConstants.loginRoute),
                child: const Text('Go to Login'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        actions: [
          if (_isEditing)
            TextButton(
              onPressed: _saveProfile,
              child: Text(
                'Save',
                style: TextStyle(color: theme.colorScheme.primary),
              ),
            )
          else ...[
            IconButton(
              onPressed: () => context.push('/settings'),
              icon: const Icon(Icons.settings),
              tooltip: 'Settings',
            ),
            IconButton(
              onPressed: () => context.push('/profile/edit'),
              icon: const Icon(Icons.edit),
              tooltip: 'Edit Profile',
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          children: [
            // Profile header
            _buildProfileHeader(context, user),
            
            const SizedBox(height: 32),
            
            // Profile form
            _buildProfileForm(context, user),
            
            const SizedBox(height: 32),
            
            // Quick Actions
            _buildQuickActions(context, user),

            const SizedBox(height: 24),

            // Account actions
            _buildAccountActions(context, user, authState),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, user) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        // Avatar
        CircleAvatar(
          radius: 50,
          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
          backgroundImage: user.photoURL != null ? NetworkImage(user.photoURL!) : null,
          child: user.photoURL == null
              ? Text(
                  user.initials,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        
        const SizedBox(height: 16),
        
        // User name
        Text(
          user.displayName ?? 'User',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 4),
        
        // Email
        Text(
          user.email ?? '',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        
        // Email verification status
        if (!user.emailVerified && user.isEmailUser) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.warning_amber,
                  size: 16,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(width: 4),
                Text(
                  'Email not verified',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildProfileForm(BuildContext context, user) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Profile Information',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Display name field
            TextFormField(
              controller: _displayNameController,
              enabled: _isEditing,
              decoration: InputDecoration(
                labelText: 'Display Name',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Email field (read-only)
            TextFormField(
              initialValue: user.email ?? '',
              enabled: false,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Sign-in methods
            Text(
              'Sign-in Methods',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Wrap(
              spacing: 8,
              children: user.providerIds.map<Widget>((providerId) {
                IconData icon;
                String label;

                switch (providerId) {
                  case 'password':
                    icon = Icons.email;
                    label = 'Email';
                    break;
                  case 'google.com':
                    icon = Icons.g_mobiledata;
                    label = 'Google';
                    break;
                  case 'apple.com':
                    icon = Icons.apple;
                    label = 'Apple';
                    break;
                  default:
                    icon = Icons.account_circle;
                    label = providerId;
                }

                return Chip(
                  avatar: Icon(icon, size: 16),
                  label: Text(label),
                  backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  /// Build quick actions section
  Widget _buildQuickActions(BuildContext context, UserModel user) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildQuickActionButton(
                    context,
                    icon: Icons.settings,
                    label: 'Settings',
                    onTap: () => context.push('/settings'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionButton(
                    context,
                    icon: Icons.help_outline,
                    label: 'Help',
                    onTap: () => _showHelp(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionButton(
                    context,
                    icon: Icons.share,
                    label: 'Share',
                    onTap: () => _shareApp(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: theme.colorScheme.primary,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountActions(BuildContext context, user, AuthState authState) {
    final theme = Theme.of(context);
    final canChangePassword = ref.watch(canChangePasswordProvider);
    
    return Column(
      children: [
        // Send email verification
        if (!user.emailVerified && user.isEmailUser)
          Card(
            child: ListTile(
              leading: Icon(
                Icons.mark_email_unread,
                color: theme.colorScheme.primary,
              ),
              title: const Text('Verify Email'),
              subtitle: const Text('Send verification email'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _sendEmailVerification,
            ),
          ),
        
        // Change password
        if (canChangePassword)
          Card(
            child: ListTile(
              leading: Icon(
                Icons.lock_outline,
                color: theme.colorScheme.primary,
              ),
              title: const Text('Change Password'),
              subtitle: const Text('Update your password'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _showChangePasswordDialog,
            ),
          ),
        
        const SizedBox(height: 16),
        
        // Sign out button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: (authState == AuthState.loading) ? null : _signOut,
            icon: const Icon(Icons.logout),
            label: const Text('Sign Out'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Delete account button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: (authState == AuthState.loading) ? null : _showDeleteAccountDialog,
            icon: const Icon(Icons.delete_forever),
            label: const Text('Delete Account'),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
              side: BorderSide(color: theme.colorScheme.error),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _saveProfile() async {
    final authNotifier = ref.read(authNotifierProvider.notifier);
    
    final result = await authNotifier.updateProfile(
      displayName: _displayNameController.text.trim(),
    );

    if (mounted) {
      if (result.success) {
        setState(() => _isEditing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.errorMessage ?? 'Failed to update profile'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _sendEmailVerification() async {
    final authNotifier = ref.read(authNotifierProvider.notifier);
    
    final result = await authNotifier.sendEmailVerification();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.success 
                ? 'Verification email sent!' 
                : result.errorMessage ?? 'Failed to send verification email',
          ),
          backgroundColor: result.success 
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _showChangePasswordDialog() {
    // TODO: Implement change password dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Change password feature coming soon!')),
    );
  }

  void _showDeleteAccountDialog() {
    // TODO: Implement delete account dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Delete account feature coming soon!')),
    );
  }

  void _signOut() async {
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

  // Helper methods for quick actions
  void _showHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Need help? Here are some resources:'),
            SizedBox(height: 16),
            Text('• Check our FAQ section'),
            Text('• Contact support team'),
            Text('• Visit our documentation'),
            Text('• Join our community forum'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Open support page
            },
            child: const Text('Contact Support'),
          ),
        ],
      ),
    );
  }

  void _shareApp(BuildContext context) {
    // TODO: Implement app sharing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share app feature coming soon!')),
    );
  }

  void _showAccountInfo(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Account Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('User ID', user.uid),
            _buildInfoRow('Email', user.email ?? 'Not set'),
            _buildInfoRow('Email Verified', user.emailVerified ? 'Yes' : 'No'),
            _buildInfoRow('Account Created', _formatDate(user.createdAt)),
            _buildInfoRow('Last Sign In', _formatDate(user.lastSignInTime)),
            _buildInfoRow('Sign In Methods', user.providerIds.join(', ')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    return '${date.day}/${date.month}/${date.year}';
  }
}
