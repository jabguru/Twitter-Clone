import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/core/error/exceptions.dart';
import 'package:twitter_clone/core/networking/urls.dart';
import 'package:twitter_clone/core/providers.dart';

final authDatasourceProvider = Provider((ref) {
  final dio = ref.watch(dioProvider);
  return AuthDatasource(dio: dio);
});

abstract class IAuthDatasource {
  Future<bool> register({
    required String email,
    required String password,
  });
  Future<Map> login({
    required String email,
    required String password,
  });
  // Future<User?> currentUserAccount();
  Future<void> logout();
}

class AuthDatasource implements IAuthDatasource {
  final Dio _dio;
  AuthDatasource({
    required Dio dio,
  }) : _dio = dio;

  @override
  Future<Map> login({
    required String email,
    required String password,
  }) async {
    final Response res = await _dio.post(
      Endpoints.login,
      data: {
        'email': email,
        'password': password,
      },
    );

    if (res.statusCode == 200) {
      return res.data;
    }

    throw ServerException();
  }

  @override
  Future<bool> register({
    required String email,
    required String password,
  }) async {
    final Response res = await _dio.post(
      Endpoints.register,
      data: {
        'email': email,
        'password': password,
      },
    );

    if (res.statusCode == 200) {
      return true;
    }

    throw ServerException();
  }

  @override
  Future<void> logout() async {
    return;
  }
}
