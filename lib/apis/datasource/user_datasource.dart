import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/core/error/exceptions.dart';
import 'package:twitter_clone/core/networking/urls.dart';
import 'package:twitter_clone/core/providers.dart';

final userDatasourceProvider = Provider((ref) {
  final dio = ref.watch(dioProvider);
  return UserDatasource(dio: dio);
});

abstract class IUserDatasource {
  Future<void> saveUserData(
    Map<String, dynamic> userModel, {
    File? profilePhoto,
    File? bannerPhoto,
  });
  Future<Map<String, dynamic>> getUserData(int id);
  Future<List<Map<String, dynamic>>> searchUserByName(String name);
  // Stream<RealtimeMessage> getLatestUserProfileData();
}

class UserDatasource implements IUserDatasource {
  final Dio _dio;
  UserDatasource({
    required Dio dio,
  }) : _dio = dio;

  @override
  Future<Map<String, dynamic>> getUserData(int id) async {
    final Response res = await _dio.get(
      Endpoints.getUser(id),
    );

    if (res.statusCode == 200) {
      return Map<String, dynamic>.from(res.data);
    }

    throw ServerException();
  }

  @override
  Future<void> saveUserData(
    Map<String, dynamic> userModel, {
    File? profilePhoto,
    File? bannerPhoto,
  }) async {
    Map<String, dynamic> requestBody = {};
    requestBody.addAll(userModel);

    if (profilePhoto != null) {
      requestBody['profilePhoto'] = MultipartFile.fromFileSync(
        profilePhoto.path,
      );
    }

    if (bannerPhoto != null) {
      requestBody['bannerPhoto'] = MultipartFile.fromFileSync(
        bannerPhoto.path,
      );
    }

    final formData = FormData.fromMap(requestBody);

    final Response res = await _dio.post(
      Endpoints.saveUser,
      data: formData,
    );

    if (res.statusCode == 200) {
      return res.data;
    }

    throw ServerException();
  }

  @override
  Future<List<Map<String, dynamic>>> searchUserByName(String name) async {
    final Response res = await _dio.get(
      Endpoints.searchUsers(name),
    );

    if (res.statusCode == 200) {
      return List<Map<String, dynamic>>.from(res.data);
    }

    throw ServerException();
  }
}
