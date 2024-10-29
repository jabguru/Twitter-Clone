import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/core/error/exceptions.dart';
import 'package:twitter_clone/core/networking/urls.dart';
import 'package:twitter_clone/core/providers.dart';

final notificationDatasourceProvider = Provider((ref) {
  final dio = ref.watch(dioProvider);
  return NotificationDatasource(dio: dio);
});

abstract class INotificationDatasource {
  Future<void> createNotification(Map<String, dynamic> notification);
  Future<List<Map<String, dynamic>>> getNotifications(int uid);
  // Stream<RealtimeMessage> getLatestNotification();
}

class NotificationDatasource implements INotificationDatasource {
  final Dio _dio;

  NotificationDatasource({
    required Dio dio,
  }) : _dio = dio;

  @override
  Future<void> createNotification(Map<String, dynamic> notification) async {
    final Response res = await _dio.post(
      Endpoints.createNotification,
      data: notification,
    );

    if (res.statusCode == 201) {
      return res.data;
    }

    throw ServerException();
  }

  @override
  Future<List<Map<String, dynamic>>> getNotifications(int uid) async {
    final Response res = await _dio.get(
      Endpoints.getNotifications(uid),
    );

    if (res.statusCode == 200) {
      return List<Map<String, dynamic>>.from(res.data);
    }

    throw ServerException();
  }
}
