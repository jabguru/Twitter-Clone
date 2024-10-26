import 'dart:io';

class AppUrls {
  static String endpoint =
      Platform.isAndroid ? '172.20.10.2:8080' : 'localhost:8080';
  static String baseUrl = 'http://$endpoint/api/v1';
  static String login = '$baseUrl/auth/login';
  static String register = '$baseUrl/auth/register';
}
