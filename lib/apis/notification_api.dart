import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/apis/datasource/notification_datasource.dart';
import 'package:twitter_clone/core/core.dart';
import 'package:twitter_clone/core/error/handler.dart';
import 'package:twitter_clone/models/notification_model.dart';

final notificationAPIProvider = Provider((ref) {
  return NotificationAPI(
    notificationDatasource: ref.watch(notificationDatasourceProvider),
  );
});

abstract class INotificationAPI {
  FutureEitherVoid createNotification(
      Map<String, dynamic> notification, int userId);
  FutureEither<List<Notification>> getNotifications(int uid);
  // Stream<RealtimeMessage> getLatestNotification();
}

class NotificationAPI implements INotificationAPI {
  final NotificationDatasource _notificationDatasource;
  NotificationAPI({required NotificationDatasource notificationDatasource})
      : _notificationDatasource = notificationDatasource;

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

  // @override
  // Stream<RealtimeMessage> getLatestNotification() {
  //   return _realtime.subscribe([
  //     'databases.${AppwriteConstants.databaseId}.collections.${AppwriteConstants.notificationsCollectionId}.documents'
  //   ]).stream;
  // }
}
