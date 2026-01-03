import 'package:passkeys/authenticator.dart';
import 'package:passkeys/types.dart';

class PasskeyService {
  final _authenticator = PasskeyAuthenticator();

  /// Authenticates using a Passkey/WebAuthn.
  /// [options] is the 'options' map returned from the 'initiate' login step.
  Future<Map<String, dynamic>> authenticate(
    Map<String, dynamic> options,
  ) async {
    try {
      // The options from SimpleWebAuthn (backend) match the expected format for AuthenticateRequestType
      final request = AuthenticateRequestType.fromJson(options);

      final response = await _authenticator.authenticate(request);

      // Return the JSON representation which matches what the backend expects for 'credentials'
      return response.toJson();
    } catch (e) {
      // Re-throw to handle in the Bloc
      rethrow;
    }
  }

  /// Checks if Passkeys are supported on this device.
  Future<bool> isSupported() async {
    try {
      // canAuthenticate returns true if the device supports passkeys
      return await _authenticator.canAuthenticate();
    } catch (_) {
      return false;
    }
  }
}
