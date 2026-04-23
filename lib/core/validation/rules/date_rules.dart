import 'package:intl/intl.dart';
import '../../l10n/generated/l10n.dart';
import '../../models/survey/validation_model.dart';
import '../rule.dart';

DateTime? _toDate(dynamic v) {
  if (v == null) return null;
  if (v is DateTime) return v;
  if (v is! String) return null;

  final trimmed = v.trim();
  if (trimmed.isEmpty) return null;

  // 1. Full ISO or YYYY-MM-DD HH:mm:ss
  final full = DateTime.tryParse(trimmed);
  if (full != null) return full;

  // 2. YYYY-MM-DD
  if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(trimmed)) {
    return DateTime.tryParse(trimmed);
  }

  // 3. HH:mm:ss or HH:mm (Time only)
  // Prepend dummy date to make it parseable
  if (RegExp(r'^\d{1,2}:\d{2}(:\d{2})?$').hasMatch(trimmed)) {
    return DateTime.tryParse("1970-01-01 $trimmed");
  }

  return null;
}

String _fmt(DateTime d, String locale, {bool hasTime = true, bool onlyTime = false}) {
  if (onlyTime) {
    return DateFormat.jm(locale).format(d);
  }
  if (hasTime && (d.hour != 0 || d.minute != 0)) {
    return DateFormat.yMd(locale).add_jm().format(d);
  }
  return DateFormat.yMd(locale).format(d);
}

bool _isTimeOnly(dynamic v) {
  if (v is! String) return false;
  return RegExp(r'^\d{1,2}:\d{2}(:\d{2})?$').hasMatch(v.trim());
}

class MinDateRule extends Rule {
  @override
  int get id => 28;
  @override
  String get debugName => 'Minimum Date/Time';

  @override
  RuleResult validate({
    required dynamic value,
    required Map<String, dynamic> params,
    required Validation validation,
    required String locale,
  }) {
    final minVal = params['value'] ?? params['min'];
    final min = _toDate(minVal);
    if (min == null) return const RuleResult.valid();

    final actual = _toDate(value);
    if (actual == null) return const RuleResult.valid();

    final ok = actual.isAfter(min) || actual.isAtSameMomentAs(min);
    if (ok) return const RuleResult.valid();

    return RuleResult.invalid(
      S.current.validation_min_date(_fmt(min, locale, onlyTime: _isTimeOnly(minVal))),
    );
  }
}

class MaxDateRule extends Rule {
  @override
  int get id => 29;
  @override
  String get debugName => 'Maximum Date/Time';

  @override
  RuleResult validate({
    required dynamic value,
    required Map<String, dynamic> params,
    required Validation validation,
    required String locale,
  }) {
    final maxVal = params['value'] ?? params['max'];
    final max = _toDate(maxVal);
    if (max == null) return const RuleResult.valid();

    final actual = _toDate(value);
    if (actual == null) return const RuleResult.valid();

    final ok = actual.isBefore(max) || actual.isAtSameMomentAs(max);
    if (ok) return const RuleResult.valid();

    return RuleResult.invalid(
      S.current.validation_max_date(_fmt(max, locale, onlyTime: _isTimeOnly(maxVal))),
    );
  }
}

class BetweenDatesRule extends Rule {
  @override
  int get id => 30;
  @override
  String get debugName => 'Between Dates/Times';

  @override
  RuleResult validate({
    required dynamic value,
    required Map<String, dynamic> params,
    required Validation validation,
    required String locale,
  }) {
    final startVal = params['start'];
    final endVal = params['end'];
    final start = _toDate(startVal);
    final end = _toDate(endVal);

    if (start == null || end == null) return const RuleResult.valid();

    final actual = _toDate(value);
    if (actual == null) return const RuleResult.valid();

    final ok = (actual.isAfter(start) || actual.isAtSameMomentAs(start)) &&
        (actual.isBefore(end) || actual.isAtSameMomentAs(end));
    
    if (ok) return const RuleResult.valid();

    final isTime = _isTimeOnly(startVal);
    return RuleResult.invalid(
      S.current.validation_date_range(
        _fmt(start, locale, onlyTime: isTime),
        _fmt(end, locale, onlyTime: isTime),
      ),
    );
  }
}

class EqualDateRule extends Rule {
  @override
  int get id => 34; // New ID
  @override
  String get debugName => 'Equal Date/Time';

  @override
  RuleResult validate({
    required dynamic value,
    required Map<String, dynamic> params,
    required Validation validation,
    required String locale,
  }) {
    final targetVal = params['value'];
    final target = _toDate(targetVal);
    if (target == null) return const RuleResult.valid();

    final actual = _toDate(value);
    if (actual == null) return const RuleResult.valid();

    if (actual.isAtSameMomentAs(target)) return const RuleResult.valid();

    // Fallback: compare strings if moments differ slightly but represent same day/time
    if (value.toString().trim() == targetVal.toString().trim()) {
      return const RuleResult.valid();
    }

    return RuleResult.invalid(
      S.current.validation_equal_date(
        _fmt(target, locale, onlyTime: _isTimeOnly(targetVal)),
      ),
    );
  }
}
