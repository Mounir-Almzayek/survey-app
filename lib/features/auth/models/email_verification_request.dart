class EmailVerificationRequest {
  final String email;
  final String code;

  EmailVerificationRequest({this.email = '', this.code = ''});

  EmailVerificationRequest copyWith({String? email, String? code}) {
    return EmailVerificationRequest(
      email: email ?? this.email,
      code: code ?? this.code,
    );
  }

  Map<String, dynamic> toJson() => {'email': email, 'code': code};
}
