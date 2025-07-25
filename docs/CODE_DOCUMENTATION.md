# 📚 Code Documentation & Architecture

## 📋 **Overview**

This document provides detailed explanations of the codebase architecture, design patterns, and implementation details to help developers understand and extend the Flutter AI Template.

## 🏗️ **Project Architecture**

### **Clean Architecture Pattern**

The project follows Clean Architecture principles with clear separation of concerns:

```
lib/
├── main.dart                 # App entry point
├── app.dart                  # App configuration
├── constants/                # App-wide constants
├── models/                   # Data models (entities)
├── services/                 # Business logic (use cases)
├── repositories/             # Data access layer
├── providers/                # State management (Riverpod)
├── screens/                  # UI layer (presentation)
├── widgets/                  # Reusable UI components
└── utils/                    # Utility functions
```

### **Dependency Flow**
```
UI Layer (Screens/Widgets)
    ↓
State Management (Providers)
    ↓
Business Logic (Services)
    ↓
Data Access (Repositories)
    ↓
External APIs/Database
```

## 🔧 **Core Components Explained**

### **1. Main Application Entry**

#### **main.dart**
```dart
/// Application entry point
/// 
/// Initializes Firebase, services, and starts the Flutter app
/// with proper error handling and configuration
void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with error handling
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Handle Firebase initialization errors
    print('Firebase initialization error: $e');
  }
  
  // Initialize app services
  await OnboardingService.init();
  await FirestoreService().initialize();
  
  // Run app with Riverpod provider scope
  runApp(
    ProviderScope(
      child: FlutterTemplateApp(),
    ),
  );
}
```

#### **app.dart**
```dart
/// Main application widget
/// 
/// Configures app-wide settings including:
/// - Theme configuration
/// - Router setup
/// - Global providers
/// - Error handling
class FlutterTemplateApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    
    return MaterialApp.router(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
```

### **2. State Management (Riverpod)**

#### **Provider Pattern Explanation**
```dart
/// Example: Authentication Provider
/// 
/// This provider manages authentication state and operations
/// using StateNotifier for complex state management
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.read(authServiceProvider);
  return AuthNotifier(authService);
});

/// AuthNotifier handles all authentication operations
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  
  AuthNotifier(this._authService) : super(const AuthState.initial()) {
    // Initialize authentication state
    _initializeAuth();
  }
  
  /// Initialize authentication by checking current user
  Future<void> _initializeAuth() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        state = AuthState.authenticated(user);
      } else {
        state = const AuthState.unauthenticated();
      }
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }
  
  /// Sign in with email and password
  Future<void> signInWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final result = await _authService.signInWithEmail(email, password);
      
      if (result.success) {
        // Authentication successful - state will be updated by auth stream
        state = state.copyWith(isLoading: false);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: result.message,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred',
      );
    }
  }
}
```

#### **Provider Types Used**

1. **Provider**: For simple, immutable values
```dart
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});
```

2. **StateNotifierProvider**: For complex, mutable state
```dart
final chatNotifierProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  final openRouterService = ref.read(openRouterServiceProvider);
  final conversationRepository = ref.read(conversationRepositoryProvider);
  return ChatNotifier(openRouterService, conversationRepository);
});
```

3. **FutureProvider**: For asynchronous operations
```dart
final availableModelsProvider = FutureProvider<List<String>>((ref) async {
  final openRouterService = ref.read(openRouterServiceProvider);
  return await openRouterService.getAvailableModels();
});
```

4. **StreamProvider**: For real-time data
```dart
final activeConversationsProvider = StreamProvider<List<Conversation>>((ref) {
  final conversationRepository = ref.read(conversationRepositoryProvider);
  return conversationRepository.streamActiveConversations();
});
```

### **3. Repository Pattern**

#### **Base Repository**
```dart
/// Generic repository interface for Firestore operations
/// 
/// This abstract class provides a template for all data repositories
/// ensuring consistent CRUD operations across different data types
abstract class BaseRepository<T> {
  /// Get the Firestore collection reference
  CollectionReference<Map<String, dynamic>> get collection;
  
  /// Convert Firestore document to model
  T fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc);
  
  /// Convert model to Firestore data
  Map<String, dynamic> toFirestore(T item);
  
  /// Get document ID from model (optional)
  String? getDocumentId(T item) => null;
  
  /// Create a new document
  /// 
  /// Returns the document ID of the created item
  /// Handles both auto-generated and custom IDs
  Future<String> create(T item) async {
    try {
      final data = toFirestore(item);
      final docId = getDocumentId(item);
      
      if (docId != null) {
        // Use custom ID
        await collection.doc(docId).set(data);
        return docId;
      } else {
        // Auto-generate ID
        final docRef = await collection.add(data);
        return docRef.id;
      }
    } catch (e) {
      throw RepositoryException('Failed to create document: $e');
    }
  }
  
  /// Read a document by ID
  Future<T?> read(String id) async {
    try {
      final doc = await collection.doc(id).get();
      if (doc.exists) {
        return fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw RepositoryException('Failed to read document: $e');
    }
  }
  
  // ... other CRUD operations
}
```

