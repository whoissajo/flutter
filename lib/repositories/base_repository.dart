import 'package:cloud_firestore/cloud_firestore.dart';

/// Generic repository interface for Firestore operations
/// This provides a template pattern that can be used for any data type
abstract class BaseRepository<T> {
  /// Get the collection reference for this repository
  CollectionReference<Map<String, dynamic>> get collection;

  /// Convert from Firestore document to model
  T fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc);

  /// Convert from model to Firestore data
  Map<String, dynamic> toFirestore(T item);

  /// Get document ID from model (optional, can return null for auto-generated IDs)
  String? getDocumentId(T item) => null;

  /// Create a new document
  Future<String> create(T item) async {
    try {
      final data = toFirestore(item);
      final docId = getDocumentId(item);
      
      if (docId != null) {
        await collection.doc(docId).set(data);
        return docId;
      } else {
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

  /// Update an existing document
  Future<void> update(String id, T item) async {
    try {
      final data = toFirestore(item);
      await collection.doc(id).update(data);
    } catch (e) {
      throw RepositoryException('Failed to update document: $e');
    }
  }

  /// Delete a document
  Future<void> delete(String id) async {
    try {
      await collection.doc(id).delete();
    } catch (e) {
      throw RepositoryException('Failed to delete document: $e');
    }
  }

  /// Get all documents in the collection
  Future<List<T>> getAll() async {
    try {
      final snapshot = await collection.get();
      return snapshot.docs.map((doc) => fromFirestore(doc)).toList();
    } catch (e) {
      throw RepositoryException('Failed to get all documents: $e');
    }
  }

  /// Get documents with a query
  Future<List<T>> query(Query<Map<String, dynamic>> query) async {
    try {
      final snapshot = await query.get();
      return snapshot.docs.map((doc) => fromFirestore(doc)).toList();
    } catch (e) {
      throw RepositoryException('Failed to query documents: $e');
    }
  }

  /// Stream all documents in the collection
  Stream<List<T>> streamAll() {
    return collection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => fromFirestore(doc)).toList();
    });
  }

  /// Stream documents with a query
  Stream<List<T>> streamQuery(Query<Map<String, dynamic>> query) {
    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => fromFirestore(doc)).toList();
    });
  }

  /// Stream a single document
  Stream<T?> streamDocument(String id) {
    return collection.doc(id).snapshots().map((doc) {
      if (doc.exists) {
        return fromFirestore(doc);
      }
      return null;
    });
  }

  /// Batch operations
  Future<void> batchWrite(List<BatchOperation<T>> operations) async {
    try {
      final batch = FirebaseFirestore.instance.batch();
      
      for (final operation in operations) {
        switch (operation.type) {
          case BatchOperationType.create:
            final docRef = operation.id != null 
                ? collection.doc(operation.id)
                : collection.doc();
            batch.set(docRef, toFirestore(operation.item));
            break;
          case BatchOperationType.update:
            if (operation.id == null) {
              throw RepositoryException('Update operation requires document ID');
            }
            batch.update(collection.doc(operation.id!), toFirestore(operation.item));
            break;
          case BatchOperationType.delete:
            if (operation.id == null) {
              throw RepositoryException('Delete operation requires document ID');
            }
            batch.delete(collection.doc(operation.id!));
            break;
        }
      }
      
      await batch.commit();
    } catch (e) {
      throw RepositoryException('Failed to execute batch operations: $e');
    }
  }

  /// Check if document exists
  Future<bool> exists(String id) async {
    try {
      final doc = await collection.doc(id).get();
      return doc.exists;
    } catch (e) {
      throw RepositoryException('Failed to check document existence: $e');
    }
  }

  /// Count documents in collection
  Future<int> count() async {
    try {
      final snapshot = await collection.get();
      return snapshot.docs.length;
    } catch (e) {
      throw RepositoryException('Failed to count documents: $e');
    }
  }
}

/// Batch operation types
enum BatchOperationType { create, update, delete }

/// Batch operation model
class BatchOperation<T> {
  final BatchOperationType type;
  final T item;
  final String? id;

  const BatchOperation({
    required this.type,
    required this.item,
    this.id,
  });

  /// Create operation
  factory BatchOperation.create(T item, {String? id}) {
    return BatchOperation(type: BatchOperationType.create, item: item, id: id);
  }

  /// Update operation
  factory BatchOperation.update(T item, String id) {
    return BatchOperation(type: BatchOperationType.update, item: item, id: id);
  }

  /// Delete operation (item can be a placeholder)
  factory BatchOperation.delete(T item, String id) {
    return BatchOperation(type: BatchOperationType.delete, item: item, id: id);
  }
}

/// Repository exception
class RepositoryException implements Exception {
  final String message;
  const RepositoryException(this.message);

  @override
  String toString() => 'RepositoryException: $message';
}
