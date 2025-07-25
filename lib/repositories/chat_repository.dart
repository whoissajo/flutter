import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/chat_message.dart';
import '../models/conversation.dart';
import 'base_repository.dart';

/// Repository for chat messages using local storage (shared_preferences)
class ChatMessageRepository extends BaseRepository<ChatMessage> {
  final String conversationId;
  static const String _messagesKey = 'chat_messages';

  ChatMessageRepository({required this.conversationId});

  /// Get the storage key for messages in this conversation
  String get _messagesStorageKey => '${_messagesKey}_$conversationId';

  @override
  Future<List<ChatMessage>> getAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = prefs.getString(_messagesStorageKey);
      if (messagesJson == null) return [];
      final List<dynamic> messagesList = json.decode(messagesJson);
      return messagesList
          .map((json) => ChatMessage.fromStorage(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<ChatMessage?> get(String id) async {
    final messages = await getAll();
    return messages.firstWhere(
      (message) => message.id == id,
      orElse: () => null,
    );
  }

  @override
  Future<String> create(ChatMessage item) async {
    final messages = await getAll();
    final newId = DateTime.now().millisecondsSinceEpoch.toString();
    final newMessage = item.copyWith(id: newId);
    messages.add(newMessage);
    await _saveMessages(messages);
    return newId;
  }

  @override
  Future<void> update(String id, ChatMessage item) async {
    final messages = await getAll();
    final index = messages.indexWhere((message) => message.id == id);
    if (index != -1) {
      messages[index] = item.copyWith(id: id);
      await _saveMessages(messages);
    }
  }

  @override
  Future<void> delete(String id) async {
    final messages = await getAll();
    messages.removeWhere((message) => message.id == id);
    await _saveMessages(messages);
  }

  /// Save messages to local storage
  Future<void> _saveMessages(List<ChatMessage> messages) async {
    final prefs = await SharedPreferences.getInstance();
    final messagesJson = json.encode(
      messages.map((message) => message.toStorage()).toList(),
    );
    await prefs.setString(_messagesStorageKey, messagesJson);
  }

  /// Get messages ordered by timestamp
  Future<List<ChatMessage>> getMessagesOrdered({bool ascending = true}) async {
    final messages = await getAll();
    messages.sort((a, b) => ascending 
        ? a.timestamp.compareTo(b.timestamp)
        : b.timestamp.compareTo(a.timestamp));
    return messages;
  }

  /// Get recent messages with limit
  Future<List<ChatMessage>> getRecentMessages(int limit) async {
    final messages = await getMessagesOrdered(ascending: false);
    return messages.take(limit).toList();
  }

  /// Get messages by role
  Future<List<ChatMessage>> getMessagesByRole(MessageRole role) async {
    final messages = await getAll();
    return messages.where((message) => message.role == role).toList();
  }

  /// Search messages by content
  Future<List<ChatMessage>> searchMessages(String searchTerm) async {
    final messages = await getAll();
    return messages.where((message) =>
        message.content.toLowerCase().contains(searchTerm.toLowerCase())
    ).toList();
  }

  /// Get message count
  Future<int> getMessageCount() async {
    final messages = await getAll();
    return messages.length;
  }

  /// Delete all messages in conversation
  Future<void> deleteAllMessages() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_messagesStorageKey);
  }
}

/// Repository for conversations using local storage (shared_preferences)
class ConversationRepository extends BaseRepository<Conversation> {
  static const String _conversationsKey = 'chat_conversations';

  @override
  Future<List<Conversation>> getAll() async {
    try {      
      final prefs = await SharedPreferences.getInstance();
      final conversationsJson = prefs.getString(_conversationsKey);
      if (conversationsJson == null) return [];
      final List<dynamic> conversationsList = json.decode(conversationsJson);
      return conversationsList
          .map((json) => Conversation.fromStorage(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<Conversation?> get(String id) async {
    final conversations = await getAll();
    return conversations.firstWhere(
      (conversation) => conversation.id == id,
      orElse: () => null,
    );
  }

  @override
  Future<String> create(Conversation item) async {
    final conversations = await getAll();
    conversations.add(item);
    await _saveConversations(conversations);
    return item.id;
  }

  @override
  Future<void> update(String id, Conversation item) async {
    final conversations = await getAll();
    final index = conversations.indexWhere((conversation) => conversation.id == id);
    if (index != -1) {
      conversations[index] = item.copyWith(id: id);
      await _saveConversations(conversations);
    }
  }

  @override
  Future<void> delete(String id) async {
    final conversations = await getAll();
    conversations.removeWhere((conversation) => conversation.id == id);
    await _saveConversations(conversations);
    // Also delete all messages in this conversation
    final messageRepo = ChatMessageRepository(conversationId: id);
    await messageRepo.deleteAllMessages();
  }

  /// Save conversations to local storage
  Future<void> _saveConversations(List<Conversation> conversations) async {
    final prefs = await SharedPreferences.getInstance();
    final conversationsJson = json.encode(
      conversations.map((conversation) => conversation.toStorage()).toList(),
    );
    await prefs.setString(_conversationsKey, conversationsJson);
  }

  /// Get conversations ordered by update time
  Future<List<Conversation>> getConversationsOrdered({bool ascending = false}) async {
    final conversations = await getAll();
    conversations.sort((a, b) => ascending 
        ? a.updatedAt.compareTo(b.updatedAt)
        : b.updatedAt.compareTo(a.updatedAt));
    return conversations;
  }

  /// Get active (non-archived) conversations
  Future<List<Conversation>> getActiveConversations() async {
    final conversations = await getAll();
    return conversations.where((conversation) => !conversation.isArchived).toList();
  }

  /// Get archived conversations
  Future<List<Conversation>> getArchivedConversations() async {
    final conversations = await getAll();
    return conversations.where((conversation) => conversation.isArchived).toList();
  }

  /// Get conversations by model
  Future<List<Conversation>> getConversationsByModel(String model) async {
    final conversations = await getAll();
    return conversations.where((conversation) => conversation.model == model).toList();
  }

  /// Search conversations by title or description
  Future<List<Conversation>> searchConversations(String searchTerm) async {
    final conversations = await getAll();
    return conversations.where((conversation) =>
        conversation.title.toLowerCase().contains(searchTerm.toLowerCase()) ||
        (conversation.description?.toLowerCase().contains(searchTerm.toLowerCase()) ?? false)
    ).toList();
  }

  /// Create conversation with first message
  Future<String> createConversationWithMessage({
    required String title,
    required ChatMessage firstMessage,
    String? description,
    String model = 'deepseek/deepseek-r1-0528',
  }) async {
    final conversation = Conversation.create(
      userId: 'local_user',
      title: title,
      description: description,
      model: model,
    );

    await create(conversation);
    final messageRepo = ChatMessageRepository(conversationId: conversation.id);
    await messageRepo.create(firstMessage);

    await updateMessageCount(conversation.id, 1);
    return conversation.id;
  }

  /// Update conversation message count
  Future<void> updateMessageCount(String conversationId, int newCount) async {
    final conversation = await get(conversationId);
    if (conversation != null) {
      await update(conversationId, conversation.copyWith(
        messageCount: newCount,
        updatedAt: DateTime.now(),
      ));
    }
  }

  /// Archive conversation
  Future<void> archiveConversation(String conversationId) async {
    final conversation = await get(conversationId);
    if (conversation != null) {
      await update(conversationId, conversation.copyWith(
        isArchived: true,
        updatedAt: DateTime.now(),
      ));
    }
  }

  /// Unarchive conversation
  Future<void> unarchiveConversation(String
