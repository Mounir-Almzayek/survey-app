class ResendVerificationRequest {
  final String email;

  ResendVerificationRequest({this.email = ''});

  Map<String, dynamic> toJson() => {'email': email};
}
