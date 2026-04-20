import 'dart:async';
import 'package:app_links/app_links.dart';

typedef DeepLinkClock = DateTime Function();

class DeepLinkService {
  static const Duration _dedupWindow = Duration(seconds: 2);

  final AppLinks? _appLinks;
  final Stream<Uri>? _sourceStreamOverride;
  final Uri? _initialOverride;
  final DeepLinkClock _clock;

  Uri? _lastUri;
  DateTime? _lastAt;

  late final Stream<Uri> _filtered;

  DeepLinkService()
      : _appLinks = AppLinks(),
        _sourceStreamOverride = null,
        _initialOverride = null,
        _clock = DateTime.now {
    _filtered = _appLinks!.uriLinkStream.where(_notDuplicate);
  }

  DeepLinkService.test({
    required Uri? initial,
    required Stream<Uri> sourceStream,
    required DeepLinkClock clock,
  })  : _appLinks = null,
        _initialOverride = initial,
        _sourceStreamOverride = sourceStream,
        _clock = clock {
    _filtered = _sourceStreamOverride!.where(_notDuplicate);
  }

  Stream<Uri> get linkStream => _filtered;

  Future<Uri?> initialLink() async {
    if (_appLinks != null) {
      final uri = await _appLinks.getInitialLink();
      if (uri == null) return null;
      if (!_notDuplicate(uri)) return null;
      return uri;
    }
    final initial = _initialOverride;
    if (initial != null && _notDuplicate(initial)) return initial;
    return null;
  }

  /// Called on AppLifecycleState.resumed to pick up any delivered-while-suspended link.
  Future<Uri?> refreshOnResume() => initialLink();

  bool _notDuplicate(Uri uri) {
    final now = _clock();
    final last = _lastUri;
    final lastAt = _lastAt;
    if (last != null &&
        lastAt != null &&
        last == uri &&
        now.difference(lastAt) < _dedupWindow) {
      return false;
    }
    _lastUri = uri;
    _lastAt = now;
    return true;
  }
}
