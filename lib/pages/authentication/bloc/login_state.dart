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
  final String roleName;
  final int? storeId;
  final int userId;
  final String email;
  const LoginSuccess(this.roleName, this.storeId,this.userId,this.email);

  @override
  List<Object?> get props => [roleName, storeId];
}

class LoginFailure extends LoginState {
  final String message;
  const LoginFailure(this.message);

  @override
  List<Object?> get props => [message];
}
