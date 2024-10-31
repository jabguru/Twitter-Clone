import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/apis/tweet_api.dart';
import 'package:twitter_clone/constants/global_variables.dart';
import 'package:twitter_clone/core/enums/notification_type_enum.dart';
import 'package:twitter_clone/core/enums/tweet_type_enum.dart';
import 'package:twitter_clone/core/error/handler.dart';
import 'package:twitter_clone/core/utils.dart';
import 'package:twitter_clone/features/auth/controller/auth_controller.dart';
import 'package:twitter_clone/features/notifications/controller/notification_controller.dart';
import 'package:twitter_clone/models/tweet_model.dart';
import 'package:twitter_clone/models/user_model.dart';

final tweetControllerProvider =
    StateNotifierProvider<TweetController, bool>((ref) {
  return TweetController(
    ref: ref,
    tweetAPI: ref.watch(tweetAPIProvider),
    notificationController: ref.watch(notificationControllerProvider.notifier),
  );
});

final getTweetsProvider = FutureProvider((ref) {
  final tweetController = ref.watch(tweetControllerProvider.notifier);
  return tweetController.getTweets();
});

final getLatestTweetProvider = StreamProvider((ref) {
  final tweetAPI = ref.watch(tweetAPIProvider);
  // return tweetAPI.getLatestTweet();
  // TODO: FIX
  return Stream.value(null);
});

final getRepliesToTweetsProvider = FutureProvider.family((ref, Tweet tweet) {
  final tweetController = ref.watch(tweetControllerProvider.notifier);
  return tweetController.getRepliesToTweet(tweet.id);
});

final getTweetByIdProvider = FutureProvider.family((ref, int id) async {
  final tweetController = ref.watch(tweetControllerProvider.notifier);
  return tweetController.getTweetById(id);
});

final getTweetsByHashtagProvider = FutureProvider.family((ref, String hashtag) {
  final tweetController = ref.watch(tweetControllerProvider.notifier);
  return tweetController.getTweetsByHashtag(hashtag);
});

class TweetController extends StateNotifier<bool> {
  final Ref _ref;
  final TweetAPI _tweetAPI;
  final NotificationController _notificationController;
  TweetController({
    required Ref ref,
    required TweetAPI tweetAPI,
    required NotificationController notificationController,
  })  : _ref = ref,
        _tweetAPI = tweetAPI,
        _notificationController = notificationController,
        super(false);

  Future<List<Tweet>> getTweets() async {
    final tweetList = await _tweetAPI.getTweets();
    return tweetList.fold(
      (l) {
        showSnackBar(
            GlobalVariables.navigatorKey.currentContext!, getFailureMessage(l));
        return [];
      },
      (r) => r,
    );
  }

  void shareTweet({
    required List<File> images,
    required String text,
    required BuildContext context,
    int? repliedTo,
    int? repliedToUserId,
  }) {
    if (text.isEmpty) {
      showSnackBar(context, 'Please enter  text');
      return;
    }

    if (images.isNotEmpty) {
      _shareImageTweet(
        images: images,
        text: text,
        context: context,
        repliedTo: repliedTo,
        repliedToUserId: repliedToUserId,
      );
    } else {
      _shareTextTweet(
        text: text,
        context: context,
        repliedTo: repliedTo,
        repliedToUserId: repliedToUserId,
      );
    }
  }

  void _shareImageTweet({
    required List<File> images,
    required String text,
    required BuildContext context,
    required int? repliedTo,
    required int? repliedToUserId,
  }) async {
    state = true;
    final hashtags = _getHashTagsFromText(text);
    String link = _getLinkFromText(text);
    final user = _ref.read(currentUserDetailsProvider).value!;

    Map<String, dynamic> tweetMap = {
      "text": text,
      "hashtags": hashtags,
      "link": link,
      "tweetType": TweetType.image.type,
    };

    if (repliedTo != null) {
      tweetMap['repliedTo'] = repliedTo;
    }

    final res = await _tweetAPI.shareTweet(
      userId: user.id,
      tweet: tweetMap,
      images: images,
    );

    res.fold(
      (l) {
        state = false;
        showSnackBar(context, getFailureMessage(l));
      },
      (r) async {
        if (repliedToUserId != null && repliedTo != null) {
          Tweet? tweetRepliedTo = await getTweetById(repliedTo);
          if (tweetRepliedTo != null) {
            updateTweetCommentsId(tweetRepliedTo, r.id);
            _notificationController.createNotification(
              text: '${user.name} replied to your tweet!',
              postId: r.id,
              notificationType: NotificationType.reply,
              uid: repliedToUserId,
            );
          }
        }
      },
    );
    state = false;
  }

