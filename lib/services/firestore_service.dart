import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Core Firestore service for database operations
/// This service provides common Firestore functionality and utilities
class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  /// Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get Firestore instance
  FirebaseFirestore get firestore => _firestore;

  /// Get current user ID
  String? get currentUserId => FirebaseAuth.instance.currentUser?.uid;

  /// Initialize Firestore with settings
  Future<void> initialize() async {
    try {
      // Enable offline persistence
      await _firestore.enablePersistence(
        const PersistenceSettings(synchronizeTabs: true),
      );
    } catch (e) {
      // Persistence might already be enabled or not supported
      print('Firestore persistence setup: $e');
    }
  }

  /// Get user-specific collection reference
  CollectionReference<Map<String, dynamic>> getUserCollection(String collectionName) {
    final userId = currentUserId;
    if (userId == null) {
      throw FirestoreException('User not authenticated');
    }
    return _firestore.collection('users').doc(userId).collection(collectionName);
  }

  /// Get global collection reference
  CollectionReference<Map<String, dynamic>> getGlobalCollection(String collectionName) {
    return _firestore.collection(collectionName);
  }

  /// Create a user document if it doesn't exist
  Future<void> createUserDocument(String userId, Map<String, dynamic> userData) async {
    try {
      final userDoc = _firestore.collection('users').doc(userId);
      final docSnapshot = await userDoc.get();
      
      if (!docSnapshot.exists) {
        await userDoc.set({
          ...userData,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw FirestoreException('Failed to create user document: $e');
    }
  }

  /// Update user document
  Future<void> updateUserDocument(String userId, Map<String, dynamic> userData) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        ...userData,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw FirestoreException('Failed to update user document: $e');
    }
  }

  /// Get user document
  Future<Map<String, dynamic>?> getUserDocument(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      throw FirestoreException('Failed to get user document: $e');
    }
  }

  /// Delete user document and all subcollections
  Future<void> deleteUserDocument(String userId) async {
    try {
      final userDoc = _firestore.collection('users').doc(userId);
      
      // Delete all subcollections (you might want to customize this)
      final subcollections = ['chats', 'conversations', 'settings'];
      
      final batch = _firestore.batch();
      
      for (final subcollection in subcollections) {
        final snapshot = await userDoc.collection(subcollection).get();
        for (final doc in snapshot.docs) {
          batch.delete(doc.reference);
        }
      }
      
      // Delete the user document itself
      batch.delete(userDoc);
      
      await batch.commit();
    } catch (e) {
      throw FirestoreException('Failed to delete user document: $e');
    }
  }

  /// Perform transaction
  Future<T> runTransaction<T>(
    Future<T> Function(Transaction transaction) updateFunction,
  ) async {
    try {
      return await _firestore.runTransaction(updateFunction);
    } catch (e) {
      throw FirestoreException('Transaction failed: $e');
    }
  }

  /// Create batch
  WriteBatch createBatch() {
    return _firestore.batch();
  }

  /// Execute batch
  Future<void> commitBatch(WriteBatch batch) async {
    try {
      await batch.commit();
    } catch (e) {
      throw FirestoreException('Batch commit failed: $e');
    }
  }

  /// Add server timestamp
  FieldValue get serverTimestamp => FieldValue.serverTimestamp();

  /// Add array union
  FieldValue arrayUnion(List<dynamic> elements) => FieldValue.arrayUnion(elements);

  /// Add array remove
  FieldValue arrayRemove(List<dynamic> elements) => FieldValue.arrayRemove(elements);

  /// Increment value
  FieldValue increment(num value) => FieldValue.increment(value);

  /// Delete field
  FieldValue get delete => FieldValue.delete();

  /// Query helpers
  Query<Map<String, dynamic>> whereEquals(
    CollectionReference<Map<String, dynamic>> collection,
    String field,
    dynamic value,
  ) {
    return collection.where(field, isEqualTo: value);
  }

  Query<Map<String, dynamic>> whereIn(
    CollectionReference<Map<String, dynamic>> collection,
    String field,
    List<dynamic> values,
  ) {
    return collection.where(field, whereIn: values);
  }

  Query<Map<String, dynamic>> whereGreaterThan(
    CollectionReference<Map<String, dynamic>> collection,
    String field,
    dynamic value,
  ) {
    return collection.where(field, isGreaterThan: value);
  }

  Query<Map<String, dynamic>> whereLessThan(
    CollectionReference<Map<String, dynamic>> collection,
    String field,
    dynamic value,
  ) {
    return collection.where(field, isLessThan: value);
  }

  Query<Map<String, dynamic>> orderBy(
    Query<Map<String, dynamic>> query,
    String field, {
    bool descending = false,
  }) {
    return query.orderBy(field, descending: descending);
  }

  Query<Map<String, dynamic>> limit(
    Query<Map<String, dynamic>> query,
    int limit,
  ) {
    return query.limit(limit);
  }

  /// Pagination helpers
  Query<Map<String, dynamic>> startAfter(
    Query<Map<String, dynamic>> query,
    DocumentSnapshot lastDocument,
  ) {
    return query.startAfterDocument(lastDocument);
  }

  Query<Map<String, dynamic>> startAt(
    Query<Map<String, dynamic>> query,
    List<dynamic> values,
  ) {
    return query.startAt(values);
  }

  /// Check connection status
  Future<bool> isConnected() async {
    try {
      await _firestore.enableNetwork();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Enable offline mode
  Future<void> enableOffline() async {
    try {
      await _firestore.disableNetwork();
    } catch (e) {
      throw FirestoreException('Failed to enable offline mode: $e');
    }
  }

  /// Enable online mode
  Future<void> enableOnline() async {
    try {
      await _firestore.enableNetwork();
    } catch (e) {
      throw FirestoreException('Failed to enable online mode: $e');
    }
  }

  /// Clear persistence cache
  Future<void> clearPersistence() async {
    try {
      await _firestore.clearPersistence();
    } catch (e) {
      throw FirestoreException('Failed to clear persistence: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    // Firestore doesn't need explicit disposal
    // But you can add cleanup logic here if needed
  }
}

/// Firestore exception
class FirestoreException implements Exception {
  final String message;
  const FirestoreException(this.message);

  @override
  String toString() => 'FirestoreException: $message';
}
