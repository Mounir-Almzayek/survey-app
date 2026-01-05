class WebAuthnChallengeResponse {
  final WebAuthnOptions options;
  final String? cookie;

  const WebAuthnChallengeResponse({required this.options, this.cookie});

  factory WebAuthnChallengeResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return WebAuthnChallengeResponse(
      options: WebAuthnOptions.fromJson(
        data['options'] as Map<String, dynamic>,
      ),
      cookie: data['cookie'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'options': options.toJson(), if (cookie != null) 'cookie': cookie};
  }
}

class WebAuthnOptions {
  final String challenge;
  final RelyingParty rp;
  final WebAuthnUser user;
  final List<PubKeyCredParam> pubKeyCredParams;
  final int timeout;
  final String attestation;
  final List<CredentialDescriptor> excludeCredentials;
  final AuthenticatorSelection authenticatorSelection;
  final WebAuthnExtensions? extensions;
  final List<String> hints;

  const WebAuthnOptions({
    required this.challenge,
    required this.rp,
    required this.user,
    required this.pubKeyCredParams,
    required this.timeout,
    required this.attestation,
    required this.excludeCredentials,
    required this.authenticatorSelection,
    this.extensions,
    required this.hints,
  });

  factory WebAuthnOptions.fromJson(Map<String, dynamic> json) {
    return WebAuthnOptions(
      challenge: json['challenge'] as String,
      rp: RelyingParty.fromJson(json['rp'] as Map<String, dynamic>),
      user: WebAuthnUser.fromJson(json['user'] as Map<String, dynamic>),
      pubKeyCredParams: (json['pubKeyCredParams'] as List)
          .map((e) => PubKeyCredParam.fromJson(e as Map<String, dynamic>))
          .toList(),
      timeout: json['timeout'] as int,
      attestation: json['attestation'] as String,
      excludeCredentials: (json['excludeCredentials'] as List? ?? [])
          .map((e) => CredentialDescriptor.fromJson(e as Map<String, dynamic>))
          .toList(),
      authenticatorSelection: AuthenticatorSelection.fromJson(
        json['authenticatorSelection'] as Map<String, dynamic>,
      ),
      extensions: json['extensions'] != null
          ? WebAuthnExtensions.fromJson(
              json['extensions'] as Map<String, dynamic>,
            )
          : null,
      hints: (json['hints'] as List? ?? []).cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'challenge': challenge,
      'rp': rp.toJson(),
      'user': user.toJson(),
      'pubKeyCredParams': pubKeyCredParams.map((e) => e.toJson()).toList(),
      'timeout': timeout,
      'attestation': attestation,
      'excludeCredentials': excludeCredentials.map((e) => e.toJson()).toList(),
      'authenticatorSelection': authenticatorSelection.toJson(),
      if (extensions != null) 'extensions': extensions!.toJson(),
      'hints': hints,
    };
  }
}

class RelyingParty {
  final String name;
  final String id;

  const RelyingParty({required this.name, required this.id});

  factory RelyingParty.fromJson(Map<String, dynamic> json) {
    return RelyingParty(name: json['name'] as String, id: json['id'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'id': id};
  }
}

class WebAuthnUser {
  final String id;
  final String name;
  final String displayName;

  const WebAuthnUser({
    required this.id,
    required this.name,
    required this.displayName,
  });

  factory WebAuthnUser.fromJson(Map<String, dynamic> json) {
    return WebAuthnUser(
      id: json['id'] as String,
      name: json['name'] as String,
      displayName: json['displayName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'displayName': displayName};
  }
}

class PubKeyCredParam {
  final int alg;
  final String type;

  const PubKeyCredParam({required this.alg, required this.type});

  factory PubKeyCredParam.fromJson(Map<String, dynamic> json) {
    return PubKeyCredParam(
      alg: json['alg'] as int,
      type: json['type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'alg': alg, 'type': type};
  }
}

class CredentialDescriptor {
  final String id;
  final String type;
  final List<String>? transports;

  const CredentialDescriptor({
    required this.id,
    required this.type,
    this.transports,
  });

  factory CredentialDescriptor.fromJson(Map<String, dynamic> json) {
    return CredentialDescriptor(
      id: json['id'] as String,
      type: json['type'] as String,
      transports: (json['transports'] as List?)?.cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      if (transports != null) 'transports': transports,
    };
  }
}

class AuthenticatorSelection {
  final String residentKey;
  final bool requireResidentKey;
  final String authenticatorAttachment;
  final String userVerification;

  const AuthenticatorSelection({
    required this.residentKey,
    required this.requireResidentKey,
    required this.authenticatorAttachment,
    required this.userVerification,
  });

  factory AuthenticatorSelection.fromJson(Map<String, dynamic> json) {
    return AuthenticatorSelection(
      residentKey: json['residentKey'] as String,
      requireResidentKey: json['requireResidentKey'] as bool,
      authenticatorAttachment: json['authenticatorAttachment'] as String,
      userVerification: json['userVerification'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'residentKey': residentKey,
      'requireResidentKey': requireResidentKey,
      'authenticatorAttachment': authenticatorAttachment,
      'userVerification': userVerification,
    };
  }
}

class WebAuthnExtensions {
  final bool? credProps;

  const WebAuthnExtensions({this.credProps});

  factory WebAuthnExtensions.fromJson(Map<String, dynamic> json) {
    return WebAuthnExtensions(credProps: json['credProps'] as bool?);
  }

  Map<String, dynamic> toJson() {
    return {if (credProps != null) 'credProps': credProps};
  }
}
