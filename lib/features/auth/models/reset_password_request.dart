class ResetPasswordRequest {
  final String email;
  final String code;
  final String password;

  ResetPasswordRequest({this.email = '', this.code = '', this.password = ''});

  ResetPasswordRequest copyWith({
    String? email,
    String? code,
    String? password,
  }) {
    return ResetPasswordRequest(
      email: email ?? this.email,
      code: code ?? this.code,
      password: password ?? this.password,
    );
  }

  Map<String, dynamic> toJson() => {
    'email': email,
    'reset_password_code': code,
    'password': password,
  };
}
