class EmailVerificationRequest {
  final String email;
  final String code;

  EmailVerificationRequest({required this.email, required this.code});

  Map<String, dynamic> toJson() => {'email': email, 'code': code};
}

class ResendVerificationRequest {
  final String email;

  ResendVerificationRequest({required this.email});

  Map<String, dynamic> toJson() => {'email': email};
}

class ForgotPasswordRequest {
  final String email;

  ForgotPasswordRequest({required this.email});

  Map<String, dynamic> toJson() => {'email': email};
}

class ResetPasswordRequest {
  final String email;
  final String code;
  final String password;

  ResetPasswordRequest({
    required this.email,
    required this.code,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'reset_password_code': code,
    'password': password,
  };
}
