import 'package:json_annotation/json_annotation.dart';
part 'chat_message.g.dart';

/// Enum for message roles
enum MessageRole {
  @JsonValue('user')
  user,
  @JsonValue('assistant')
  assistant,
  @JsonValue('system')
  system,
}

/// Chat message model for local storage
@JsonSerializable()
class ChatMessage {
  final MessageRole role;
  final String content;
  final DateTime timestamp;
  final String? id;

  const ChatMessage({
    required this.role,
    required this.content,
    required this.timestamp,
    this.id,
  });

  /// Factory constructor from JSON
  factory ChatMessage.fromJson(Map<String, dynamic> json) => _$ChatMessageFromJson(json);

  /// Convert to JSON
  Map<String, dynamic> toJson() => _$ChatMessageToJson(this);

  /// Create a user message
  factory ChatMessage.user(String content) {
    return ChatMessage(
      role: MessageRole.user,
      content: content,
      timestamp: DateTime.now(),
      id: DateTime.now().millisecondsSinceEpoch.toString(),
    );
  }

  /// Create an assistant message
  factory ChatMessage.assistant(String content) {
    return ChatMessage(
      role: MessageRole.assistant,
      content: content,
      timestamp: DateTime.now(),
      id: DateTime.now().millisecondsSinceEpoch.toString(),
    );
  }

  /// Create a system message
  factory ChatMessage.system(String content) {
    return ChatMessage(
      role: MessageRole.system,
      content: content,
      timestamp: DateTime.now(),
      id: DateTime.now().millisecondsSinceEpoch.toString(),
    );
  }

  /// Copy with method
  ChatMessage copyWith({
    MessageRole? role,
    String? content,
    DateTime? timestamp,
    String? id,
  }) {
    return ChatMessage(
      role: role ?? this.role,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      id: id ?? this.id,
    );
  }

  /// Check if message is from user
  bool get isUser => role == MessageRole.user;

  /// Check if message is from assistant
  bool get isAssistant => role == MessageRole.assistant;

  /// Check if message is system message
  bool get isSystem => role == MessageRole.system;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatMessage &&
        other.role == role &&
        other.content == content &&
        other.timestamp == timestamp &&
        other.id == id;
  }

  @override
  int get hashCode {
    return role.hashCode ^ content.hashCode ^ timestamp.hashCode ^ id.hashCode;
  }

  @override
  String toString() {
    return 'ChatMessage(role: $role, content: $content, timestamp: $timestamp, id: $id)';
  }

  /// Convert to local storage format
  Map<String, dynamic> toStorage() {
    return {
      'role': role.name,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'id': id,
    };
  }

  /// Create from local storage
  factory ChatMessage.fromStorage(Map<String, dynamic> data) {
    return ChatMessage(
      role: MessageRole.values.firstWhere(
        (e) => e.name == data['role'],
        orElse: () => MessageRole.user,
      ),
      content: data['content'] ?? '',
      timestamp: DateTime.parse(data['timestamp']),
      id: data['id'],
    );
  }
}

/// Helper functions for JSON serialization
DateTime _timestampFromJson(dynamic timestamp) {
  if (timestamp is String) {
    return DateTime.parse(timestamp);
  } else if (timestamp is int) {
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }
  return DateTime.now();
}

dynamic _timestampToJson(DateTime dateTime) {
  return dateTime.toIso8601String();
}
