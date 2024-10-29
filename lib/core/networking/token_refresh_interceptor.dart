import 'dart:async';

import 'package:dio/dio.dart';
import 'package:synchronized/synchronized.dart';
import 'package:twitter_clone/apis/app_storage.dart';
import 'package:twitter_clone/core/networking/urls.dart';

class TokenInterceptor extends QueuedInterceptorsWrapper {
  final AppStorage appStorage;

  TokenInterceptor({
    required this.appStorage,
  });

  final Dio dio = Dio();
  final Lock _lock = Lock();

  String? _accessToken;
  String? _refreshToken;

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    if (_accessToken == null && _refreshToken == null) {
      String? accessToken = await appStorage.getAccessToken();
      String? refreshToken = await appStorage.getRefreshToken();
      if (accessToken != null && refreshToken != null) {
        _accessToken = accessToken;
        _refreshToken = refreshToken;
      }
    }

    // Add the current access token to the request
    if (_accessToken != null) {
      options.headers['Authorization'] = 'Bearer $_accessToken';
    }
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Token has expired, refresh it
      try {
        await _lock.synchronized(() async {
          if (err.requestOptions.headers['Authorization'] !=
              'Bearer $_accessToken') {
            // Token has already been refreshed by another request
            return handler.resolve(await dio.fetch(err.requestOptions
              ..headers['Authorization'] = 'Bearer $_accessToken'));
          }

          // Perform token refresh
          final Map<String, dynamic>? newTokens = await _onRefreshToken();
          if (newTokens != null) {
            _accessToken = newTokens['accessToken'];
            _refreshToken = newTokens['refreshToken'];
            // Retry the original request with the new token
            err.requestOptions.headers['Authorization'] =
                'Bearer $_accessToken';
            return handler.resolve(await dio.fetch(err.requestOptions));
          } else {
            // If refresh fails, propagate the error
            return handler.next(err);
          }
        });
      } catch (e) {
        // If refresh fails, propagate the error
        return handler.next(err);
      }
    } else {
      // ? if else is taken away, it calls the handler again and throws error
      return handler.next(err);
    }
  }

  Future<Map<String, dynamic>?> _onRefreshToken() async {
    try {
      final Response res = await dio.post(
        Endpoints.refreshToken,
        data: {
          'refreshToken': _refreshToken,
        },
      );

      if (res.statusCode == 200) {
        return res.data;
      }
    } catch (e) {
      // TODO: ERROR OCCURS WHEN REFRESH TOKEN HAS EXPIRED. LOG THE USER OUT AND REDIRECT TO LOGIN SCREEN
      print("Error on refresh token: $e");
    }

    return null;
  }
}
