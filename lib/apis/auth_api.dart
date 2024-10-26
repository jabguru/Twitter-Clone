import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:twitter_clone/apis/app_storage.dart';
import 'package:twitter_clone/apis/datasource/auth_datasource.dart';
import 'package:twitter_clone/core/core.dart';
import 'package:twitter_clone/core/error/handler.dart';
import 'package:twitter_clone/core/providers.dart';

final authAPIProvider = Provider(
  (ref) {
    final appStorage = ref.watch(storageProvider);
    final authDatasource = ref.watch(authDatasourceProvider);
    return AuthAPI(
      appStorage: appStorage,
      authDatasource: authDatasource,
    );
  },
);

abstract class IAuthAPI {
  FutureEither<bool> register({
    required String email,
    required String password,
  });
  FutureEither<bool> login({
    required String email,
    required String password,
  });
  // Future<User?> currentUserAccount();
  FutureEitherVoid logout();
}

class AuthAPI implements IAuthAPI {
  final AppStorage _appStorage;
  final AuthDatasource _authDatasource;
  AuthAPI({
    required AppStorage appStorage,
    required AuthDatasource authDatasource,
  })  : _appStorage = appStorage,
        _authDatasource = authDatasource;

  // @override
  // Future<User?> currentUserAccount() async {
  //   try {
  //     return await _account.get();
  //   } on AppwriteException {
  //     return null;
  //   } catch (e) {
  //     return null;
  //   }
  // }

  @override
  FutureEither<bool> login({
    required String email,
    required String password,
  }) async {
    return await handleError(() async {
      Map res = await _authDatasource.login(email: email, password: password);

      // save usertoken
      _appStorage.saveAccessToken(res['accessToken']);
      _appStorage.saveRefreshToken(res['refreshToken']);

      // save userdetails
      _appStorage.saveUser(res['user']);

      return true;
    });
  }

  @override
  FutureEitherVoid logout() async {
    return right(await _authDatasource.logout());
    // try {
    //   await _account.deleteSession(
    //     sessionId: 'current',
    //   );
    //   return right(null);
    // } on AppwriteException catch (e, stackTrace) {
    //   return left(
    //     Failure(e.message ?? 'Some unexpected error occurred', stackTrace),
    //   );
    // } catch (e, stackTrace) {
    //   return left(
    //     Failure(e.toString(), stackTrace),
    //   );
    // }
  }

  @override
  FutureEither<bool> register({
    required String email,
    required String password,
  }) async {
    return await handleError(() async {
      bool res =
          await _authDatasource.register(email: email, password: password);

      return res;
    });
  }
}
