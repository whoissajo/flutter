import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/chat_message.dart';
import '../models/conversation.dart';
import '../services/openrouter_service.dart';
import '../services/firestore_service.dart';
import '../repositories/chat_repository.dart';

/// Provider for OpenRouter service instance
final openRouterServiceProvider = Provider<OpenRouterService>((ref) {
  return OpenRouterService();
});

/// Provider for Firestore service instance
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

/// Provider for conversation repository
final conversationRepositoryProvider = Provider<ConversationRepository>((ref) {
  final firestoreService = ref.read(firestoreServiceProvider);
  return ConversationRepository(firestoreService: firestoreService);
});

/// Provider for chat message repository (requires conversation ID)
final chatMessageRepositoryProvider = Provider.family<ChatMessageRepository, String>((ref, conversationId) {
  final firestoreService = ref.read(firestoreServiceProvider);
  return ChatMessageRepository(
    conversationId: conversationId,
    firestoreService: firestoreService,
  );
});

/// Chat state class
class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;
  final String currentModel;
  final Conversation? currentConversation;
  final bool isInitialized;

  const ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
    this.currentModel = 'deepseek/deepseek-r1-0528',
    this.currentConversation,
    this.isInitialized = false,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
    String? currentModel,
    Conversation? currentConversation,
    bool? isInitialized,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentModel: currentModel ?? this.currentModel,
      currentConversation: currentConversation ?? this.currentConversation,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatState &&
        other.messages == messages &&
        other.isLoading == isLoading &&
        other.error == error &&
        other.currentModel == currentModel &&
        other.currentConversation == currentConversation &&
        other.isInitialized == isInitialized;
  }

  @override
  int get hashCode {
    return messages.hashCode ^
           isLoading.hashCode ^
           error.hashCode ^
           currentModel.hashCode ^
           currentConversation.hashCode ^
           isInitialized.hashCode;
  }
}

/// Chat state notifier
class ChatNotifier extends StateNotifier<ChatState> {
  final OpenRouterService _openRouterService;
  final ConversationRepository _conversationRepository;
  ChatMessageRepository? _messageRepository;

  ChatNotifier(
    this._openRouterService,
    this._conversationRepository,
  ) : super(const ChatState()) {
    _initializeChat();
  }

  /// Initialize chat - create new conversation or load existing
  Future<void> _initializeChat() async {
    try {
      // For now, create a new conversation each time
      // In a full implementation, you might want to load the last conversation
      await _createNewConversation();
    } catch (e) {
      state = state.copyWith(error: 'Failed to initialize chat: $e');
    }
  }

  /// Create a new conversation
  Future<void> _createNewConversation() async {
    try {
      final systemMessage = _openRouterService.createSystemMessage();

      // Create conversation with system message
      final conversationId = await _conversationRepository.createConversationWithMessage(
        title: 'New Chat',
        firstMessage: systemMessage,
        description: 'AI Chat Session',
        model: state.currentModel,
      );

      // Load the created conversation
      final conversation = await _conversationRepository.read(conversationId);

      // Initialize message repository for this conversation
      _messageRepository = ChatMessageRepository(
        conversationId: conversationId,
        firestoreService: _conversationRepository.firestoreService,
      );

      // Load messages
      final messages = await _messageRepository!.getMessagesOrdered();

      state = state.copyWith(
        currentConversation: conversation,
        messages: messages,
        isInitialized: true,
      );
    } catch (e) {
      state = state.copyWith(error: 'Failed to create conversation: $e');
    }
  }

