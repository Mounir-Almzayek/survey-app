import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:passkeys/authenticator.dart';
import 'package:passkeys/types.dart';
import 'main.dart'; // To access constants like kApiBaseUrl if needed, or we can duplicate/import constants

class DeviceRegistrationWidget extends StatefulWidget {
  const DeviceRegistrationWidget({super.key});

  @override
  State<DeviceRegistrationWidget> createState() =>
      _DeviceRegistrationWidgetState();
}

class _DeviceRegistrationWidgetState extends State<DeviceRegistrationWidget> {
  final TextEditingController _tokenController = TextEditingController();
  final _passkeyAuthenticator = PasskeyAuthenticator(debugMode: true);
  final _storage = const FlutterSecureStorage();
  final _dio = Dio(BaseOptions(baseUrl: kApiBaseUrl));

  bool _isLoading = false;
  String _statusMessage = '';

  Future<void> _handleRegistration(String token) async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Validating token...';
    });

    try {
      // 1. Validate Token
      final validateRes = await _dio.get(
        '/device-registration/validate-token/$token',
      );
      if (validateRes.statusCode != 200) {
        throw Exception('Invalid token');
      }

      if (mounted)
        setState(() => _statusMessage = 'Generating device fingerprint...');

      // 2. Generate Fingerprint
      final fingerprint = await _getFingerprint();

      if (mounted)
        setState(() => _statusMessage = 'Requesting Passkey Challenge...');

      // 3. Request Challenge
      final challengeRes = await _dio.post(
        '/device-registration/register/webauthn/challenge/$token',
        data: {
          'browser': 'FlutterApp',
          'os': Platform.operatingSystem,
          'fingerprint': fingerprint,
        },
      );

      final challengeData = challengeRes.data['data'];
      final options = challengeData['options'];
      final String cookie = challengeData['cookie']; // The initial cookie

      if (mounted)
        setState(() => _statusMessage = 'Waiting for User Passkey...');

      // 4. Create Passkey on Device
      final RegisterResponseType
      response = await _passkeyAuthenticator.register(
        RegisterRequestType(
          excludeCredentials: List.from(
            options['excludeCredentials'],
          ).map((e) => CredentialType.fromJson(e)).toList(),
          authSelectionType: AuthenticatorSelectionType(
            authenticatorAttachment:
                options['authenticatorSelection']['authenticatorAttachment'],
            residentKey: options['authenticatorSelection']['residentKey'],
            requireResidentKey:
                options['authenticatorSelection']['requireResidentKey'],
            userVerification:
                options['authenticatorSelection']['userVerification'],
          ),
          attestation: options['attestation'],
          timeout: options['timeout'],
          relyingParty: RelyingPartyType(
            name: options['rp']['name'],
            id: options['rp']['id'],
          ),
          user: UserType(
            displayName: options['user']['displayName'],
            name: options['user']['name'],
            id: options['user']['id'],
          ),
          challenge: options['challenge'],
          pubKeyCredParams: (options['pubKeyCredParams'] as List)
              .map((e) => PubKeyCredParamType(alg: e['alg'], type: e['type']))
              .toList(),
        ),
      );
      log(response.toJsonString());

      if (mounted)
        setState(() => _statusMessage = 'Verifying Passkey with Server...');

      // 5. Complete Registration
      final Map<String, dynamic> registrationPayload = jsonDecode(
        response.toJsonString(),
      );

      final completeRes = await _dio.post(
        '/device-registration/register/webauthn/complete/$token',
        data: {'credentials': registrationPayload},
      );

      if (completeRes.data['success'] == true) {
        // 6. Save the Device Cookie
        await _storage.write(key: 'device_cookie', value: cookie);

        if (mounted) {
          setState(() {
            _statusMessage = 'Registration Successful!';
            _isLoading = false;
          });
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Device Registered Successfully!')),
          );
        }
      } else {
        throw Exception('Server rejected registration');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = 'Error: $e';
          _isLoading = false;
        });
      }
      log(e.toString());
    }
  }

  Future<Map<String, dynamic>> _getFingerprint() async {
    final deviceInfo = DeviceInfoPlugin();
    Map<String, dynamic> fingerprint = {
      'user_agent': 'Flutter/${Platform.version}',
      'screen': {'width': 1080, 'height': 1920},
      'ram': 4096,
      'hardware_concurrency': 4,
      'max_touch_points': 5,
    };

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      fingerprint['device_model'] = androidInfo.model;
      fingerprint['os_version'] = androidInfo.version.release;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      fingerprint['device_model'] = iosInfo.name;
      fingerprint['os_version'] = iosInfo.systemVersion;
    }
    return fingerprint;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_isLoading)
              Column(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  Text(_statusMessage, textAlign: TextAlign.center),
                ],
              )
            else ...[
              const Text(
                'Enter Registration Token',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _tokenController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Paste token here',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_tokenController.text.isNotEmpty) {
                    _handleRegistration(_tokenController.text.trim());
                  }
                },
                child: const Text('Register with Token'),
              ),
              const SizedBox(height: 40),
              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('OR'),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 40),
              Text(
                'Important: When prompted, please use your device PIN, Pattern, or Password. Using Biometrics (Fingerprint/Face) may create a synced key which will be rejected for security reasons.',
                style: TextStyle(
                  color: Colors.orange[800],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Scan QR Code'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                ),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const QRScannerPage(),
                    ),
                  );
                  if (result != null) {
                    _tokenController.text = result;
                    _handleRegistration(result);
                  }
                },
              ),
              const SizedBox(height: 20),
              Text(
                _statusMessage,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  bool _isScanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Code')),
      body: MobileScanner(
        onDetect: (capture) {
          if (_isScanned) return;
          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            if (barcode.rawValue != null) {
              setState(() {
                _isScanned = true;
              });
              String code = barcode.rawValue!;
              Uri? uri = Uri.tryParse(code);
              if (uri != null && uri.queryParameters.containsKey('token')) {
                code = uri.queryParameters['token']!;
              } else if (code.contains('token=')) {
                code = code.split('token=')[1].split('&')[0];
              }

              Navigator.pop(context, code);
              break;
            }
          }
        },
      ),
    );
  }
}
