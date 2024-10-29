import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:twitter_clone/apis/app_storage.dart';
import 'package:twitter_clone/core/networking/custom_dio_logger.dart';
import 'package:twitter_clone/core/networking/token_refresh_interceptor.dart';

final storageProvider = Provider((ref) {
  FlutterSecureStorage secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  return AppStorage(secureStorage: secureStorage);
});

final dioProvider = Provider((ref) {
  Dio dio = Dio();
  dio.interceptors.add(
    TokenInterceptor(
      appStorage: ref.watch(storageProvider),
    ),
  );
  dio.interceptors.add(DioLogger());
  return dio;
});
