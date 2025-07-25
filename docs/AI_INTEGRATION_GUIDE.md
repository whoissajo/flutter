# 🤖 AI Integration Guide (OpenRouter)

## 📋 **Overview**

This guide covers the complete AI integration using OpenRouter API with DeepSeek R1 model, including setup, customization, and advanced features for building intelligent conversational interfaces.

## 🏗️ **Architecture Overview**

### **Core Components**

#### **1. OpenRouterService**
```dart
// lib/services/openrouter_service.dart
class OpenRouterService {
  // Core AI communication
  Future<ChatMessage> sendMessage(List<ChatMessage> messages);
  Future<List<String>> getAvailableModels();
  Future<bool> testConnection();
  Map<String, dynamic> getModelInfo(String model);
}
```

#### **2. Chat Models**
```dart
// lib/models/chat_message.dart
class ChatMessage {
  final MessageRole role;        // user, assistant, system
  final String content;          // Message text
  final DateTime timestamp;      // When sent
  final String? id;             // Unique identifier
}

// lib/models/openrouter_models.dart
class OpenRouterRequest;         // API request structure
class OpenRouterResponse;        // API response structure
```

#### **3. Chat Providers**
```dart
// lib/providers/chat_provider.dart
final chatNotifierProvider;      // Chat state management
final openRouterServiceProvider; // Service instance
final userMessagesProvider;      // User messages only
final isChatLoadingProvider;     // Loading state
```

## 🔑 **OpenRouter Setup**

### **Step 1: Get OpenRouter API Key**

