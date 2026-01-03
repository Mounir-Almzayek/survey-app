import 'researcher_login_screen.dart';

class ResearcherLoginFingerprint {
  final String user_agent;
  final ResearcherLoginScreen screen;
  final int ram;
  final int hardware_concurrency;
  final int max_touch_points;

  const ResearcherLoginFingerprint({
    this.user_agent = '',
    this.screen = const ResearcherLoginScreen(),
    this.ram = 0,
    this.hardware_concurrency = 0,
    this.max_touch_points = 0,
  });

  Map<String, dynamic> toJson() => {
        'user_agent': user_agent,
        'screen': screen.toJson(),
        'ram': ram,
        'hardware_concurrency': hardware_concurrency,
        'max_touch_points': max_touch_points,
      };
}
