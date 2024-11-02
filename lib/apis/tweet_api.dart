import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/apis/datasource/tweet_datasource.dart';
import 'package:twitter_clone/core/core.dart';
import 'package:twitter_clone/core/error/handler.dart';
import 'package:twitter_clone/core/networking/urls.dart';
import 'package:twitter_clone/core/providers.dart';
import 'package:twitter_clone/models/tweet_model.dart';
import 'package:web_socket_channel/io.dart';

final tweetAPIProvider = Provider((ref) {
  return TweetAPI(
    tweetDatasource: ref.watch(tweetDatasourceProvider),
    tweetWebSocket: ref.watch(websocketProvider(Endpoints.tweetWebsocket)),
  );
});

abstract class ITweetAPI {
  FutureEitherVoid shareTweet({
    required int userId,
    required Map<String, dynamic> tweet,
    List<File>? images,
  });
  FutureEither<List<Tweet>> getTweets();
  Stream<Map<String, dynamic>> getLatestTweet();
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
  final IOWebSocketChannel _tweetWebSocket;

  TweetAPI(
      {required TweetDatasource tweetDatasource,
      required IOWebSocketChannel tweetWebSocket})
      : _tweetDatasource = tweetDatasource,
        _tweetWebSocket = tweetWebSocket;

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

  @override
  Stream<Map<String, dynamic>> getLatestTweet() {
    return _tweetWebSocket.stream.map((event) => event == "connected"
        ? {}
        : Map<String, dynamic>.from(jsonDecode(event)));
  }

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
