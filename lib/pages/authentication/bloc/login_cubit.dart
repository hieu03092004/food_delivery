import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:food_delivery/domains/authentication_respository/authentication_respository.dart';

import '../../../domains/data_source/firebase_auth_service.dart';
import '../authenticaion_state/authenticationCubit.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthenticationRepository _authRepo;
  final AuthenticationCubit _authCubit; // Thêm dòng này

  LoginCubit({
    required AuthenticationRepository authenticationRepository,
    required AuthenticationCubit authenticationCubit  // Thêm tham số này
  })
      : _authRepo = authenticationRepository,
        _authCubit = authenticationCubit,  // Khởi tạo
        super(const LoginInitial());

  Future<void> login(String email, String password) async {
    emit(const LoginLoading());
    try {
      final AuthResult result = await _authRepo
          .loginWithEmailAndPassword(email: email, password: password);

      // Cập nhật AuthenticationCubit với kết quả login
      _authCubit.loggedIn(result);  // Thêm dòng này

      // emit success với các thông tin
      emit(LoginSuccess(result.roleName, result.storeId, result.uid, result.email));
    } catch (e) {
      emit(LoginFailure(e.toString()));
    }
  }
}