  /// Send a message to the AI
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty || _messageRepository == null || state.currentConversation == null) {
      return;
    }

    // Create user message
    final userMessage = ChatMessage.user(content.trim());

    // Optimistically update UI
    final updatedMessages = [...state.messages, userMessage];
    state = state.copyWith(
      messages: updatedMessages,
      isLoading: true,
      error: null,
    );

    try {
      // Save user message to Firestore
      await _messageRepository!.create(userMessage);

      // Send to OpenRouter API
      final response = await _openRouterService.sendMessage(
        messages: updatedMessages,
        model: state.currentModel,
      );

      // Save AI response to Firestore
      await _messageRepository!.create(response);

      // Update conversation message count
      final newMessageCount = updatedMessages.length + 1; // +1 for AI response
      await _conversationRepository.updateMessageCount(
        state.currentConversation!.id,
        newMessageCount,
      );

      // Update conversation title if this is the first user message
      if (state.messages.where((m) => m.isUser).length == 1) {
        final newTitle = Conversation.generateTitle(content);
        await _conversationRepository.update(
          state.currentConversation!.id,
          state.currentConversation!.copyWith(title: newTitle),
        );
      }

      // Update state with final messages
      final finalMessages = [...updatedMessages, response];
      state = state.copyWith(
        messages: finalMessages,
        isLoading: false,
      );
    } catch (e) {
      // Revert optimistic update on error
      state = state.copyWith(
        messages: state.messages.where((m) => m.id != userMessage.id).toList(),
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Clear chat history - create new conversation
  Future<void> clearChat() async {
    await _createNewConversation();
  }

  /// Change AI model
  void changeModel(String model) {
    state = state.copyWith(currentModel: model);
  }

  /// Remove a specific message
  Future<void> removeMessage(String messageId) async {
    if (_messageRepository == null) return;

    try {
      // Remove from Firestore
      await _messageRepository!.delete(messageId);

      // Update local state
      final updatedMessages = state.messages.where((msg) => msg.id != messageId).toList();
      state = state.copyWith(messages: updatedMessages);

      // Update conversation message count
      if (state.currentConversation != null) {
        await _conversationRepository.updateMessageCount(
          state.currentConversation!.id,
          updatedMessages.length,
        );
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to remove message: $e');
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Get user messages only (excluding system messages)
  List<ChatMessage> get userMessages {
    return state.messages.where((msg) => !msg.isSystem).toList();
  }

  /// Check if chat is empty (only system message)
  bool get isChatEmpty {
    return userMessages.isEmpty;
  }

  /// Get last user message
  ChatMessage? get lastUserMessage {
    final userMsgs = userMessages.where((msg) => msg.isUser).toList();
    return userMsgs.isNotEmpty ? userMsgs.last : null;
  }

  /// Get last assistant message
  ChatMessage? get lastAssistantMessage {
    final assistantMsgs = userMessages.where((msg) => msg.isAssistant).toList();
    return assistantMsgs.isNotEmpty ? assistantMsgs.last : null;
  }

  @override
  void dispose() {
    _openRouterService.dispose();
    super.dispose();
  }
}

/// Provider for chat state notifier
final chatNotifierProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  final openRouterService = ref.read(openRouterServiceProvider);
  final conversationRepository = ref.read(conversationRepositoryProvider);
  return ChatNotifier(openRouterService, conversationRepository);
});

/// Provider for chat operations
final chatOperationsProvider = Provider<ChatNotifier>((ref) {
  return ref.read(chatNotifierProvider.notifier);
});

/// Provider for user messages only
final userMessagesProvider = Provider<List<ChatMessage>>((ref) {
  final chatState = ref.watch(chatNotifierProvider);
  return chatState.messages.where((msg) => !msg.isSystem).toList();
});

/// Provider for checking if chat is loading
final isChatLoadingProvider = Provider<bool>((ref) {
  final chatState = ref.watch(chatNotifierProvider);
  return chatState.isLoading;
});

/// Provider for chat error
final chatErrorProvider = Provider<String?>((ref) {
  final chatState = ref.watch(chatNotifierProvider);
  return chatState.error;
});

/// Provider for current AI model
final currentModelProvider = Provider<String>((ref) {
  final chatState = ref.watch(chatNotifierProvider);
  return chatState.currentModel;
});

/// Provider for available models
final availableModelsProvider = FutureProvider<List<String>>((ref) async {
  final openRouterService = ref.read(openRouterServiceProvider);
  return await openRouterService.getAvailableModels();
});

/// Provider for model information
final modelInfoProvider = Provider.family<Map<String, dynamic>, String>((ref, model) {
  final openRouterService = ref.read(openRouterServiceProvider);
  return openRouterService.getModelInfo(model);
});

/// Provider for testing OpenRouter connection
final connectionTestProvider = FutureProvider<bool>((ref) async {
  final openRouterService = ref.read(openRouterServiceProvider);
  return await openRouterService.testConnection();
});

/// Provider for streaming active conversations
final activeConversationsProvider = StreamProvider<List<Conversation>>((ref) {
  final conversationRepository = ref.read(conversationRepositoryProvider);
  return conversationRepository.streamActiveConversations();
});

/// Provider for conversation statistics
final conversationStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final conversationRepository = ref.read(conversationRepositoryProvider);
  return await conversationRepository.getConversationStats();
});

/// Provider for current conversation
final currentConversationProvider = Provider<Conversation?>((ref) {
  final chatState = ref.watch(chatNotifierProvider);
  return chatState.currentConversation;
});

/// Provider for checking if chat is initialized
final isChatInitializedProvider = Provider<bool>((ref) {
  final chatState = ref.watch(chatNotifierProvider);
  return chatState.isInitialized;
});
