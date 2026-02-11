part of 'login_bloc.dart';

abstract class LoginState {
  final String email;
  final String password;

  LoginState({this.email = '', this.password = ''});
}

class LoginInitial extends LoginState {
  LoginInitial({super.email, super.password});
}

class LoginLoading extends LoginState {
  LoginLoading({super.email, super.password});
}

class LoginInitiateSuccess extends LoginState {
  final ResearcherLoginInitiateResponse response;

  LoginInitiateSuccess({required this.response, super.email, super.password});
}

class LoginSuccess extends LoginState {
  final String token;

  LoginSuccess({required this.token, super.email, super.password});
}

class LoginFailure extends LoginState {
  final String error;

  LoginFailure({required this.error, super.email, super.password});
}
