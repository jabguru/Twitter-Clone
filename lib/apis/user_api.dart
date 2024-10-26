import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/apis/datasource/user_datasource.dart';
import 'package:twitter_clone/core/core.dart';
import 'package:twitter_clone/core/error/handler.dart';
import 'package:twitter_clone/models/user_model.dart';

final userAPIProvider = Provider(
  (ref) {
    final userDatasource = ref.watch(userDatasourceProvider);
    return UserAPI(
      userDatasource: userDatasource,
    );
  },
);

abstract class IUserAPI {
  FutureEitherVoid saveUserData(UserModel userModel);
  FutureEither<UserModel> getUserData(int id);
  FutureEither<List<UserModel>> searchUserByName(String name);
  // Stream<RealtimeMessage> getLatestUserProfileData();
}

class UserAPI implements IUserAPI {
  final UserDatasource _userDatasource;

  UserAPI({
    required UserDatasource userDatasource,
  }) : _userDatasource = userDatasource;

  @override
  FutureEither<UserModel> getUserData(int id) async {
    return await handleError(() async {
      Map<String, dynamic> userMap = await _userDatasource.getUserData(id);
      return UserModel.fromMap(userMap);
    });
  }

  @override
  FutureEitherVoid saveUserData(UserModel userModel) async {
    return await handleError(() async {
      await _userDatasource.saveUserData(userModel.toMap());
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
