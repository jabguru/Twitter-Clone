import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/apis/user_api.dart';
import 'package:twitter_clone/constants/global_variables.dart';
import 'package:twitter_clone/core/error/handler.dart';
import 'package:twitter_clone/core/utils.dart';
import 'package:twitter_clone/models/user_model.dart';

final exploreControllerProvider = StateNotifierProvider((ref) {
  return ExploreController(
    userAPI: ref.watch(userAPIProvider),
  );
});

final searchUserProvider = FutureProvider.family((ref, String name) async {
  final exploreController = ref.watch(exploreControllerProvider.notifier);
  return exploreController.searchUser(name);
});

class ExploreController extends StateNotifier<bool> {
  final UserAPI _userAPI;
  ExploreController({
    required UserAPI userAPI,
  })  : _userAPI = userAPI,
        super(false);

  Future<List<UserModel>> searchUser(String name) async {
    final users = await _userAPI.searchUserByName(name);
    return users.fold((l) {
      showSnackBar(
          GlobalVariables.navigatorKey.currentContext!, getFailureMessage(l));
      return [];
    }, (r) => r);
  }
}
