import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../models/chat_message.dart';
import '../models/openrouter_models.dart';
import '../config/api_config.dart';

/// Service for interacting with OpenRouter API
class OpenRouterService {
  static const String _baseUrl = 'https://openrouter.ai/api/v1';
  static String get _apiKey => ApiConfig.validatedOpenRouterApiKey;
  static String get _defaultModel => ApiConfig.defaultAiModel;

  // Optional headers for OpenRouter rankings
  static String get _siteUrl => ApiConfig.siteUrl;
  static String get _siteName => ApiConfig.siteName;

  final http.Client _client;

  OpenRouterService({http.Client? client}) : _client = client ?? http.Client();

  /// Send a chat completion request to OpenRouter
  Future<ChatMessage> sendMessage({
    required List<ChatMessage> messages,
    String? model,
    int? maxTokens,
    double? temperature,
    double? topP,
  }) async {
    try {
      final request = OpenRouterRequest.fromMessages(
        messages: messages,
        model: model ?? _defaultModel,
        maxTokens: maxTokens ?? 1000,
        temperature: temperature ?? 0.7,
        topP: topP ?? 1.0,
        stream: false,
      );

      final response = await _makeRequest(request);
      
      if (response.choices.isNotEmpty) {
        return response.firstMessage ?? ChatMessage.assistant('Sorry, I could not generate a response.');
      } else {
        throw Exception('No response choices received from OpenRouter');
      }
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  /// Make HTTP request to OpenRouter API
  Future<OpenRouterResponse> _makeRequest(OpenRouterRequest request) async {
    final url = Uri.parse('$_baseUrl/chat/completions');
    
    final headers = {
      'Authorization': 'Bearer $_apiKey',
      'Content-Type': 'application/json',
      'HTTP-Referer': _siteUrl,
      'X-Title': _siteName,
    };

    try {
      final response = await _client.post(
        url,
        headers: headers,
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        return OpenRouterResponse.fromJson(jsonData);
      } else {
        // Try to parse error response
        try {
          final errorData = jsonDecode(response.body) as Map<String, dynamic>;
          final errorResponse = OpenRouterErrorResponse.fromJson(errorData);
          throw Exception('OpenRouter API Error: ${errorResponse.error.message}');
        } catch (parseError) {
          throw Exception('HTTP ${response.statusCode}: ${response.body}');
        }
      }
    } on SocketException {
      throw Exception('No internet connection. Please check your network.');
    } on HttpException {
      throw Exception('Network error occurred. Please try again.');
    } on FormatException {
      throw Exception('Invalid response format from OpenRouter API.');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Get available models from OpenRouter
  Future<List<String>> getAvailableModels() async {
    try {
      final url = Uri.parse('$_baseUrl/models');
      final headers = {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      };

      final response = await _client.get(url, headers: headers);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        final models = jsonData['data'] as List<dynamic>;
        return models.map((model) => model['id'] as String).toList();
      } else {
        throw Exception('Failed to fetch models: ${response.statusCode}');
      }
    } catch (e) {
      // Return default models if API call fails
      return [
        'deepseek/deepseek-r1-0528',
        'openai/gpt-4o',
        'openai/gpt-3.5-turbo',
        'anthropic/claude-3-haiku',
        'meta-llama/llama-3.1-8b-instruct',
      ];
    }
  }

  /// Test the connection to OpenRouter API
  Future<bool> testConnection() async {
    try {
      final testMessage = ChatMessage.user('Hello, can you respond with just "OK"?');
      final response = await sendMessage(
        messages: [testMessage],
        maxTokens: 10,
        temperature: 0.1,
      );
      return response.content.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Get model information
  Map<String, dynamic> getModelInfo(String model) {
    switch (model) {
      case 'deepseek/deepseek-r1-0528':
        return {
          'name': 'DeepSeek R1',
          'description': 'Advanced reasoning model with strong analytical capabilities',
          'maxTokens': 8192,
          'costPer1kTokens': 0.14,
        };
      case 'openai/gpt-4o':
        return {
          'name': 'GPT-4o',
          'description': 'OpenAI\'s most capable multimodal model',
          'maxTokens': 4096,
          'costPer1kTokens': 5.0,
        };
      case 'openai/gpt-3.5-turbo':
        return {
          'name': 'GPT-3.5 Turbo',
          'description': 'Fast and efficient conversational AI',
          'maxTokens': 4096,
          'costPer1kTokens': 0.5,
        };
      default:
        return {
          'name': model,
          'description': 'AI Language Model',
          'maxTokens': 4096,
          'costPer1kTokens': 1.0,
        };
    }
  }

  /// Create a system message for better responses
  ChatMessage createSystemMessage() {
    return ChatMessage.system(
      'You are a helpful AI assistant integrated into a Flutter mobile app. '
      'Provide concise, helpful responses. Keep your answers brief and to the point '
      'unless the user specifically asks for detailed explanations.'
    );
  }

  /// Dispose of resources
  void dispose() {
    _client.close();
  }
}