#### **Specific Repository Implementation**
```dart
/// Chat message repository implementation
/// 
/// Extends BaseRepository to provide chat-specific operations
/// while inheriting all standard CRUD functionality
class ChatMessageRepository extends BaseRepository<ChatMessage> {
  final FirestoreService _firestoreService;
  final String conversationId;

  ChatMessageRepository({
    required String conversationId,
    FirestoreService? firestoreService,
  }) : _firestoreService = firestoreService ?? FirestoreService(),
       conversationId = conversationId;

  @override
  CollectionReference<Map<String, dynamic>> get collection {
    // Messages are stored as subcollection of conversations
    return _firestoreService
        .getUserCollection('conversations')
        .doc(conversationId)
        .collection('messages');
  }

  @override
  ChatMessage fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return ChatMessage.fromFirestore(data).copyWith(id: doc.id);
  }

  @override
  Map<String, dynamic> toFirestore(ChatMessage item) {
    return item.toFirestore();
  }

  /// Get messages ordered by timestamp
  /// 
  /// Custom method that leverages base repository's query functionality
  /// to provide ordered message retrieval
  Future<List<ChatMessage>> getMessagesOrdered({bool ascending = true}) async {
    final query = collection.orderBy('timestamp', descending: !ascending);
    return await this.query(query);
  }

  /// Stream messages in real-time
  /// 
  /// Provides live updates for chat interface
  Stream<List<ChatMessage>> streamMessagesOrdered({bool ascending = true}) {
    final query = collection.orderBy('timestamp', descending: !ascending);
    return streamQuery(query);
  }
}
```

### **4. Service Layer**

#### **Service Pattern Explanation**
```dart
/// Authentication service
/// 
/// Handles all authentication-related business logic
/// Abstracts Firebase Auth complexity from the UI layer
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  
  /// Get current authenticated user
  /// 
  /// Returns UserModel if authenticated, null otherwise
  /// Converts Firebase User to our custom UserModel
  Future<UserModel?> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      return UserModel.fromFirebaseUser(firebaseUser);
    }
    return null;
  }
  
  /// Sign up with email and password
  /// 
  /// Comprehensive sign-up process including:
  /// - Input validation
  /// - Firebase user creation
  /// - Email verification
  /// - User document creation in Firestore
  /// - Error handling
  Future<AuthResult> signUpWithEmail(String email, String password) async {
    try {
      // Validate inputs
      if (!_isEmailValid(email)) {
        return AuthResult.failure('Please enter a valid email address');
      }
      
      if (!_isPasswordValid(password)) {
        return AuthResult.failure(
          'Password must be at least 8 characters with uppercase and number'
        );
      }
      
      // Create Firebase user
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Send verification email
      await credential.user?.sendEmailVerification();
      
      // Create user document in Firestore
      if (credential.user != null) {
        await _createUserDocument(credential.user!);
      }
      
      return AuthResult.success(
        'Account created successfully! Please verify your email.'
      );
      
    } on FirebaseAuthException catch (e) {
      // Handle Firebase-specific errors
      return AuthResult.failure(_getErrorMessage(e.code));
    } catch (e) {
      // Handle unexpected errors
      return AuthResult.failure('An unexpected error occurred');
    }
  }
  
  /// Validate email format
  /// 
  /// Uses regex to ensure proper email format
  bool _isEmailValid(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
  
  /// Validate password strength
  /// 
  /// Ensures password meets security requirements:
  /// - Minimum 8 characters
  /// - At least one uppercase letter
  /// - At least one number
  bool _isPasswordValid(String password) {
    return password.length >= 8 &&
           password.contains(RegExp(r'[A-Z]')) &&
           password.contains(RegExp(r'[0-9]'));
  }
  
  /// Create user document in Firestore
  /// 
  /// Creates a user profile document with:
  /// - Basic user information
  /// - Timestamps
  /// - Authentication provider info
  Future<void> _createUserDocument(User user) async {
    final userDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid);
    
    final userData = {
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName ?? _extractNameFromEmail(user.email!),
      'photoURL': user.photoURL,
      'emailVerified': user.emailVerified,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'lastSignIn': FieldValue.serverTimestamp(),
      'authProvider': 'email',
    };
    
    await userDoc.set(userData, SetOptions(merge: true));
  }
  
  /// Extract display name from email
  /// 
  /// Converts "john.doe@example.com" to "John Doe"
  String _extractNameFromEmail(String email) {
    final username = email.split('@')[0];
    return username
        .split('.')
        .map((part) => part.isNotEmpty 
            ? part[0].toUpperCase() + part.substring(1).toLowerCase()
            : '')
        .join(' ');
  }
  
  /// Convert Firebase Auth error codes to user-friendly messages
  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account found for this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
```

