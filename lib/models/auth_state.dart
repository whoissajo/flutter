/// Authentication state enumeration
enum AuthState {
  /// User is not authenticated
  unauthenticated,
  
  /// User is authenticated
  authenticated,
  
  /// Authentication status is being checked
  loading,
  
  /// Authentication error occurred
  error,
}

/// Authentication result class
class AuthResult {
  final bool success;
  final String? errorMessage;
  final String? errorCode;

  const AuthResult({
    required this.success,
    this.errorMessage,
    this.errorCode,
  });

  /// Create successful auth result
  factory AuthResult.success() {
    return const AuthResult(success: true);
  }

  /// Create failed auth result
  factory AuthResult.failure({
    required String errorMessage,
    String? errorCode,
  }) {
    return AuthResult(
      success: false,
      errorMessage: errorMessage,
      errorCode: errorCode,
    );
  }

  @override
  String toString() {
    return 'AuthResult(success: $success, errorMessage: $errorMessage, errorCode: $errorCode)';
  }
}

/// Sign-in method enumeration
enum SignInMethod {
  email,
  google,
  apple,
  anonymous,
}

/// Authentication exception class
class AuthException implements Exception {
  final String message;
  final String? code;

  const AuthException(this.message, {this.code});

  @override
  String toString() => 'AuthException: $message${code != null ? ' (Code: $code)' : ''}';
}
