/// Local storage base repository
/// This is a simplified base repository for local storage operations

abstract class BaseRepository<T> {
  /// Get all items
  Future<List<T>> getAll();

  /// Get item by id
  Future<T?> get(String id);

  /// Create new item
  Future<String> create(T item);

  /// Update existing item
  Future<void> update(String id, T item);

  /// Delete item by id
  Future<void> delete(String id);

  /// Count items
  Future<int> count() async {
    final items = await getAll();
    return items.length;
  }
}
