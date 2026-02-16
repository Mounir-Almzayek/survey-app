import '../../auth/models/login_method_type.dart';

/// Context that drives which nav tabs are visible.
/// Extensible: add more fields later for other visibility conditions.
class NavVisibilityContext {
  const NavVisibilityContext({this.loginMethod});

  final LoginMethodType? loginMethod;
}
