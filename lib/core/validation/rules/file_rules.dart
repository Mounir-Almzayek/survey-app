import 'dart:io';
import 'package:path/path.dart' as p;
import '../../l10n/generated/l10n.dart';
import '../../models/survey/validation_model.dart';
import '../param_helpers.dart';
import '../rule.dart';

class FileSizeRule extends Rule {
  @override
  int get id => 31;
  @override
  String get debugName => 'Max File Size';

  @override
  RuleResult validate({
    required dynamic value,
    required Map<String, dynamic> params,
    required Validation validation,
    required String locale,
  }) {
    // Value is expected to be a path (String) or File object
    final path = value is String ? value : (value is File ? value.path : null);
    if (path == null || path.isEmpty) return const RuleResult.valid();

    final maxMb = paramInt(params, 'max_size_mb');
    if (maxMb == null) return const RuleResult.valid();

    final file = File(path);
    if (!file.existsSync()) return const RuleResult.valid();

    final sizeInMb = file.lengthSync() / (1024 * 1024);
    if (sizeInMb > maxMb) {
      return RuleResult.invalid(S.current.validation_max_file_size(maxMb.toString()));
    }

    return const RuleResult.valid();
  }
}

class FileExtensionRule extends Rule {
  @override
  int get id => 32;
  @override
  String get debugName => 'Allowed Extensions';

  @override
  RuleResult validate({
    required dynamic value,
    required Map<String, dynamic> params,
    required Validation validation,
    required String locale,
  }) {
    final path = value is String ? value : (value is File ? value.path : null);
    if (path == null || path.isEmpty) return const RuleResult.valid();

    final allowed = params['extensions']; // Expected as a comma-separated string or list
    if (allowed == null) return const RuleResult.valid();

    final allowedList = allowed is List 
        ? allowed.map((e) => e.toString().toLowerCase()).toList()
        : allowed.toString().toLowerCase().split(',').map((e) => e.trim()).toList();

    final ext = p.extension(path).replaceAll('.', '').toLowerCase();
    
    if (!allowedList.contains(ext)) {
      return RuleResult.invalid(S.current.validation_invalid_file_type(allowedList.join(', ')));
    }

    return const RuleResult.valid();
  }
}
