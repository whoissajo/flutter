/// Simple user model for local storage app
class UserModel {
  final String id;
  final String? name;
  final String? email;
  final String? photoUrl;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    this.name,
    this.email,
    this.photoUrl,
    required this.createdAt,
  });

  /// Factory constructor for local user
  factory UserModel.localUser() {
    return UserModel(
      id: 'local_user',
      name: 'Local User',
      email: null,
      photoUrl: null,
      createdAt: DateTime.now(),
    );
  }

  /// Copy with method
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? photoUrl,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Create from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 'local_user',
      name: json['name'],
      email: json['email'],
      photoUrl: json['photoUrl'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  /// Convert to local storage format
  Map<String, dynamic> toStorage() {
    return toJson();
  }

  /// Create from local storage
  factory UserModel.fromStorage(Map<String, dynamic> data) {
    return UserModel.fromJson(data);
  }
}
