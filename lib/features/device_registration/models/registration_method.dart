enum RegistrationMethod {
  webauthn,
  cookieBased,
  deviceBoundKey,
}

extension RegistrationMethodX on RegistrationMethod {
  String get displayName {
    switch (this) {
      case RegistrationMethod.webauthn:
        return 'WebAuthn';
      case RegistrationMethod.cookieBased:
        return 'Cookie-based';
      case RegistrationMethod.deviceBoundKey:
        return 'Device-Bound Key';
    }
  }
}

