import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../config/app_environment.dart';
import '../../l10n/generated/l10n.dart';
import '../../styles/app_colors.dart';

/// Reusable map picker with optional "use my current location" button.
/// Consumers own the value; this widget only emits LatLng changes.
class SurveyLocationMapPicker extends StatefulWidget {
  final LatLng? value;
  final ValueChanged<LatLng?> onChanged;
  final double height;
  final bool showError;
  final bool showCurrentLocationButton;
  final bool disabled;

  const SurveyLocationMapPicker({
    super.key,
    required this.value,
    required this.onChanged,
    this.height = 280,
    this.showError = false,
    this.showCurrentLocationButton = true,
    this.disabled = false,
  });

  @override
  State<SurveyLocationMapPicker> createState() =>
      _SurveyLocationMapPickerState();
}

class _SurveyLocationMapPickerState extends State<SurveyLocationMapPicker> {
  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  LatLng get _center {
    if (widget.value != null) return widget.value!;
    final d = AppEnvironment.mapDefaultLatLng;
    return LatLng(d.latitude, d.longitude);
  }

  Future<void> _useMyLocation() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) throw Exception('Location service disabled');
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        throw Exception('Location permission denied');
      }
      final pos = await Geolocator.getCurrentPosition();
      final ll = LatLng(pos.latitude, pos.longitude);
      widget.onChanged(ll);
      _mapController.move(ll, 14);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pos = widget.value;
    final border = widget.showError
        ? AppColors.destructive
        : AppColors.border.withOpacity(0.8);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: SizedBox(
            height: widget.height,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: border),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _center,
                  initialZoom: pos != null ? 14 : 10,
                  onTap: widget.disabled
                      ? null
                      : (_, latlng) {
                          widget.onChanged(latlng);
                        },
                ),
                children: [
                  TileLayer(
                    urlTemplate: AppEnvironment.mapTileUrl,
                    userAgentPackageName:
                        'com.system2030.king_abdulaziz_center_survey_app',
                    keepBuffer: 3,
                  ),
                  if (pos != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: pos,
                          width: 36,
                          height: 36,
                          child: const RepaintBoundary(
                            child: Icon(
                              Icons.location_on_rounded,
                              color: AppColors.surveyPrimary,
                              size: 36,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
        if (pos != null) ...[
          SizedBox(height: 8.h),
          Text(
            '${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}',
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.secondaryText,
            ),
          ),
        ],
        if (widget.showCurrentLocationButton && !widget.disabled) ...[
          SizedBox(height: 8.h),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              key: const ValueKey('map-use-my-location'),
              onPressed: _useMyLocation,
              icon: const Icon(Icons.my_location_rounded),
              label: Text(S.of(context).use_my_current_location),
            ),
          ),
        ],
      ],
    );
  }
}
