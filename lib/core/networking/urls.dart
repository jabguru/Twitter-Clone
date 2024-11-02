import 'dart:io';

class Endpoints {
  static String endpoint =
      Platform.isAndroid ? '172.20.10.3:8080' : 'localhost:8080';
  static String baseUrl = 'http://$endpoint/api/v1';

  // ? AUTH
  static String login = '$baseUrl/auth/login';
  static String register = '$baseUrl/auth/register';
  static String refreshToken = '$baseUrl/refreshToken';

  // ? USER
  static String updateUser(int id) => '$baseUrl/users/update/$id';
  static String getUser(int id) => '$baseUrl/users/$id';
  static String searchUsers = '$baseUrl/users/search';

  // ? TWEETS
  static String tweetBase = '$baseUrl/tweets';
  static String shareTweet = '$tweetBase/share';
  static String tweetWebsocket = "ws://$endpoint/tweets";
  // ignore: unnecessary_string_interpolations
  static String getTweets = '$tweetBase';
  static String updateTweet(int id) => '$tweetBase/update/$id';
  static String getRepliesToTweet(int id) => '$tweetBase/replies/$id';
  static String getTweetById(int id) => '$tweetBase/$id';
  static String getUserTweets(int userId) => '$tweetBase/user/$userId';
  static String getTweetsByHashtag = '$tweetBase/hashtag';

  // ? NOTIFICATIONS
  static String notificationBase = '$baseUrl/notifications';
  static String createNotification = '$notificationBase/create';
  static String getNotifications(int userId) =>
      '$notificationBase/user/$userId';

  static String getImageUrl(String imageName) =>
      'http://$endpoint/images/$imageName';
}
