// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Conversation _$ConversationFromJson(Map<String, dynamic> json) => Conversation(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String?,
  createdAt: _timestampFromJson(json['createdAt']),
  updatedAt: _timestampFromJson(json['updatedAt']),
  userId: json['userId'] as String,
  model: json['model'] as String,
  messageCount: (json['messageCount'] as num?)?.toInt() ?? 0,
  isArchived: json['isArchived'] as bool? ?? false,
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$ConversationToJson(Conversation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'createdAt': _timestampToJson(instance.createdAt),
      'updatedAt': _timestampToJson(instance.updatedAt),
      'userId': instance.userId,
      'model': instance.model,
      'messageCount': instance.messageCount,
      'isArchived': instance.isArchived,
      'metadata': instance.metadata,
    };
