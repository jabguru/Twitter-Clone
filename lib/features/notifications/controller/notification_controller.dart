import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/apis/notification_api.dart';
import 'package:twitter_clone/constants/global_variables.dart';
import 'package:twitter_clone/core/enums/notification_type_enum.dart';
import 'package:twitter_clone/core/error/handler.dart';
import 'package:twitter_clone/core/utils.dart';
import 'package:twitter_clone/models/notification_model.dart';

final notificationControllerProvider =
    StateNotifierProvider<NotificationController, bool>((ref) {
  return NotificationController(
    notificationAPI: ref.watch(notificationAPIProvider),
  );
});

final getLatestNotificationProvider = StreamProvider((ref) {
  final notificationAPI = ref.watch(notificationAPIProvider);
  return notificationAPI.getLatestNotification();
});

final getNotificationsProvider = FutureProvider.family((ref, int uid) async {
  final notificationController =
      ref.watch(notificationControllerProvider.notifier);
  return notificationController.getNotifications(uid);
});

class NotificationController extends StateNotifier<bool> {
  final NotificationAPI _notificationAPI;
  NotificationController({required NotificationAPI notificationAPI})
      : _notificationAPI = notificationAPI,
        super(false);

  void createNotification({
    required String text,
    required int? postId,
    required NotificationType notificationType,
    required int uid,
  }) async {
    final Map<String, dynamic> notificationMap = {
      'text': text,
      'postId': postId,
      'notificationType': notificationType.type,
    };
    final res = await _notificationAPI.createNotification(notificationMap, uid);
    res.fold((l) => null, (r) => null);
  }

  Future<List<Notification>> getNotifications(int uid) async {
    final notifications = await _notificationAPI.getNotifications(uid);
    return notifications.fold((l) {
      showSnackBar(
          GlobalVariables.navigatorKey.currentContext!, getFailureMessage(l));
      return [];
    }, (r) => r);
  }
}
