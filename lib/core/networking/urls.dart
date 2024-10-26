import 'dart:io';

class Endpoints {
  static String endpoint =
      Platform.isAndroid ? '172.20.10.2:8080' : 'localhost:8080';
  static String baseUrl = 'http://$endpoint/api/v1';

  // ? AUTH
  static String login = '$baseUrl/auth/login';
  static String register = '$baseUrl/auth/register';
  static String refreshToken = '$baseUrl/refreshToken';

  // ? USER
  static String saveUser = '$baseUrl/users/save';
  static String getUser(int id) => '$baseUrl/users/$id';
  static String searchUsers(String name) => '$baseUrl/users/search';
}
