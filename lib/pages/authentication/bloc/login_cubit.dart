import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:food_delivery/domains/authentication_respository/authentication_respository.dart';

import '../../../domains/data_source/firebase_auth_service.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthenticationRepository _authRepo;

  LoginCubit({ required AuthenticationRepository authenticationRepository })
      : _authRepo = authenticationRepository,
        super(const LoginInitial());

  Future<void> login(String email, String password) async {
    emit(const LoginLoading());
    try {
      print("DO login Cubit");
      final AuthResult result = await _authRepo
          .loginWithEmailAndPassword(email: email, password: password);
      // emit success with role & store
      emit(LoginSuccess(result.roleName, result.storeId));
    } catch (e) {
      emit(LoginFailure(e.toString()));
    }
  }
}
