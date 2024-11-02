import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/core/error/exceptions.dart';
import 'package:twitter_clone/core/networking/urls.dart';
import 'package:twitter_clone/core/providers.dart';

final tweetDatasourceProvider = Provider((ref) {
  final dio = ref.watch(dioProvider);
  return TweetDatasource(dio: dio);
});

abstract class ITweetDatasource {
  Future<Map<String, dynamic>> shareTweet({
    required int userId,
    required Map<String, dynamic> tweet,
    List<File>? images,
  });
  Future<List<Map<String, dynamic>>> getTweets();
  Future<void> updateTweet(
    int id, {
    required Map<String, dynamic> data,
  });
  Future<List<Map<String, dynamic>>> getRepliesToTweet(int id);
  Future<Map<String, dynamic>> getTweetById(int id);
  Future<List<Map<String, dynamic>>> getUserTweets(int uid);
  Future<List<Map<String, dynamic>>> getTweetsByHashtag(String hashtag);
}

class TweetDatasource implements ITweetDatasource {
  final Dio _dio;

  TweetDatasource({
    required Dio dio,
  }) : _dio = dio;

  @override
  Future<List<Map<String, dynamic>>> getRepliesToTweet(int id) async {
    final Response res = await _dio.get(
      Endpoints.getRepliesToTweet(id),
    );

    if (res.statusCode == 200) {
      return List<Map<String, dynamic>>.from(res.data);
    }

    throw ServerException();
  }

  @override
  Future<Map<String, dynamic>> getTweetById(int id) async {
    final Response res = await _dio.get(
      Endpoints.getTweetById(id),
    );

    if (res.statusCode == 200) {
      return Map<String, dynamic>.from(res.data);
    }

    throw ServerException();
  }

  @override
  Future<List<Map<String, dynamic>>> getTweets() async {
    final Response res = await _dio.get(
      Endpoints.getTweets,
    );

    if (res.statusCode == 200) {
      return List<Map<String, dynamic>>.from(res.data);
    }

    throw ServerException();
  }

  @override
  Future<List<Map<String, dynamic>>> getTweetsByHashtag(String hashtag) async {
    final Response res = await _dio.get(
      Endpoints.getTweetsByHashtag,
      queryParameters: {
        'hashtag': hashtag,
      },
    );

    if (res.statusCode == 200) {
      return List<Map<String, dynamic>>.from(res.data);
    }

    throw ServerException();
  }

  @override
  Future<List<Map<String, dynamic>>> getUserTweets(int uid) async {
    final Response res = await _dio.get(
      Endpoints.getUserTweets(uid),
    );

    if (res.statusCode == 200) {
      return List<Map<String, dynamic>>.from(res.data);
    }

    throw ServerException();
  }

  @override
  Future<Map<String, dynamic>> shareTweet({
    required int userId,
    required Map<String, dynamic> tweet,
    List<File>? images,
  }) async {
    Map<String, dynamic> requestBody = {};
    requestBody.addAll(tweet);
    if (images != null) {
      requestBody['files'] = images
          .map((File image) => MultipartFile.fromFileSync(image.path))
          .toList();
    }
    final formData = FormData.fromMap(requestBody);

    final Response res = await _dio.post(
      Endpoints.shareTweet,
      queryParameters: {
        'userId': userId,
      },
      data: formData,
    );

    if (res.statusCode == 201) {
      return Map<String, dynamic>.from(res.data);
    }

    throw ServerException();
  }

  @override
  Future<void> updateTweet(int id, {required Map<String, dynamic> data}) async {
    final Response res = await _dio.post(
      Endpoints.updateTweet(id),
      data: data,
    );

    if (res.statusCode == 200) {
      return res.data;
    }

    throw ServerException();
  }
}