#### **Create OpenRouter Account**
1. Go to [OpenRouter.ai](https://openrouter.ai)
2. Click **Sign Up** or **Sign In**
3. Complete account verification
4. Navigate to **API Keys** section
5. Click **Create API Key**
6. Copy your API key: `sk-or-v1-...`

#### **Choose Your Model**
Popular models available:
| Model | Description | Cost/1K tokens | Best for |
|-------|-------------|----------------|----------|
| `deepseek/deepseek-r1-0528` | Advanced reasoning | $0.14 | Complex analysis, coding |
| `openai/gpt-4o` | OpenAI's latest | $5.00 | General conversation |
| `openai/gpt-3.5-turbo` | Fast & efficient | $0.50 | Quick responses |
| `anthropic/claude-3-haiku` | Anthropic's model | $0.25 | Creative writing |
| `meta-llama/llama-3.1-8b-instruct` | Open source | $0.07 | Cost-effective |

### **Step 2: Configure API Key**

#### **Method 1: Direct Configuration (Development)**
Edit `lib/services/openrouter_service.dart`:
```dart
class OpenRouterService {
  static const String _apiKey = 'sk-or-v1-YOUR_API_KEY_HERE';
  static const String _defaultModel = 'deepseek/deepseek-r1-0528';
  static const String _siteUrl = 'https://your-app-domain.com';
  static const String _siteName = 'Your App Name';
}
```

#### **Method 2: Environment Variables (Production)**
Create `lib/config/api_config.dart`:
```dart
class ApiConfig {
  static const String openRouterApiKey = String.fromEnvironment(
    'OPENROUTER_API_KEY',
    defaultValue: 'your-development-key',
  );
  
  static const String defaultModel = String.fromEnvironment(
    'DEFAULT_AI_MODEL',
    defaultValue: 'deepseek/deepseek-r1-0528',
  );
}
```

Build with environment variables:
```bash
flutter build apk --dart-define=OPENROUTER_API_KEY=sk-or-v1-your-key --dart-define=DEFAULT_AI_MODEL=deepseek/deepseek-r1-0528
```

#### **Method 3: Secure Storage (Recommended)**
```dart
// lib/services/secure_storage_service.dart
class SecureStorageService {
  static const _storage = FlutterSecureStorage();
  
  static Future<void> storeApiKey(String apiKey) async {
    await _storage.write(key: 'openrouter_api_key', value: apiKey);
  }
  
  static Future<String?> getApiKey() async {
    return await _storage.read(key: 'openrouter_api_key');
  }
}
```

## 🎯 **Model Configuration**

### **DeepSeek R1 Configuration**

#### **Model Specifications**
- **Context Length**: 8,192 tokens
- **Output Length**: Up to 4,096 tokens
- **Strengths**: Advanced reasoning, code analysis, mathematical problems
- **Best Temperature**: 0.7 for balanced creativity
- **Recommended Top-P**: 1.0 for full vocabulary

#### **Optimal Parameters**
```dart
final response = await _openRouterService.sendMessage(
  messages: messages,
  model: 'deepseek/deepseek-r1-0528',
  maxTokens: 1000,        // Adjust based on needs
  temperature: 0.7,       // 0.0 = deterministic, 1.0 = creative
  topP: 1.0,             // Nucleus sampling parameter
);
```

### **System Prompt Optimization**

#### **Default System Prompt**
```dart
ChatMessage createSystemMessage() {
  return ChatMessage.system(
    'You are a helpful AI assistant integrated into a Flutter mobile app. '
    'Provide concise, helpful responses. Keep your answers brief and to the point '
    'unless the user specifically asks for detailed explanations.'
  );
}
```

#### **Domain-Specific System Prompts**
```dart
// For a productivity app
ChatMessage createProductivitySystemMessage() {
  return ChatMessage.system(
    'You are a productivity assistant helping users organize their work and life. '
    'Provide actionable advice, suggest tools and techniques, and help users '
    'achieve their goals efficiently. Keep responses practical and implementable.'
  );
}

// For a learning app
ChatMessage createLearningSystemMessage() {
  return ChatMessage.system(
    'You are an educational assistant helping users learn new concepts. '
    'Break down complex topics into digestible parts, provide examples, '
    'and encourage questions. Adapt your explanations to the user\'s level.'
  );
}

// For a creative app
ChatMessage createCreativeSystemMessage() {
  return ChatMessage.system(
    'You are a creative assistant helping users with writing, brainstorming, '
    'and artistic projects. Encourage creativity, provide inspiration, '
    'and offer constructive feedback on ideas and projects.'
  );
}
```

## 🎨 **Chat Interface Customization**

### **Message Styling**

#### **Custom Message Bubbles**
```dart
// lib/widgets/custom_message_bubble.dart
class CustomMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final ThemeData theme;
  
  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) _buildAvatar(false),
          if (!isUser) SizedBox(width: 8),
          
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser 
                    ? theme.colorScheme.primary 
                    : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomRight: isUser ? Radius.circular(4) : null,
                  bottomLeft: !isUser ? Radius.circular(4) : null,
                ),
                border: !isUser ? Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                ) : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMessageContent(),
                  SizedBox(height: 4),
                  _buildTimestamp(),
                ],
              ),
            ),
          ),
          
          if (isUser) SizedBox(width: 8),
          if (isUser) _buildAvatar(true),
        ],
      ),
    );
  }
  
  Widget _buildAvatar(bool isUser) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
      child: Icon(
        isUser ? Icons.person : Icons.psychology,
        size: 16,
        color: theme.colorScheme.primary,
      ),
    );
  }
  
  Widget _buildMessageContent() {
    return SelectableText(
      message.content,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: message.isUser 
            ? theme.colorScheme.onPrimary 
            : theme.colorScheme.onSurface,
        height: 1.4,
      ),
    );
  }
  
  Widget _buildTimestamp() {
    return Text(
      _formatTimestamp(message.timestamp),
      style: theme.textTheme.bodySmall?.copyWith(
        color: (message.isUser 
            ? theme.colorScheme.onPrimary 
            : theme.colorScheme.onSurface).withOpacity(0.6),
        fontSize: 11,
      ),
    );
  }
  
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }
}
```

#### **Typing Indicator**
```dart
class TypingIndicator extends StatefulWidget {
  @override
  _TypingIndicatorState createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true);
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            child: Icon(Icons.psychology, size: 16),
          ),
          SizedBox(width: 12),
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Row(
                children: List.generate(3, (index) {
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 2),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(
                        0.3 + (0.7 * _animation.value * (index == 1 ? 1 : 0.5)),
                      ),
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              );
            },
          ),
          SizedBox(width: 8),
          Text(
            'AI is thinking...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
```

### **Input Field Enhancement**

#### **Advanced Input Field**
```dart
class AdvancedChatInput extends StatefulWidget {
  final Function(String) onSendMessage;
  final bool isLoading;
  
  @override
  _AdvancedChatInputState createState() => _AdvancedChatInputState();
}

class _AdvancedChatInputState extends State<AdvancedChatInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _hasText = false;
  
  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _hasText = _controller.text.trim().isNotEmpty;
      });
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                  ),
                ),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: _hasText ? _sendMessage : null,
                  decoration: InputDecoration(
                    hintText: 'Type your message...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    suffixIcon: _hasText
                        ? IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              _controller.clear();
                              _focusNode.requestFocus();
                            },
                          )
                        : null,
                  ),
                ),
              ),
            ),
            
            SizedBox(width: 8),
            
            AnimatedContainer(
              duration: Duration(milliseconds: 200),
              child: FloatingActionButton.small(
                onPressed: _hasText && !widget.isLoading ? _sendMessage : null,
                backgroundColor: _hasText 
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                child: widget.isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      )
                    : Icon(
                        Icons.send,
                        color: _hasText 
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.outline,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _sendMessage([String? value]) {
    final message = value ?? _controller.text.trim();
    if (message.isNotEmpty) {
      widget.onSendMessage(message);
      _controller.clear();
      _focusNode.requestFocus();
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
```

## 🔧 **Advanced Features**

### **Model Switching**

#### **Model Selection UI**
```dart
class ModelSelector extends StatelessWidget {
  final String currentModel;
  final Function(String) onModelChanged;
  
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final availableModels = ref.watch(availableModelsProvider);
        
        return availableModels.when(
          data: (models) => DropdownButton<String>(
            value: currentModel,
            onChanged: onModelChanged,
            items: models.map((model) {
              final info = ref.read(modelInfoProvider(model));
              return DropdownMenuItem(
                value: model,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(info['name']),
                    Text(
                      '\$${info['costPer1kTokens']}/1K tokens',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          loading: () => CircularProgressIndicator(),
          error: (error, stack) => Text('Error loading models'),
        );
      },
    );
  }
}
```

### **Message Actions**

#### **Copy, Regenerate, Delete**
```dart
class MessageActions extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onCopy;
  final VoidCallback? onRegenerate;
  final VoidCallback? onDelete;
  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.copy, size: 16),
          onPressed: onCopy,
          tooltip: 'Copy message',
        ),
        if (message.isAssistant && onRegenerate != null)
          IconButton(
            icon: Icon(Icons.refresh, size: 16),
            onPressed: onRegenerate,
            tooltip: 'Regenerate response',
          ),
        IconButton(
          icon: Icon(Icons.delete, size: 16),
          onPressed: onDelete,
          tooltip: 'Delete message',
        ),
      ],
    );
  }
}
```

### **Conversation Management**

#### **Save and Load Conversations**
```dart
class ConversationManager {
  static Future<String> saveConversation(List<ChatMessage> messages) async {
    final conversation = Conversation.create(
      userId: FirebaseAuth.instance.currentUser!.uid,
      title: _generateTitle(messages),
      model: 'deepseek/deepseek-r1-0528',
    );
    
    final repository = ConversationRepository();
    return await repository.create(conversation);
  }
  
  static String _generateTitle(List<ChatMessage> messages) {
    final userMessages = messages.where((m) => m.isUser).toList();
    if (userMessages.isNotEmpty) {
      return Conversation.generateTitle(userMessages.first.content);
    }
    return 'New Conversation';
  }
  
  static Future<List<ChatMessage>> loadConversation(String conversationId) async {
    final messageRepository = ChatMessageRepository(conversationId: conversationId);
    return await messageRepository.getMessagesOrdered();
  }
}
```

## 🧪 **Testing AI Integration**

### **Test Scenarios**

#### **Basic Functionality**
- [ ] Send simple text message
- [ ] Receive AI response
- [ ] Handle network errors
- [ ] Test with different models
- [ ] Verify message persistence

#### **Edge Cases**
- [ ] Very long messages (near token limit)
- [ ] Special characters and emojis
- [ ] Multiple rapid messages
- [ ] Network interruption during response
- [ ] Invalid API key handling

#### **Performance Testing**
- [ ] Response time measurement
- [ ] Memory usage monitoring
- [ ] Battery impact assessment
- [ ] Offline behavior testing

### **Debug Tools**

#### **API Response Logging**
```dart
// Add to OpenRouterService for debugging
if (kDebugMode) {
  print('OpenRouter Request: ${jsonEncode(request.toJson())}');
  print('OpenRouter Response: ${response.body}');
  print('Response Time: ${DateTime.now().difference(startTime).inMilliseconds}ms');
}
```

#### **Token Usage Tracking**
```dart
class TokenUsageTracker {
  static int totalTokensUsed = 0;
  static double totalCost = 0.0;
  
  static void trackUsage(OpenRouterResponse response) {
    if (response.usage != null) {
      totalTokensUsed += response.usage!.totalTokens;
      totalCost += _calculateCost(response.usage!.totalTokens, response.model);
    }
  }
  
  static double _calculateCost(int tokens, String model) {
    final costPer1k = _getModelCost(model);
    return (tokens / 1000) * costPer1k;
  }
}
```

## 🎤 **Voice Input Integration**

### **Overview**
The template includes speech-to-text functionality that allows users to speak instead of typing their messages to the AI chatbot.

### **Core Components**

#### **1. SpeechService**
```dart
// lib/services/speech_service.dart
class SpeechService {
  // Initialize speech recognition
  Future<bool> initialize();

  // Start/stop listening
  Future<void> startListening();
  Future<void> stopListening();
  Future<void> cancel();

  // State streams
  Stream<bool> get isListeningStream;
  Stream<String> get wordsStream;
  Stream<String> get errorStream;

  // Current state
  bool get isListening;
  String get lastWords;
}
```

#### **2. Speech Providers**
```dart
// lib/providers/speech_provider.dart
final speechServiceProvider;      // Service instance
final speechListeningProvider;    // Listening state stream
final speechWordsProvider;        // Recognized words stream
final speechErrorProvider;        // Error messages stream
final speechInitializedProvider;  // Initialization state
```

### **Dependencies**
```yaml
# pubspec.yaml
dependencies:
  speech_to_text: ^6.6.2
  permission_handler: ^11.3.1
```

### **Platform Configuration**

#### **Android Permissions**
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.MICROPHONE" />
```

#### **iOS Permissions**
```xml
<!-- ios/Runner/Info.plist -->
<key>NSMicrophoneUsageDescription</key>
<string>This app needs access to microphone for voice input in the chat.</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>This app needs access to speech recognition for voice input in the chat.</string>
```

### **Usage in Chat Interface**

#### **Voice Button States**
- **Inactive**: `Icons.mic_none` - Ready to start voice input
- **Active**: `Icons.mic` - Voice mode enabled, ready to listen
- **Listening**: `Icons.stop` with error color - Currently recording

#### **User Flow**
1. User taps voice button to enter voice mode
2. Text field shows "Tap mic to speak" hint
3. User taps voice button again to start listening
4. Text field shows "Listening..." and becomes read-only
5. Speech is converted to text in real-time
6. User can stop manually or speech auto-stops after pause
7. User can edit the transcribed text if needed
8. Send button works normally with voice-transcribed text

### **Implementation Example**

#### **Voice Input Toggle**
```dart
Future<void> _toggleVoiceInput() async {
  final speechService = ref.read(speechServiceProvider);

  if (_isVoiceMode) {
    // Exit voice mode
    if (speechService.isListening) {
      await speechService.stopListening();
    }
    setState(() => _isVoiceMode = false);
  } else {
    // Enter voice mode
    setState(() => _isVoiceMode = true);
    _messageController.clear();
    await speechService.startListening();
  }
}
```

#### **Real-time Text Updates**
```dart
// Listen to speech recognition results
ref.listen(speechWordsProvider, (previous, next) {
  if (_isVoiceMode && next.hasValue && next.value != null) {
    _messageController.text = next.value!;
    _messageController.selection = TextSelection.fromPosition(
      TextPosition(offset: _messageController.text.length),
    );
  }
});
```

### **Error Handling**
```dart
// Handle speech recognition errors
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
```

### **Customization Options**

#### **Speech Recognition Settings**
```dart
// In SpeechService.startListening()
await _speechToText.listen(
  listenFor: const Duration(seconds: 30),  // Max duration
  pauseFor: const Duration(seconds: 3),    // Pause detection
  partialResults: true,                    // Real-time results
  localeId: 'en_US',                      // Language
  cancelOnError: true,                     // Auto-cancel on error
  listenMode: ListenMode.confirmation,     // Recognition mode
);
```

#### **Supported Languages**
```dart
// Get available locales
final locales = await speechService.getLocales();
for (final locale in locales) {
  print('${locale.name}: ${locale.localeId}');
}
```

### **Best Practices**

1. **Permission Handling**: Always check microphone permissions before starting
2. **Error Recovery**: Provide clear error messages and recovery options
3. **User Feedback**: Show visual indicators for listening state
4. **Auto-stop**: Implement timeout and pause detection
5. **Offline Fallback**: Gracefully handle when speech recognition is unavailable

### **Troubleshooting**

#### **Common Issues**
- **Permission Denied**: Check platform-specific permission settings
- **Not Available**: Speech recognition may not be available on emulators
- **Poor Recognition**: Ensure quiet environment and clear speech
- **Timeout**: Adjust `listenFor` duration based on use case

Your AI integration now supports both text and voice input! 🚀
