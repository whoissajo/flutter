import 'package:json_annotation/json_annotation.dart';
import 'chat_message.dart';

part 'openrouter_models.g.dart';

/// OpenRouter API request model
@JsonSerializable()
class OpenRouterRequest {
  final String model;
  final List<Map<String, dynamic>> messages;
  @JsonKey(name: 'max_tokens')
  final int? maxTokens;
  final double? temperature;
  @JsonKey(name: 'top_p')
  final double? topP;
  final bool? stream;

  const OpenRouterRequest({
    required this.model,
    required this.messages,
    this.maxTokens,
    this.temperature,
    this.topP,
    this.stream,
  });

  factory OpenRouterRequest.fromJson(Map<String, dynamic> json) => _$OpenRouterRequestFromJson(json);
  Map<String, dynamic> toJson() => _$OpenRouterRequestToJson(this);

  /// Create request from chat messages
  factory OpenRouterRequest.fromMessages({
    required List<ChatMessage> messages,
    String model = 'deepseek/deepseek-r1-0528',
    int? maxTokens = 1000,
    double? temperature = 0.7,
    double? topP = 1.0,
    bool? stream = false,
  }) {
    return OpenRouterRequest(
      model: model,
      messages: messages.map((msg) => {
        'role': msg.role.name,
        'content': msg.content,
      }).toList(),
      maxTokens: maxTokens,
      temperature: temperature,
      topP: topP,
      stream: stream,
    );
  }
}

/// OpenRouter API response choice
@JsonSerializable()
class OpenRouterChoice {
  final int index;
  final ChatMessageResponse message;
  @JsonKey(name: 'finish_reason')
  final String? finishReason;

  const OpenRouterChoice({
    required this.index,
    required this.message,
    this.finishReason,
  });

  factory OpenRouterChoice.fromJson(Map<String, dynamic> json) => _$OpenRouterChoiceFromJson(json);
  Map<String, dynamic> toJson() => _$OpenRouterChoiceToJson(this);
}

/// Chat message response from API
@JsonSerializable()
class ChatMessageResponse {
  final String role;
  final String content;

  const ChatMessageResponse({
    required this.role,
    required this.content,
  });

  factory ChatMessageResponse.fromJson(Map<String, dynamic> json) => _$ChatMessageResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ChatMessageResponseToJson(this);

  /// Convert to ChatMessage
  ChatMessage toChatMessage() {
    return ChatMessage.assistant(content);
  }
}

/// OpenRouter API usage information
@JsonSerializable()
class OpenRouterUsage {
  @JsonKey(name: 'prompt_tokens')
  final int promptTokens;
  @JsonKey(name: 'completion_tokens')
  final int completionTokens;
  @JsonKey(name: 'total_tokens')
  final int totalTokens;

  const OpenRouterUsage({
    required this.promptTokens,
    required this.completionTokens,
    required this.totalTokens,
  });

  factory OpenRouterUsage.fromJson(Map<String, dynamic> json) => _$OpenRouterUsageFromJson(json);
  Map<String, dynamic> toJson() => _$OpenRouterUsageToJson(this);
}

/// OpenRouter API response model
@JsonSerializable()
class OpenRouterResponse {
  final String id;
  final String object;
  final int created;
  final String model;
  final List<OpenRouterChoice> choices;
  final OpenRouterUsage? usage;

  const OpenRouterResponse({
    required this.id,
    required this.object,
    required this.created,
    required this.model,
    required this.choices,
    this.usage,
  });

  factory OpenRouterResponse.fromJson(Map<String, dynamic> json) => _$OpenRouterResponseFromJson(json);
  Map<String, dynamic> toJson() => _$OpenRouterResponseToJson(this);

  /// Get the first choice message
  ChatMessage? get firstMessage {
    if (choices.isNotEmpty) {
      return choices.first.message.toChatMessage();
    }
    return null;
  }
}

/// OpenRouter API error model
@JsonSerializable()
class OpenRouterError {
  final String message;
  final String? type;
  final String? code;

  const OpenRouterError({
    required this.message,
    this.type,
    this.code,
  });

  factory OpenRouterError.fromJson(Map<String, dynamic> json) => _$OpenRouterErrorFromJson(json);
  Map<String, dynamic> toJson() => _$OpenRouterErrorToJson(this);

  @override
  String toString() => 'OpenRouterError(message: $message, type: $type, code: $code)';
}

/// OpenRouter API error response
@JsonSerializable()
class OpenRouterErrorResponse {
  final OpenRouterError error;

  const OpenRouterErrorResponse({
    required this.error,
  });

  factory OpenRouterErrorResponse.fromJson(Map<String, dynamic> json) => _$OpenRouterErrorResponseFromJson(json);
  Map<String, dynamic> toJson() => _$OpenRouterErrorResponseToJson(this);
}
