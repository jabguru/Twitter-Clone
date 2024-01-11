class AppwriteConstants {
  static const String databaseId = '6589423a60bd6209c46e';
  static const String projectId = '65893f5b9787f543bda3';
  static const String endPoint = 'http://172.20.10.5:80/v1';

  static const String usersCollectionId = '658c2f90aad9966421cf';
  static const String tweetsCollectionId = '6599dfa9e1d5ecea3045';
  static const String notificationsCollectionId = '65a03494cd11b3aeb75b';

  static const String imagesBucket = '659ac60bc078f75d59f3';
  static String imageUrl(String imageId) =>
      '$endPoint/storage/buckets/$imagesBucket/files/$imageId/view?project=$projectId&mode=admin';
}
