part of 'login_cubit.dart';
abstract class LoginState extends Equatable {
  const LoginState();
  @override
  List<Object?> get props => [];
}

class LoginInitial extends LoginState {
  const LoginInitial();
}

class LoginLoading extends LoginState {
  const LoginLoading();
}

class LoginSuccess extends LoginState {
  final int roleId;
  final int? storeId;
  const LoginSuccess(this.roleId, this.storeId);

  @override
  List<Object?> get props => [roleId, storeId];
}

class LoginFailure extends LoginState {
  final String message;
  const LoginFailure(this.message);

  @override
  List<Object?> get props => [message];
}
