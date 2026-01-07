enum RegistrationMethod {
  cookieBased,
  deviceBoundKey,
}

extension RegistrationMethodX on RegistrationMethod {
  String get displayName {
    switch (this) {
      case RegistrationMethod.cookieBased:
        return 'Cookie-based';
      case RegistrationMethod.deviceBoundKey:
        return 'Device-Bound Key';
    }
  }
}

