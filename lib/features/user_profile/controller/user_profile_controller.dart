import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/apis/tweet_api.dart';
import 'package:twitter_clone/apis/user_api.dart';
import 'package:twitter_clone/constants/global_variables.dart';
import 'package:twitter_clone/core/enums/notification_type_enum.dart';
import 'package:twitter_clone/core/error/handler.dart';
import 'package:twitter_clone/core/utils.dart';
import 'package:twitter_clone/features/notifications/controller/notification_controller.dart';
import 'package:twitter_clone/models/tweet_model.dart';
import 'package:twitter_clone/models/user_model.dart';

final userProfileControllerProvider =
    StateNotifierProvider<UserProfileController, bool>((ref) {
  return UserProfileController(
    tweetAPI: ref.watch(tweetAPIProvider),
    // storageAPI: ref.watch(storageAPIProvider),
    userAPI: ref.watch(userAPIProvider),
    notificationController: ref.watch(notificationControllerProvider.notifier),
  );
});

final getUserTweetsProvider = FutureProvider.family((ref, int uid) async {
  final userProfileController =
      ref.watch(userProfileControllerProvider.notifier);
  return userProfileController.getUserTweets(uid);
});

final getLatestUserProfileDataProvider = StreamProvider((ref) {
  final userAPI = ref.watch(userAPIProvider);
  // return userAPI.getLatestUserProfileData();
  // TODO: FIX
  return Stream.value(null);
});

class UserProfileController extends StateNotifier<bool> {
  final TweetAPI _tweetAPI;
  final UserAPI _userAPI;
  final NotificationController _notificationController;
  UserProfileController({
    required TweetAPI tweetAPI,
    required UserAPI userAPI,
    required NotificationController notificationController,
  })  : _tweetAPI = tweetAPI,
        _userAPI = userAPI,
        _notificationController = notificationController,
        super(false);

  Future<List<Tweet>> getUserTweets(int uid) async {
    final tweets = await _tweetAPI.getUserTweets(uid);
    return tweets.fold(
      (l) {
        showSnackBar(
            GlobalVariables.navigatorKey.currentContext!, getFailureMessage(l));
        return [];
      },
      (r) => r,
    );
  }

  void updateUserProfile({
    required UserModel userModel,
    required BuildContext context,
    required File? bannerFile,
    required File? profileFile,
  }) async {
    state = true;
    final res = await _userAPI.saveUserData(
      userModel,
      profilePhoto: profileFile,
      bannerPhoto: bannerFile,
    );
    state = false;
    res.fold(
      (l) => showSnackBar(context, getFailureMessage(l)),
      (r) => Navigator.pop(context),
    );
  }

  void followUser({
    required UserModel user,
    required BuildContext context,
    required UserModel currentUser,
  }) async {
    // already following
    if (currentUser.following.contains(user.id)) {
      user.followers.remove(currentUser.id);
      currentUser.following.remove(user.id);
    } else {
      user.followers.add(currentUser.id);
      currentUser.following.add(user.id);
    }

    user = user.copyWith(followers: user.followers);
    currentUser = currentUser.copyWith(
      following: currentUser.following,
    );

    final res = await _userAPI.saveUserData(user);
    res.fold((l) => showSnackBar(context, getFailureMessage(l)), (r) async {
      final res2 = await _userAPI.saveUserData(currentUser);
      res2.fold((l) => showSnackBar(context, getFailureMessage(l)), (r) {
        _notificationController.createNotification(
          text: '${currentUser.name} followed you!',
          postId: null,
          notificationType: NotificationType.follow,
          uid: user.id,
        );
      });
    });
  }
}
