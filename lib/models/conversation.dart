import 'package:json_annotation/json_annotation.dart';
part 'conversation.g.dart';

/// Conversation model for local storage
@JsonSerializable()
class Conversation {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final String model;
  final int messageCount;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Conversation({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.model,
    this.messageCount = 0,
    this.isArchived = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Factory constructor from JSON
  factory Conversation.fromJson(String id, Map<String, dynamic> json) =>
      _$ConversationFromJson(json).copyWith(id: id);

  /// Convert to JSON
  Map<String, dynamic> toJson() => _$ConversationToJson(this);

  /// Create a new conversation
  factory Conversation.create({
    required String userId,
    required String title,
    String? description,
    String model = 'deepseek/deepseek-r1-0528',
  }) {
    final now = DateTime.now();
    return Conversation(
      id: now.millisecondsSinceEpoch.toString(),
      userId: userId,
      title: title,
      description: description,
      model: model,
      messageCount: 0,
      isArchived: false,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Copy with method
  Conversation copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? model,
    int? messageCount,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Conversation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      model: model ?? this.model,
      messageCount: messageCount ?? this.messageCount,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convert to local storage format
  Map<String, dynamic> toStorage() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'model': model,
      'messageCount': messageCount,
      'isArchived': isArchived,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create from local storage
  factory Conversation.fromStorage(String id, Map<String, dynamic> data) {
    return Conversation(
      id: id,
      userId: data['userId'] ?? 'local_user',
      title: data['title'] ?? '',
      description: data['description'],
      model: data['model'] ?? 'deepseek/deepseek-r1-0528',
      messageCount: data['messageCount'] ?? 0,
      isArchived: data['isArchived'] ?? false,
      createdAt: DateTime.parse(data['createdAt']),
      updatedAt: DateTime.parse(data['updatedAt']),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Conversation &&
        other.id == id &&
        other.userId == userId &&
        other.title == title &&
        other.description == description &&
        other.model == model &&
        other.messageCount == messageCount &&
        other.isArchived == isArchived &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        title.hashCode ^
        description.hashCode ^
        model.hashCode ^
        messageCount.hashCode ^
        isArchived.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }

  @override
  String toString() {
    return 'Conversation(id: $id, title: $title, messageCount: $messageCount, isArchived: $isArchived)';
  }
}
