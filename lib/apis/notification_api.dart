import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/apis/datasource/notification_datasource.dart';
import 'package:twitter_clone/core/core.dart';
import 'package:twitter_clone/core/error/handler.dart';
import 'package:twitter_clone/core/networking/urls.dart';
import 'package:twitter_clone/core/providers.dart';
import 'package:twitter_clone/models/notification_model.dart';
import 'package:web_socket_channel/io.dart';

final notificationAPIProvider = Provider((ref) {
  return NotificationAPI(
    notificationDatasource: ref.watch(notificationDatasourceProvider),
    notificationWebSocket:
        ref.watch(websocketProvider(Endpoints.notificationWebsocket)),
  );
});

abstract class INotificationAPI {
  FutureEitherVoid createNotification(
      Map<String, dynamic> notification, int userId);
  FutureEither<List<Notification>> getNotifications(int uid);
  Stream<Map<String, dynamic>> getLatestNotification();
}

class NotificationAPI implements INotificationAPI {
  final NotificationDatasource _notificationDatasource;
  final IOWebSocketChannel _notificationWebSocket;
  NotificationAPI(
      {required NotificationDatasource notificationDatasource,
      required IOWebSocketChannel notificationWebSocket})
      : _notificationDatasource = notificationDatasource,
        _notificationWebSocket = notificationWebSocket;

  @override
  FutureEitherVoid createNotification(
      Map<String, dynamic> notification, int userId) async {
    return await handleError(() async {
      await _notificationDatasource.createNotification(notification, userId);
    });
  }

  @override
  FutureEither<List<Notification>> getNotifications(int uid) async {
    return await handleError(() async {
      List<Map<String, dynamic>> tweets =
          await _notificationDatasource.getNotifications(uid);
      return tweets.map((e) => Notification.fromMap(e)).toList();
    });
  }

  @override
  Stream<Map<String, dynamic>> getLatestNotification() {
    return _notificationWebSocket.stream.map((event) => event == "connected"
        ? {}
        : Map<String, dynamic>.from(jsonDecode(event)));
  }
}
