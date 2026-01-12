import 'location_data.dart';

/// Request model for starting a public link response
/// POST /public-link/{short_code}/start
class StartPublicLinkRequest {
  final LocationData? location;

  const StartPublicLinkRequest({this.location});

  Map<String, dynamic> toJson() {
    return {if (location != null) 'location': location!.toJson()};
  }
}
