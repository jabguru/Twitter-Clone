class ServerException implements Exception {}

class AuthenticationException implements Exception {
  final String message;
  const AuthenticationException({
    required this.message,
  });
}

class AccountException implements Exception {
  final String message;
  const AccountException({
    required this.message,
  });
}
