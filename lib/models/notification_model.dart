import 'package:twitter_clone/core/enums/notification_type_enum.dart';
import 'package:twitter_clone/models/user_model.dart';

class Notification {
  final String text;
  final int postId;
  final int id;
  final UserModel user;
  final NotificationType notificationType;
  Notification({
    required this.text,
    required this.postId,
    required this.id,
    required this.user,
    required this.notificationType,
  });

  Notification copyWith({
    String? text,
    int? postId,
    int? id,
    UserModel? user,
    NotificationType? notificationType,
  }) {
    return Notification(
      text: text ?? this.text,
      postId: postId ?? this.postId,
      id: id ?? this.id,
      user: user ?? this.user,
      notificationType: notificationType ?? this.notificationType,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'text': text});
    result.addAll({'postId': postId});
    result.addAll({'user': user});
    result.addAll({'notificationType': notificationType.type});

    return result;
  }

  factory Notification.fromMap(Map<String, dynamic> map) {
    return Notification(
      text: map['text'] ?? '',
      postId: map['postId'] ?? '',
      id: map['id'] ?? '',
      user: UserModel.fromMap(map['user']),
      notificationType:
          (map['notificationType'] as String).toNotificationTypeEnum(),
    );
  }

  @override
  String toString() {
    return 'Notification(text: $text, postId: $postId, id: $id, user: $user, notificationType: $notificationType)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Notification &&
        other.text == text &&
        other.postId == postId &&
        other.id == id &&
        other.user == user &&
        other.notificationType == notificationType;
  }

  @override
  int get hashCode {
    return text.hashCode ^
        postId.hashCode ^
        id.hashCode ^
        user.hashCode ^
        notificationType.hashCode;
  }
}
