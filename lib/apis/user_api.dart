import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/apis/datasource/user_datasource.dart';
import 'package:twitter_clone/core/core.dart';
import 'package:twitter_clone/core/error/handler.dart';
import 'package:twitter_clone/core/networking/urls.dart';
import 'package:twitter_clone/core/providers.dart';
import 'package:twitter_clone/models/user_model.dart';
import 'package:web_socket_channel/io.dart';

final userAPIProvider = Provider(
  (ref) {
    final userDatasource = ref.watch(userDatasourceProvider);
    return UserAPI(
      userDatasource: userDatasource,
      userWebSocket: ref.watch(websocketProvider(Endpoints.userWebsocket)),
    );
  },
);

abstract class IUserAPI {
  FutureEitherVoid saveUserData({
    required int id,
    required Map<String, dynamic> userMap,
    File? profilePhoto,
    File? bannerPhoto,
  });
  FutureEither<UserModel> getUserData(int id);
  FutureEither<List<UserModel>> searchUserByName(String name);
  Stream<Map<String, dynamic>> getLatestUserProfileData();
}

class UserAPI implements IUserAPI {
  final UserDatasource _userDatasource;
  final IOWebSocketChannel _userWebSocket;

  UserAPI({
    required UserDatasource userDatasource,
    required IOWebSocketChannel userWebSocket,
  })  : _userDatasource = userDatasource,
        _userWebSocket = userWebSocket;

  @override
  FutureEither<UserModel> getUserData(int id) async {
    return await handleError(() async {
      Map<String, dynamic> userMap = await _userDatasource.getUserData(id);
      return UserModel.fromMap(userMap);
    });
  }

  @override
  Stream<Map<String, dynamic>> getLatestUserProfileData() {
    return _userWebSocket.stream.map((event) => event == "connected"
        ? {}
        : Map<String, dynamic>.from(jsonDecode(event)));
  }

  @override
  FutureEitherVoid saveUserData({
    required int id,
    required Map<String, dynamic> userMap,
    File? profilePhoto,
    File? bannerPhoto,
  }) async {
    return await handleError(() async {
      await _userDatasource.updateUser(
        id: id,
        userMap: userMap,
        profilePhoto: profilePhoto,
        bannerPhoto: bannerPhoto,
      );
    });
  }

  @override
  FutureEither<List<UserModel>> searchUserByName(String name) async {
    return await handleError(() async {
      List<Map<String, dynamic>> userMap =
          await _userDatasource.searchUserByName(name);
      return userMap.map((e) => UserModel.fromMap(e)).toList();
    });
  }
}
