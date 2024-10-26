import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:twitter_clone/core/error/failure.dart';

Future<Either<Failure, T>> handleError<T>(Future<T> Function() process) async {
  try {
    final result = await process();
    return right(result);
  } on TimeoutException {
    return left(ServerFailure());
  } on SocketException {
    return left(NetworkFailure());
  } on DioException catch (e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return left(NetworkFailure());
    }
    return left(ServerFailure());
  }
}
