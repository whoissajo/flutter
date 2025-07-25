// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'openrouter_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OpenRouterRequest _$OpenRouterRequestFromJson(Map<String, dynamic> json) =>
    OpenRouterRequest(
      model: json['model'] as String,
      messages: (json['messages'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
      maxTokens: (json['max_tokens'] as num?)?.toInt(),
      temperature: (json['temperature'] as num?)?.toDouble(),
      topP: (json['top_p'] as num?)?.toDouble(),
      stream: json['stream'] as bool?,
    );

Map<String, dynamic> _$OpenRouterRequestToJson(OpenRouterRequest instance) =>
    <String, dynamic>{
      'model': instance.model,
      'messages': instance.messages,
      'max_tokens': instance.maxTokens,
      'temperature': instance.temperature,
      'top_p': instance.topP,
      'stream': instance.stream,
    };

OpenRouterChoice _$OpenRouterChoiceFromJson(Map<String, dynamic> json) =>
    OpenRouterChoice(
      index: (json['index'] as num).toInt(),
      message: ChatMessageResponse.fromJson(
        json['message'] as Map<String, dynamic>,
      ),
      finishReason: json['finish_reason'] as String?,
    );

Map<String, dynamic> _$OpenRouterChoiceToJson(OpenRouterChoice instance) =>
    <String, dynamic>{
      'index': instance.index,
      'message': instance.message,
      'finish_reason': instance.finishReason,
    };

ChatMessageResponse _$ChatMessageResponseFromJson(Map<String, dynamic> json) =>
    ChatMessageResponse(
      role: json['role'] as String,
      content: json['content'] as String,
    );

Map<String, dynamic> _$ChatMessageResponseToJson(
  ChatMessageResponse instance,
) => <String, dynamic>{'role': instance.role, 'content': instance.content};

OpenRouterUsage _$OpenRouterUsageFromJson(Map<String, dynamic> json) =>
    OpenRouterUsage(
      promptTokens: (json['prompt_tokens'] as num).toInt(),
      completionTokens: (json['completion_tokens'] as num).toInt(),
      totalTokens: (json['total_tokens'] as num).toInt(),
    );

Map<String, dynamic> _$OpenRouterUsageToJson(OpenRouterUsage instance) =>
    <String, dynamic>{
      'prompt_tokens': instance.promptTokens,
      'completion_tokens': instance.completionTokens,
      'total_tokens': instance.totalTokens,
    };

OpenRouterResponse _$OpenRouterResponseFromJson(Map<String, dynamic> json) =>
    OpenRouterResponse(
      id: json['id'] as String,
      object: json['object'] as String,
      created: (json['created'] as num).toInt(),
      model: json['model'] as String,
      choices: (json['choices'] as List<dynamic>)
          .map((e) => OpenRouterChoice.fromJson(e as Map<String, dynamic>))
          .toList(),
      usage: json['usage'] == null
          ? null
          : OpenRouterUsage.fromJson(json['usage'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$OpenRouterResponseToJson(OpenRouterResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'object': instance.object,
      'created': instance.created,
      'model': instance.model,
      'choices': instance.choices,
      'usage': instance.usage,
    };

OpenRouterError _$OpenRouterErrorFromJson(Map<String, dynamic> json) =>
    OpenRouterError(
      message: json['message'] as String,
      type: json['type'] as String?,
      code: json['code'] as String?,
    );

Map<String, dynamic> _$OpenRouterErrorToJson(OpenRouterError instance) =>
    <String, dynamic>{
      'message': instance.message,
      'type': instance.type,
      'code': instance.code,
    };

OpenRouterErrorResponse _$OpenRouterErrorResponseFromJson(
  Map<String, dynamic> json,
) => OpenRouterErrorResponse(
  error: OpenRouterError.fromJson(json['error'] as Map<String, dynamic>),
);

Map<String, dynamic> _$OpenRouterErrorResponseToJson(
  OpenRouterErrorResponse instance,
) => <String, dynamic>{'error': instance.error};
