class Failure {}

class ServerFailure extends Failure {}

class NetworkFailure extends Failure {}

class AuthenticationFailure extends Failure {
  final String message;
  AuthenticationFailure({
    required this.message,
  });
}
