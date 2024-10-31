import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/apis/datasource/tweet_datasource.dart';
import 'package:twitter_clone/core/core.dart';
import 'package:twitter_clone/core/error/handler.dart';
import 'package:twitter_clone/models/tweet_model.dart';

final tweetAPIProvider = Provider((ref) {
  return TweetAPI(
    tweetDatasource: ref.watch(tweetDatasourceProvider),
  );
});

abstract class ITweetAPI {
  FutureEitherVoid shareTweet({
    required int userId,
    required Map<String, dynamic> tweet,
    List<File>? images,
  });
  FutureEither<List<Tweet>> getTweets();
  // Stream<RealtimeMessage> getLatestTweet();
  FutureEitherVoid updateTweet(
    int id, {
    required Map<String, dynamic> data,
  });
  FutureEither<List<Tweet>> getRepliesToTweet(int id);
  FutureEither<Tweet> getTweetById(int id);
  FutureEither<List<Tweet>> getUserTweets(int uid);
  FutureEither<List<Tweet>> getTweetsByHashtag(String hashtag);
}

class TweetAPI implements ITweetAPI {
  final TweetDatasource _tweetDatasource;

  TweetAPI({required TweetDatasource tweetDatasource})
      : _tweetDatasource = tweetDatasource;

  @override
  FutureEither<Tweet> shareTweet({
    required int userId,
    required Map<String, dynamic> tweet,
    List<File>? images,
  }) async {
    return await handleError(() async {
      Map<String, dynamic> tweetMap = await _tweetDatasource.shareTweet(
        userId: userId,
        tweet: tweet,
        images: images,
      );
      return Tweet.fromMap(tweetMap);
    });
  }

  @override
  FutureEither<List<Tweet>> getTweets() async {
    return await handleError(() async {
      List<Map<String, dynamic>> tweets = await _tweetDatasource.getTweets();
      return tweets.map((e) => Tweet.fromMap(e)).toList();
    });
  }

  // @override
  // Stream<RealtimeMessage> getLatestTweet() {
  //   return _realtime.subscribe([
  //     'databases.${AppwriteConstants.databaseId}.collections.${AppwriteConstants.tweetsCollectionId}.documents'
  //   ]).stream;
  // }

  @override
  FutureEitherVoid updateTweet(
    int id, {
    required Map<String, dynamic> data,
  }) async {
    return await handleError(() async {
      await _tweetDatasource.updateTweet(id, data: data);
    });
  }

  @override
  FutureEither<List<Tweet>> getRepliesToTweet(int id) async {
    return await handleError(() async {
      List<Map<String, dynamic>> tweets =
          await _tweetDatasource.getRepliesToTweet(id);
      return tweets.map((e) => Tweet.fromMap(e)).toList();
    });
  }

  @override
  FutureEither<Tweet> getTweetById(int id) async {
    return await handleError(() async {
      Map<String, dynamic> tweetMap = await _tweetDatasource.getTweetById(id);
      return Tweet.fromMap(tweetMap);
    });
  }

  @override
  FutureEither<List<Tweet>> getUserTweets(int uid) async {
    return await handleError(() async {
      List<Map<String, dynamic>> tweets =
          await _tweetDatasource.getUserTweets(uid);
      return tweets.map((e) => Tweet.fromMap(e)).toList();
    });
  }

  @override
  FutureEither<List<Tweet>> getTweetsByHashtag(String hashtag) async {
    return await handleError(() async {
      List<Map<String, dynamic>> tweets =
          await _tweetDatasource.getTweetsByHashtag(hashtag);
      return tweets.map((e) => Tweet.fromMap(e)).toList();
    });
  }
}
