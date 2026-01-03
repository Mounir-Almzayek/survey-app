part of 'login_bloc.dart';

abstract class LoginEvent {}

class UpdateEmail extends LoginEvent {
  final String email;
  UpdateEmail(this.email);
}

class UpdatePassword extends LoginEvent {
  final String password;
  UpdatePassword(this.password);
}

class SendInitiateLogin extends LoginEvent {}

class SendVerifyLogin extends LoginEvent {
  final String credentials;
  SendVerifyLogin({this.credentials = ''});
}

class ResetState extends LoginEvent {}
