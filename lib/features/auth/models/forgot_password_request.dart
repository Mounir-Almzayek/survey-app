class ForgotPasswordRequest {
  final String email;

  ForgotPasswordRequest({this.email = ''});

  Map<String, dynamic> toJson() => {'email': email};
}