### **5. Model Classes**

#### **Data Model Pattern**
```dart
/// Chat message model
/// 
/// Represents a single message in a conversation
/// Includes Firestore serialization and JSON serialization
@JsonSerializable()
class ChatMessage {
  final MessageRole role;
  final String content;
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime timestamp;
  final String? id;

  const ChatMessage({
    required this.role,
    required this.content,
    required this.timestamp,
    this.id,
  });

  /// Factory constructor from JSON
  /// 
  /// Used for JSON serialization/deserialization
  factory ChatMessage.fromJson(Map<String, dynamic> json) => 
      _$ChatMessageFromJson(json);

  /// Convert to JSON
  Map<String, dynamic> toJson() => _$ChatMessageToJson(this);

  /// Create a user message
  /// 
  /// Convenience factory for creating user messages
  /// with automatic timestamp and ID generation
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

  /// Convert to Firestore document
  /// 
  /// Converts the model to a format suitable for Firestore storage
  /// Handles timestamp conversion to Firestore Timestamp
  Map<String, dynamic> toFirestore() {
    return {
      'role': role.name,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
      'id': id,
    };
  }

  /// Create from Firestore document
  /// 
  /// Converts Firestore document data back to model
  /// Handles timestamp conversion from Firestore Timestamp
  factory ChatMessage.fromFirestore(Map<String, dynamic> data) {
    return ChatMessage(
      role: MessageRole.values.firstWhere(
        (e) => e.name == data['role'],
        orElse: () => MessageRole.user,
      ),
      content: data['content'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      id: data['id'],
    );
  }

  /// Copy with method
  /// 
  /// Creates a new instance with modified properties
  /// Useful for updating specific fields while keeping others unchanged
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

  /// Convenience getters for role checking
  bool get isUser => role == MessageRole.user;
  bool get isAssistant => role == MessageRole.assistant;
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
    return role.hashCode ^ 
           content.hashCode ^ 
           timestamp.hashCode ^ 
           id.hashCode;
  }

  @override
  String toString() {
    return 'ChatMessage(role: $role, content: $content, timestamp: $timestamp, id: $id)';
  }
}

/// Helper functions for JSON serialization with Firestore Timestamp
/// 
/// These functions handle the conversion between different timestamp formats
/// ensuring compatibility between JSON serialization and Firestore storage
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
```

## 🎯 **Design Patterns Used**

### **1. Repository Pattern**
- **Purpose**: Abstracts data access logic
- **Benefits**: Testable, swappable data sources
- **Implementation**: BaseRepository<T> with specific implementations

### **2. Provider Pattern (Riverpod)**
- **Purpose**: State management and dependency injection
- **Benefits**: Reactive UI, testable, compile-time safe
- **Implementation**: Various provider types for different use cases

### **3. Factory Pattern**
- **Purpose**: Object creation with different configurations
- **Benefits**: Flexible object creation, encapsulated logic
- **Implementation**: Factory constructors in model classes

### **4. Observer Pattern**
- **Purpose**: Real-time updates and reactive programming
- **Benefits**: Automatic UI updates, loose coupling
- **Implementation**: Streams and Riverpod providers

### **5. Strategy Pattern**
- **Purpose**: Interchangeable algorithms/implementations
- **Benefits**: Flexible behavior, easy testing
- **Implementation**: Different authentication providers, AI models

## 🔍 **Code Quality Standards**

### **Documentation Standards**
```dart
/// Brief description of the class/method
/// 
/// Detailed explanation of what this does, including:
/// - Purpose and use cases
/// - Parameters and their meanings
/// - Return values and their significance
/// - Any side effects or important behavior
/// - Examples of usage (if complex)
/// 
/// Example:
/// ```dart
/// final result = await authService.signInWithEmail(
///   'user@example.com',
///   'password123',
/// );
/// ```
/// 
/// Throws [AuthException] if authentication fails
/// Returns [AuthResult] with success/failure status
```

### **Error Handling Pattern**
```dart
/// Consistent error handling across the application
try {
  // Attempt operation
  final result = await riskyOperation();
  return SuccessResult(result);
} on SpecificException catch (e) {
  // Handle specific exceptions
  return FailureResult('Specific error: ${e.message}');
} catch (e) {
  // Handle unexpected errors
  return FailureResult('Unexpected error occurred');
}
```

### **Naming Conventions**
- **Classes**: PascalCase (e.g., `ChatMessage`, `AuthService`)
- **Methods**: camelCase (e.g., `sendMessage`, `getCurrentUser`)
- **Variables**: camelCase (e.g., `currentUser`, `isLoading`)
- **Constants**: camelCase with const (e.g., `defaultTimeout`)
- **Private members**: underscore prefix (e.g., `_privateMethod`)

This documentation provides the foundation for understanding and extending the Flutter AI Template codebase! 🚀
