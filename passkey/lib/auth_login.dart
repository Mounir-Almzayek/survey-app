import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:passkeys/authenticator.dart';
import 'package:passkeys/types.dart';
import 'main.dart'; // for kApiBaseUrl

class AuthWidget extends StatefulWidget {
  const AuthWidget({super.key});

  @override
  State<AuthWidget> createState() => _AuthWidgetState();
}

class _AuthWidgetState extends State<AuthWidget> {
  final _emailController = TextEditingController(
    text: 'researcher@example.com',
  );
  final _passwordController = TextEditingController(
    text: 'Adm!n@2024#Secure\$Passw0rd',
  );
  final _storage = const FlutterSecureStorage();
  final _dio = Dio(BaseOptions(baseUrl: kApiBaseUrl));
  final _passkeyAuthenticator = PasskeyAuthenticator(debugMode: true);

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Researcher Sign In',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleResearcherLogin,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Login'),
            ),
          ],
        ),
      ),
    );
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

  void _handleResearcherLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both email and password')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 0. Check for Device Cookie
      String? deviceCookie = await _storage.read(key: 'device_cookie');

      // We must attach the device_token cookie manually if using Dio for this initial request
      // Or ensure Dio cookie manager is set up. Simplified manual header approach:
      final requestOptions = Options(
        headers: deviceCookie != null
            ? {'Cookie': 'device_token=$deviceCookie'}
            : {},
      );

      final fingerprint = await _getFingerprint();

      // 1. Initiate Login
      final initResponse = await _dio.post(
        '/auth/researcher-login/initiate',
        data: {
          'email': email,
          'password': password,
          'os': Platform.operatingSystem,
          'browser': 'FlutterApp',
          'fingerprint': fingerprint,
        },
        options: requestOptions,
      );

      final initData = initResponse.data['data'];
      final String method = initData['method'];
      dynamic webAuthnResponse;

      if (method == 'webauthn') {
        // Handle Passkey Challenge
        final options = initData['options'];

        final AuthenticateResponseType authResponse =
            await _passkeyAuthenticator.authenticate(
              AuthenticateRequestType(
                relyingPartyId: kRelyingPartyId,
                challenge: options['challenge'],
                timeout: options['timeout'],
                // Use server preference or fallback to 'preferred'
                userVerification: options['userVerification'] ?? 'preferred',
                mediation: MediationType.Optional,
                preferImmediatelyAvailableCredentials: false,
                allowCredentials: (options['allowCredentials'] as List)
                    .map(
                      (e) => CredentialType(
                        id: e['id'],
                        type: e['type'],
                        transports:
                            (e['transports'] as List?)?.cast<String>() ?? [],
                      ),
                    )
                    .toList(),
              ),
            );

        webAuthnResponse = jsonDecode(authResponse.toJsonString());
      }

      // 2. Verify Login
      final verifyResponse = await _dio.post(
        '/auth/researcher-login/verify-login',
        data: {
          'email': email,
          'password': password,
          'os': Platform.operatingSystem,
          'browser': 'FlutterApp',
          'fingerprint': fingerprint,
          'credentials': webAuthnResponse, // null if method is cookie
          'device_token': null, // Optional, can be handled by cookie
          'timezone': DateTime.now().timeZoneName,
        },
        options: requestOptions,
      );

      if (verifyResponse.statusCode == 200 ||
          verifyResponse.statusCode == 201) {
        final accessToken = verifyResponse.data['accessToken'];
        final userName = verifyResponse.data['user_name'];

        if (accessToken != null) {
          await _storage.write(key: 'auth_token', value: accessToken);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Welcome, Researcher $userName!')),
            );
          }
        }
      }
    } on DioException catch (e) {
      log(e.toString());
      String errorMessage = 'Login failed';
      if (e.response?.data is Map &&
          (e.response?.data as Map).containsKey('message')) {
        errorMessage = e.response!.data['message'];
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      log(e.toString());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
