# Firestore Database Integration Guide

## Overview

This Flutter template includes a comprehensive Firestore Database integration that provides a flexible, scalable data storage solution. The implementation follows best practices with a generic repository pattern that can be used for any data type.

## Architecture

### 🏗️ **Repository Pattern**
- **Generic Base Repository**: `lib/repositories/base_repository.dart`
- **Chat-Specific Repository**: `lib/repositories/chat_repository.dart`
- **Firestore Service**: `lib/services/firestore_service.dart`

### 📊 **Data Models**
- **Chat Messages**: `lib/models/chat_message.dart`
- **Conversations**: `lib/models/conversation.dart`
- **Firestore Serialization**: Built-in support for Firestore Timestamp conversion

### 🎯 **State Management**
- **Riverpod Providers**: `lib/providers/chat_provider.dart`
- **Real-time Updates**: Stream-based data synchronization
- **Offline Support**: Automatic offline persistence

## Features Implemented

### ✅ **Core Functionality**
- **CRUD Operations**: Create, Read, Update, Delete for any data type
- **Real-time Sync**: Live updates using Firestore streams
- **Offline Persistence**: Works without internet connection
- **User-based Security**: Data isolation per authenticated user
- **Batch Operations**: Efficient bulk data operations
- **Query Support**: Advanced filtering and sorting

### ✅ **Chat-Specific Features**
- **Conversation Management**: Create, archive, delete conversations
- **Message Persistence**: All chat messages saved to Firestore
- **Message History**: Persistent chat history across app sessions
- **Auto-generated Titles**: Smart conversation titles from first message
- **Message Counting**: Automatic message count tracking
- **Model Tracking**: Track which AI model was used per conversation

## Database Structure

```
/users/{userId}/
├── conversations/{conversationId}
│   ├── title: string
│   ├── description: string
│   ├── createdAt: timestamp
│   ├── updatedAt: timestamp
│   ├── userId: string
│   ├── model: string
│   ├── messageCount: number
│   ├── isArchived: boolean
│   └── metadata: object
│   
│   └── messages/{messageId}
│       ├── role: string (user|assistant|system)
│       ├── content: string
│       ├── timestamp: timestamp
│       └── id: string
│
├── settings/{settingId}
│   └── [any app settings]
│
└── {customCollection}/{documentId}
    └── [any custom data]
```

## Security Rules

The Firestore security rules ensure:
- **User Isolation**: Users can only access their own data
- **Authentication Required**: All operations require valid authentication
- **Data Validation**: Enforces proper data structure
- **Email Verification**: Optional additional security layer

## Usage Examples

### 🔧 **Creating a Custom Repository**

```dart
// 1. Create your data model
class MyDataModel {
  final String id;
  final String name;
  final DateTime createdAt;
  
  // Add toFirestore() and fromFirestore() methods
  Map<String, dynamic> toFirestore() => {
    'name': name,
    'createdAt': Timestamp.fromDate(createdAt),
  };
  
  factory MyDataModel.fromFirestore(String id, Map<String, dynamic> data) {
    return MyDataModel(
      id: id,
      name: data['name'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

// 2. Create repository
class MyDataRepository extends BaseRepository<MyDataModel> {
  final FirestoreService _firestoreService;
  
  MyDataRepository({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  @override
  CollectionReference<Map<String, dynamic>> get collection {
    return _firestoreService.getUserCollection('myData');
  }

  @override
  MyDataModel fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    return MyDataModel.fromFirestore(doc.id, doc.data()!);
  }

  @override
  Map<String, dynamic> toFirestore(MyDataModel item) {
    return item.toFirestore();
  }
}

// 3. Create provider
final myDataRepositoryProvider = Provider<MyDataRepository>((ref) {
  return MyDataRepository();
});
```

### 📱 **Using in Your App**

```dart
// In your widget
class MyDataScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.read(myDataRepositoryProvider);
    
    return StreamBuilder<List<MyDataModel>>(
      stream: repository.streamAll(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final item = snapshot.data![index];
              return ListTile(title: Text(item.name));
            },
          );
        }
        return CircularProgressIndicator();
      },
    );
  }
}
```

## Configuration

### 🔥 **Firebase Setup**
1. **Firebase Project**: Already configured in `firebase_options.dart`
2. **Firestore Rules**: Deploy the rules from `firestore.rules`
3. **Indexes**: Firestore will auto-create needed indexes

### 📱 **App Configuration**
- **Initialization**: Firestore is initialized in `main.dart`
- **Offline Persistence**: Enabled by default
- **Settings**: Configurable in `FirestoreService`

## Best Practices

### ✅ **Do's**
- Use the repository pattern for all data operations
- Implement proper error handling
- Use streams for real-time updates
- Validate data before saving
- Use batch operations for multiple writes
- Implement proper loading states

### ❌ **Don'ts**
- Don't access Firestore directly in widgets
- Don't ignore offline scenarios
- Don't forget to handle authentication states
- Don't create too many listeners
- Don't store sensitive data without encryption

## Performance Tips

### 🚀 **Optimization**
- **Pagination**: Use `limit()` and `startAfter()` for large datasets
- **Indexing**: Create composite indexes for complex queries
- **Caching**: Leverage offline persistence for better UX
- **Batch Writes**: Use batch operations for multiple updates
- **Stream Management**: Properly dispose of stream subscriptions

## Troubleshooting

### 🐛 **Common Issues**
1. **Permission Denied**: Check Firestore security rules
2. **Offline Issues**: Ensure persistence is enabled
3. **Data Not Syncing**: Verify internet connection and authentication
4. **Build Errors**: Run `flutter clean` and rebuild

### 🔧 **Debug Tools**
- Use Firebase Console to view data
- Enable Firestore debug logging
- Check network connectivity
- Verify authentication state

## Extending the Template

### 📈 **Adding New Data Types**
1. Create your data model with Firestore serialization
2. Extend `BaseRepository<T>` for your data type
3. Create Riverpod providers
4. Implement UI components
5. Add security rules if needed

### 🔒 **Security Considerations**
- Always validate user input
- Use server-side validation where possible
- Implement proper authentication checks
- Consider data encryption for sensitive information
- Regular security rule audits

## Next Steps

This Firestore integration provides a solid foundation for any Flutter app. You can:
- Add more complex data relationships
- Implement full-text search with Algolia
- Add real-time collaboration features
- Integrate with Firebase Functions
- Add analytics and monitoring

The template is designed to be flexible and scalable, supporting any type of data your app needs to store.
