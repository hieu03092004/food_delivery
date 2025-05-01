//giao tiep voi data nhan input dau vao tu block
import 'package:food_delivery/domains/data_source/firebase_auth_service.dart';

abstract class AuthenticationRepository {
  Future<AuthResult> loginWithEmailAndPassword({
    required String email,
    required String password,
  });
}
class AuthenticationRepositoryImpl implements AuthenticationRepository {
  final FireBaseAuthService _service;
  AuthenticationRepositoryImpl(this._service);

  @override
  Future<AuthResult> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return _service.loginWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
}