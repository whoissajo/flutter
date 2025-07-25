import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
// import '../../providers/speech_provider.dart';
import '../../models/chat_message.dart';

/// Home screen with AI chatbot interface
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isVoiceMode = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _messageController.removeListener(_onTextChanged);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _messageController.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider);
    final userMessages = ref.watch(userMessagesProvider);
    final isLoading = ref.watch(isChatLoadingProvider);
    final error = ref.watch(chatErrorProvider);

    // Speech recognition state (temporarily disabled)
    // final speechService = ref.read(speechServiceProvider);

    // Speech functionality temporarily disabled for APK build
    /*
    // Update text field with speech words when in voice mode
    ref.listen(speechWordsProvider, (previous, next) {
      if (_isVoiceMode && next.hasValue && next.value != null) {
        _messageController.text = next.value!;
        _messageController.selection = TextSelection.fromPosition(
          TextPosition(offset: _messageController.text.length),
        );
      }
    });

    // Handle speech errors
    ref.listen(speechErrorProvider, (previous, next) {
      if (next.hasValue && next.value != null && next.value!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Speech Error: ${next.value}'),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }
    });

    // Auto-stop voice mode when listening stops
    ref.listen(speechListeningProvider, (previous, next) {
      if (next.hasValue && next.value == false && _isVoiceMode) {
        setState(() {
          _isVoiceMode = false;
        });
      }
    });
    */

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('AI Chat - ${user?.firstName ?? 'User'}'),
            Text(
              'DeepSeek R1',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        actions: [
          // Clear chat button
          IconButton(
            onPressed: () {
              ref.read(chatOperationsProvider).clearChat();
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Clear Chat',
          ),

          // Profile button
          IconButton(
            onPressed: () => context.push('/profile'),
            icon: CircleAvatar(
              radius: 16,
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
              backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
              child: user?.photoURL == null
                  ? Text(
                      user?.initials ?? 'U',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
          ),

          PopupMenuButton<String>(
            onSelected: (value) async {
              switch (value) {
                case 'profile':
                  context.push('/profile');
                  break;
                case 'logout':
                  final authNotifier = ref.read(authNotifierProvider.notifier);
                  final result = await authNotifier.signOut();
                  if (context.mounted && result.success) {
                    context.go(AppConstants.loginRoute);
                  }
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Text('Profile'),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Error banner
          if (error != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: theme.colorScheme.error.withOpacity(0.1),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: theme.colorScheme.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      error,
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ),
                  IconButton(
                    onPressed: () => ref.read(chatOperationsProvider).clearError(),
                    icon: Icon(Icons.close, color: theme.colorScheme.error),
                  ),
                ],
              ),
            ),

          // Chat messages
          Expanded(
            child: userMessages.isEmpty
                ? _buildEmptyState(context, theme)
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    itemCount: userMessages.length,
                    itemBuilder: (context, index) {
                      final message = userMessages[index];
                      return _buildMessageBubble(context, theme, message);
                    },
                  ),
          ),

          // Loading indicator
          if (isLoading)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'AI is thinking...',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),

          // Message input
          _buildMessageInput(context, theme, false),
        ],
      ),
    );
  }

  /// Build empty state when no messages
  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.psychology,
                size: 60,
                color: theme.colorScheme.primary,
              ),
            ),

            const SizedBox(height: 32),

            Text(
              'AI Chat Assistant',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            Text(
              'Start a conversation with DeepSeek R1, an advanced AI model. Ask questions, get help, or just chat!',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Try asking:',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...[
                    '• "What is Flutter?"',
                    '• "Explain machine learning"',
                    '• "Help me with coding"',
                    '• "Tell me a joke"',
                  ].map((suggestion) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        suggestion,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build message bubble
  Widget _buildMessageBubble(BuildContext context, ThemeData theme, ChatMessage message) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              child: Icon(
                Icons.psychology,
                size: 16,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 8),
          ],

          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomRight: isUser ? const Radius.circular(4) : null,
                  bottomLeft: !isUser ? const Radius.circular(4) : null,
                ),
                border: !isUser ? Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                ) : null,
              ),
              child: Text(
                message.content,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isUser
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),

          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              child: Icon(
                Icons.person,
                size: 16,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Build message input field
  Widget _buildMessageInput(BuildContext context, ThemeData theme, bool isListening) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: _isVoiceMode
                      ? (isListening ? 'Listening...' : 'Tap mic to speak')
                      : 'Type your message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: _isVoiceMode
                          ? theme.colorScheme.primary.withOpacity(0.5)
                          : theme.colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: _isVoiceMode
                          ? theme.colorScheme.primary.withOpacity(0.5)
                          : theme.colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: _sendMessage,
                readOnly: _isVoiceMode && isListening,
              ),
            ),

            const SizedBox(width: 8),

            // Voice input button
            FloatingActionButton.small(
              onPressed: _toggleVoiceInput,
              backgroundColor: _isVoiceMode
                  ? (isListening ? theme.colorScheme.error : theme.colorScheme.secondary)
                  : theme.colorScheme.surface,
              child: Icon(
                _isVoiceMode
                    ? (isListening ? Icons.stop : Icons.mic)
                    : Icons.mic_none,
                color: _isVoiceMode
                    ? (isListening ? theme.colorScheme.onError : theme.colorScheme.onSecondary)
                    : theme.colorScheme.onSurface,
              ),
            ),

            const SizedBox(width: 8),

            // Send button
            FloatingActionButton.small(
              onPressed: _hasText
                  ? () => _sendMessage(_messageController.text)
                  : null,
              backgroundColor: _hasText
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withOpacity(0.3),
              child: Icon(
                Icons.send,
                color: _hasText
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Send message to AI
  void _sendMessage(String message) {
    if (message.trim().isEmpty) return;

    ref.read(chatOperationsProvider).sendMessage(message);
    _messageController.clear();

    // Exit voice mode after sending
    if (_isVoiceMode) {
      setState(() {
        _isVoiceMode = false;
      });
    }

    // Scroll to bottom after sending message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Toggle voice input mode (temporarily disabled)
  Future<void> _toggleVoiceInput() async {
    // Speech functionality temporarily disabled for APK build
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Voice input feature coming soon!'),
      ),
    );
    /*
    final speechService = ref.read(speechServiceProvider);

    if (_isVoiceMode) {
      // If currently in voice mode, stop listening and exit voice mode
      if (speechService.isListening) {
        await speechService.stopListening();
      }
      setState(() {
        _isVoiceMode = false;
      });
    } else {
      // Enter voice mode and start listening
      setState(() {
        _isVoiceMode = true;
      });

      // Clear current text and start listening
      _messageController.clear();
      await speechService.startListening();
    }
    */
  }
}
