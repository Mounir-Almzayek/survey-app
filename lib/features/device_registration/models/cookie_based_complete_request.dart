class CookieBasedCompleteRequest {
  final String token;
  final String browser;
  final String os;
  final Map<String, dynamic> fingerprint;

  const CookieBasedCompleteRequest({
    required this.token,
    required this.browser,
    required this.os,
    required this.fingerprint,
  });

  Map<String, dynamic> toJson() => {
        'browser': browser,
        'os': os,
        'fingerprint': fingerprint,
      };
}

