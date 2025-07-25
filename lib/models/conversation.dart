import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'conversation.g.dart';

/// Conversation model for grouping chat messages
@JsonSerializable()
class Conversation {
  final String id;
  final String title;
  final String? description;
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime createdAt;
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime updatedAt;
  final String userId;
  final String model;
  final int messageCount;
  final bool isArchived;
  final Map<String, dynamic>? metadata;

  const Conversation({
    required this.id,
    required this.title,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
    required this.model,
    this.messageCount = 0,
    this.isArchived = false,
    this.metadata,
  });

  /// Factory constructor from JSON
  factory Conversation.fromJson(Map<String, dynamic> json) => _$ConversationFromJson(json);

  /// Convert to JSON
  Map<String, dynamic> toJson() => _$ConversationToJson(this);

  /// Create a new conversation
  factory Conversation.create({
    required String userId,
    required String title,
    String? description,
    String model = 'deepseek/deepseek-r1-0528',
    Map<String, dynamic>? metadata,
  }) {
    final now = DateTime.now();
    return Conversation(
      id: '', // Will be set by Firestore
      title: title,
      description: description,
      createdAt: now,
      updatedAt: now,
      userId: userId,
      model: model,
      messageCount: 0,
      isArchived: false,
      metadata: metadata,
    );
  }

  /// Copy with method
  Conversation copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
    String? model,
    int? messageCount,
    bool? isArchived,
    Map<String, dynamic>? metadata,
  }) {
    return Conversation(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
      model: model ?? this.model,
      messageCount: messageCount ?? this.messageCount,
      isArchived: isArchived ?? this.isArchived,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Update with new message count
  Conversation withUpdatedMessageCount(int newCount) {
    return copyWith(
      messageCount: newCount,
      updatedAt: DateTime.now(),
    );
  }

  /// Archive conversation
  Conversation archive() {
    return copyWith(
      isArchived: true,
      updatedAt: DateTime.now(),
    );
  }

  /// Unarchive conversation
  Conversation unarchive() {
    return copyWith(
      isArchived: false,
      updatedAt: DateTime.now(),
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'userId': userId,
      'model': model,
      'messageCount': messageCount,
      'isArchived': isArchived,
      'metadata': metadata,
    };
  }

  /// Create from Firestore document
  factory Conversation.fromFirestore(String documentId, Map<String, dynamic> data) {
    return Conversation(
      id: documentId,
      title: data['title'] ?? 'Untitled Conversation',
      description: data['description'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      userId: data['userId'] ?? '',
      model: data['model'] ?? 'deepseek/deepseek-r1-0528',
      messageCount: data['messageCount'] ?? 0,
      isArchived: data['isArchived'] ?? false,
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Generate title from first message
  static String generateTitle(String firstMessage) {
    if (firstMessage.isEmpty) return 'New Conversation';
    
    // Take first 50 characters and add ellipsis if needed
    final title = firstMessage.length > 50 
        ? '${firstMessage.substring(0, 50)}...'
        : firstMessage;
    
    // Remove newlines and extra spaces
    return title.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// Get conversation summary
  String get summary {
    if (description != null && description!.isNotEmpty) {
      return description!;
    }
    return '$messageCount messages • ${model.split('/').last}';
  }

  /// Check if conversation is recent (within last 24 hours)
  bool get isRecent {
    final now = DateTime.now();
    final difference = now.difference(updatedAt);
    return difference.inHours < 24;
  }

  /// Get formatted date
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(updatedAt);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${updatedAt.day}/${updatedAt.month}/${updatedAt.year}';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Conversation &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.userId == userId &&
        other.model == model &&
        other.messageCount == messageCount &&
        other.isArchived == isArchived;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        description.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        userId.hashCode ^
        model.hashCode ^
        messageCount.hashCode ^
        isArchived.hashCode;
  }

  @override
  String toString() {
    return 'Conversation(id: $id, title: $title, messageCount: $messageCount, model: $model)';
  }
}

/// Helper functions for JSON serialization with Firestore Timestamp
DateTime _timestampFromJson(dynamic timestamp) {
  if (timestamp is Timestamp) {
    return timestamp.toDate();
  } else if (timestamp is String) {
    return DateTime.parse(timestamp);
  } else if (timestamp is int) {
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }
  return DateTime.now();
}

dynamic _timestampToJson(DateTime dateTime) {
  return dateTime.toIso8601String();
}
