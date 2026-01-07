import 'package:flutter/material.dart';

import '../../../core/l10n/generated/l10n.dart';
import '../service/location_service.dart';

/// A gate widget that blocks the app until location permission is granted.
class LocationPermissionGate extends StatefulWidget {
  final Widget child;

  const LocationPermissionGate({super.key, required this.child});

  @override
  State<LocationPermissionGate> createState() => _LocationPermissionGateState();
}

class _LocationPermissionGateState extends State<LocationPermissionGate> {
  bool _checking = true;
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final has = await LocationService.hasPermissions();
    if (!mounted) return;
    setState(() {
      _hasPermission = has;
      _checking = false;
    });
  }

  Future<void> _requestPermission() async {
    setState(() {
      _checking = true;
    });
    final granted = await LocationService.requestPermissions();
    if (!mounted) return;
    if (granted) {
      setState(() {
        _hasPermission = true;
        _checking = false;
      });
    } else {
      setState(() {
        _hasPermission = false;
        _checking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_hasPermission) {
      return widget.child;
    }

    // Block app usage until location permission is granted
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_on_outlined, size: 48),
                const SizedBox(height: 16),
                Text(
                  S.of(context).location_permission_required_title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  S.of(context).location_permission_required_message,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _requestPermission,
                  child: Text(S.of(context).allow_location_access),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
