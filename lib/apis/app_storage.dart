import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:twitter_clone/models/user_model.dart';

abstract class IAppStorage {
  Future<void> saveAccessToken(String value);
  Future<String?> getAccessToken();
  Future<void> saveRefreshToken(String value);
  Future<String?> getRefreshToken();
  Future<void> saveUser(Map value);
  Future<void> clearStorage();
  Future<UserModel?> getUser();
}

class AppStorage implements IAppStorage {
  final FlutterSecureStorage secureStorage;

  AppStorage({required this.secureStorage});

  @override
  Future<String?> getAccessToken() async {
    return await secureStorage.read(key: "accessToken");
  }

  @override
  Future<void> saveAccessToken(String value) async {
    return await secureStorage.write(key: "accessToken", value: value);
  }

  @override
  Future<String?> getRefreshToken() async {
    return await secureStorage.read(key: "refreshToken");
  }

  @override
  Future<void> saveRefreshToken(String value) async {
    return await secureStorage.write(key: "refreshToken", value: value);
  }

  @override
  Future<void> saveUser(Map value) async {
    return await secureStorage.write(key: "USER", value: jsonEncode(value));
  }

  @override
  Future<UserModel?> getUser() async {
    // await secureStorage.deleteAll();
    String? userString = await secureStorage.read(key: "USER");
    if (userString != null) {
      Map<String, dynamic> userMap = jsonDecode(userString);
      return UserModel.fromMap(userMap);
    }
    return null;
  }

  @override
  Future<void> clearStorage() async {
    await secureStorage.deleteAll();
  }
}
