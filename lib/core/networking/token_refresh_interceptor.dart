import 'package:dio/dio.dart';
import 'package:synchronized/synchronized.dart';
import 'package:twitter_clone/apis/app_storage.dart';
import 'package:twitter_clone/core/networking/urls.dart';

class TokenRefreshInterceptor extends QueuedInterceptor {
  final Dio dio;
  final AppStorage appStorage;
  final Lock _lock = Lock();
  String? _accessToken;
  String? _refreshToken;

  TokenRefreshInterceptor({
    required this.dio,
    required this.appStorage,
  });

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
    }
    return handler.next(err);
  }

  Future<Map<String, dynamic>?> _onRefreshToken() async {
    final Response res = await dio.post(
      Endpoints.refreshToken,
      data: {
        'token': _refreshToken,
      },
    );

    if (res.statusCode == 200) {
      return res.data;
    }
    return null;
  }
}