  void _shareTextTweet({
    required String text,
    required BuildContext context,
    required int? repliedTo,
    required int? repliedToUserId,
  }) async {
    state = true;
    final hashtags = _getHashTagsFromText(text);
    String link = _getLinkFromText(text);
    final user = _ref.read(currentUserDetailsProvider).value!;

    Map<String, dynamic> tweetMap = {
      "text": text,
      "hashtags": hashtags,
      "link": link,
      "tweetType": TweetType.text.type,
    };

    if (repliedTo != null) {
      tweetMap['repliedTo'] = repliedTo;
    }

    final res = await _tweetAPI.shareTweet(userId: user.id, tweet: tweetMap);
    res.fold(
      (l) {
        state = false;
        showSnackBar(context, getFailureMessage(l));
      },
      (r) async {
        if (repliedToUserId != null && repliedTo != null) {
          Tweet? tweetRepliedTo = await getTweetById(repliedTo);
          if (tweetRepliedTo != null) {
            updateTweetCommentsId(tweetRepliedTo, r.id);
            _notificationController.createNotification(
              text: '${user.name} replied to your tweet!',
              postId: r.id,
              notificationType: NotificationType.reply,
              uid: repliedToUserId,
            );
          }
        }
        state = false;
      },
    );
  }

  String _getLinkFromText(String text) {
    final words = text.split(' ');
    final link = words.firstWhere(
      (element) => element.startsWith('https') || element.startsWith('www'),
      orElse: () => '',
    );
    return link;
  }

  List<String> _getHashTagsFromText(String text) {
    final words = text.split(' ');
    final hashTags = words.where((element) => element.startsWith('#')).toList();
    return hashTags;
  }

  void likeTweet(Tweet tweet, UserModel user) async {
    List<int> likes = tweet.likes;

    if (tweet.likes.contains(user.id)) {
      likes.remove(user.id);
    } else {
      likes.add(user.id);
    }

    tweet = tweet.copyWith(likes: likes);
    final res = await _tweetAPI.updateTweet(
      tweet.id,
      data: {'likes': likes},
    );
    res.fold((l) => null, (r) {
      _notificationController.createNotification(
        text: '${user.name} liked your tweet!',
        postId: tweet.id,
        notificationType: NotificationType.like,
        uid: tweet.user.id,
      );
    });
  }

  void updateTweetCommentsId(
    Tweet tweet,
    int commentId,
  ) async {
    List<int> commentIds = tweet.commentIds;

    if (tweet.commentIds.contains(commentId)) {
      commentIds.remove(commentId);
    } else {
      commentIds.add(commentId);
    }
    tweet = tweet.copyWith(commentIds: commentIds);

    final res = await _tweetAPI.updateTweet(
      tweet.id,
      data: {'commentIds': commentIds},
    );
    res.fold((l) => null, (r) => null);
  }

  void reshareTweet(
    Tweet tweet,
    UserModel currentUser,
    BuildContext context,
  ) async {
    tweet = tweet.copyWith(
      retweetedBy: currentUser.name,
      reshareCount: tweet.reshareCount + 1,
    );

    final res = await _tweetAPI.updateTweet(
      tweet.id,
      data: {'reshareCount': tweet.reshareCount + 1},
    );
    res.fold(
      (l) => showSnackBar(context, getFailureMessage(l)),
      (r) async {
        Map<String, dynamic> newTweetMap = tweet
            .copyWith(
              reshareCount: 0,
              retweetedBy: 'currentUser.name',
            )
            .toMap();
        newTweetMap.remove("id");
        newTweetMap.remove("tweetedAt");
        newTweetMap.remove("user");
        final res2 = await _tweetAPI.shareTweet(
            userId: tweet.user.id, tweet: newTweetMap);
        res2.fold(
          (l) => showSnackBar(context, getFailureMessage(l)),
          (r) {
            _notificationController.createNotification(
              text: '${currentUser.name} reshared your tweet!',
              postId: tweet.id,
              notificationType: NotificationType.retweet,
              uid: tweet.user.id,
            );
            showSnackBar(context, 'Retweeted!');
          },
        );
      },
    );
  }

  Future<List<Tweet>> getRepliesToTweet(int id) async {
    final documents = await _tweetAPI.getRepliesToTweet(id);
    return documents.fold(
      (l) {
        showSnackBar(
            GlobalVariables.navigatorKey.currentContext!, getFailureMessage(l));
        return [];
      },
      (r) => r,
    );
  }

  Future<Tweet?> getTweetById(int id) async {
    final tweet = await _tweetAPI.getTweetById(id);
    return tweet.fold((l) {
      showSnackBar(
          GlobalVariables.navigatorKey.currentContext!, getFailureMessage(l));
      return null;
    }, (r) => r);
  }

  Future<List<Tweet>> getTweetsByHashtag(String hashtag) async {
    final documents = await _tweetAPI.getTweetsByHashtag(hashtag);
    return documents.fold(
      (l) {
        showSnackBar(
            GlobalVariables.navigatorKey.currentContext!, getFailureMessage(l));
        return [];
      },
      (r) => r,
    );
  }
}
