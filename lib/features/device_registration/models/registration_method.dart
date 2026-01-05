enum RegistrationMethod {
  webauthn,
  cookieBased,
}

extension RegistrationMethodX on RegistrationMethod {
  String get displayName {
    switch (this) {
      case RegistrationMethod.webauthn:
        return 'WebAuthn';
      case RegistrationMethod.cookieBased:
        return 'Cookie-based';
    }
  }
}

