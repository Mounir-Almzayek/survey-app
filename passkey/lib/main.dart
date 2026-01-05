import 'package:flutter/material.dart';
import 'device_registration.dart';
import 'auth_login.dart';

// Consts shared across files
const String kApiBaseUrl = 'https://survey-api.system2030.com';
const String kRelyingPartyId = 'survey-frontend.system2030.com';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Survey App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Survey App'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.app_registration), text: 'Register Device'),
              Tab(icon: Icon(Icons.login), text: 'Login'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [DeviceRegistrationWidget(), AuthWidget()],
        ),
      ),
    );
  }
}
