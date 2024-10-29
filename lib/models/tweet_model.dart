import 'package:flutter/foundation.dart';
import 'package:twitter_clone/core/enums/tweet_type_enum.dart';
import 'package:twitter_clone/models/user_model.dart';

@immutable
class Tweet {
  final int id;
  final UserModel user;
  final String text;
  final List<String> hashtags;
  final String link;
  final List<String> imageLinks;
  final TweetType tweetType;
  final DateTime tweetedAt;
  final List<int> likes;
  final List<int> commentIds;
  final int reshareCount;
  final String? retweetedBy;
  final int? repliedTo;
  const Tweet({
    required this.id,
    required this.text,
    required this.hashtags,
    required this.link,
    required this.imageLinks,
    required this.user,
    required this.tweetType,
    required this.tweetedAt,
    required this.likes,
    required this.commentIds,
    required this.reshareCount,
    this.retweetedBy,
    this.repliedTo,
  });

  Tweet copyWith({
    String? text,
    List<String>? hashtags,
    String? link,
    List<String>? imageLinks,
    UserModel? user,
    TweetType? tweetType,
    DateTime? tweetedAt,
    List<int>? likes,
    List<int>? commentIds,
    int? reshareCount,
    String? retweetedBy,
    int? repliedTo,
  }) {
    return Tweet(
      text: text ?? this.text,
      hashtags: hashtags ?? this.hashtags,
      link: link ?? this.link,
      imageLinks: imageLinks ?? this.imageLinks,
      user: user ?? this.user,
      tweetType: tweetType ?? this.tweetType,
      tweetedAt: tweetedAt ?? this.tweetedAt,
      likes: likes ?? this.likes,
      commentIds: commentIds ?? this.commentIds,
      id: id,
      reshareCount: reshareCount ?? this.reshareCount,
      retweetedBy: retweetedBy ?? this.retweetedBy,
      repliedTo: repliedTo ?? this.repliedTo,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'text': text});
    result.addAll({'hashtags': hashtags});
    result.addAll({'link': link});
    result.addAll({'imageLinks': imageLinks});
    result.addAll({'user': user});
    result.addAll({'tweetType': tweetType.type});
    result.addAll({'tweetedAt': tweetedAt.millisecondsSinceEpoch});
    result.addAll({'likes': likes});
    result.addAll({'commentIds': commentIds});
    result.addAll({'reshareCount': reshareCount});
    result.addAll({'retweetedBy': retweetedBy});
    result.addAll({'repliedTo': repliedTo});

    return result;
  }

  factory Tweet.fromMap(Map<String, dynamic> map) {
    return Tweet(
      text: map['text'] ?? '',
      hashtags:
          map['hashtags'] != null ? List<String>.from(map['hashtags']) : [],
      link: map['link'] ?? '',
      imageLinks:
          map['imageLinks'] != null ? List<String>.from(map['imageLinks']) : [],
      user: UserModel.fromMap(map['user']),
      tweetType: (map['tweetType'] as String).toTweetTypeEnum(),
      tweetedAt: DateTime.parse(map['tweetedAt']),
      likes: List<int>.from(map['likes']),
      commentIds: List<int>.from(map['commentIds']),
      id: map['id'] ?? '',
      reshareCount: map['reshareCount']?.toInt() ?? 0,
      retweetedBy: map['retweetedBy'],
      repliedTo: map['repliedTo'],
    );
  }

  @override
  String toString() {
    return 'Tweet(text: $text, hashtags: $hashtags, link: $link, imageLinks: $imageLinks, user: $user, tweetType: $tweetType, tweetedAt: $tweetedAt, likes: $likes, commentIds: $commentIds, id: $id, reshareCount: $reshareCount, retweetedBy: $retweetedBy, repliedTo: $repliedTo)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Tweet &&
        other.text == text &&
        listEquals(other.hashtags, hashtags) &&
        other.link == link &&
        listEquals(other.imageLinks, imageLinks) &&
        other.user == user &&
        other.tweetType == tweetType &&
        other.tweetedAt == tweetedAt &&
        listEquals(other.likes, likes) &&
        listEquals(other.commentIds, commentIds) &&
        other.id == id &&
        other.reshareCount == reshareCount &&
        other.retweetedBy == retweetedBy &&
        other.repliedTo == repliedTo;
  }

  @override
  int get hashCode {
    return text.hashCode ^
        hashtags.hashCode ^
        link.hashCode ^
        imageLinks.hashCode ^
        user.hashCode ^
        tweetType.hashCode ^
        tweetedAt.hashCode ^
        likes.hashCode ^
        commentIds.hashCode ^
        id.hashCode ^
        reshareCount.hashCode ^
        retweetedBy.hashCode ^
        repliedTo.hashCode;
  }
}
