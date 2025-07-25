import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_constants.dart';
import '../../models/user_model.dart';

/// Edit profile screen for local user - no auth required
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _nameController;
  late UserModel user;

  @override
  void initState() {
    super.initState();
    user = UserModel.localUser();
    _nameController = TextEditingController(text: user.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          children: [
            // Profile picture
            _buildProfilePicture(context, theme),
            const SizedBox(height: 32),
            // Name field
            _buildNameField(context, theme),
            const SizedBox(height: 32),
            // Info
            _buildInfoSection(context, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePicture(BuildContext context, ThemeData theme) {
    return Center(
      child: CircleAvatar(
        radius: 60,
        backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
        child: Icon(
          Icons.person,
          size: 60,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildNameField(BuildContext context, ThemeData theme) {
    return TextField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: 'Name',
        hintText: 'Enter your name',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        prefixIcon: const Icon(Icons.person),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        Text(
          'Local Storage App',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'This is a local profile. Changes are stored locally on your device.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _saveProfile() {
    final newName = _nameController.text.trim();
    if (newName.isNotEmpty) {
      // TODO: Save to local storage
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved locally')),
      );
      context.pop();
    }
  }
}
