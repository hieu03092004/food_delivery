import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domains/data_source/firebase_auth_service.dart';

/// State chứa AuthResult (hoặc null nếu chưa login)
class AuthenticationState extends Equatable {
  final AuthResult? user;
  const AuthenticationState(this.user);

  @override
  List<Object?> get props => [user];
}

/// Cubit để quản lý login/logout
class AuthenticationCubit extends Cubit<AuthenticationState> {
  AuthenticationCubit() : super(const AuthenticationState(null));

  /// Gọi khi login thành công
  void loggedIn(AuthResult user) => emit(AuthenticationState(user));

  /// Gọi khi logout
  void loggedOut() => emit(const AuthenticationState(null));
}
