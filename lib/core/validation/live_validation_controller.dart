import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/survey/question_model.dart';
import '../utils/survey_validator.dart';

/// Per-question debounced validator + error stream.
///
/// Owned by `SurveyQuestionRenderer`. One instance per visible question.
/// Emits via [ChangeNotifier] so widgets can rebuild only their error text.
class LiveValidationController extends ChangeNotifier {
  LiveValidationController({
    required this.question,
    required this.locale,
    Duration debounce = const Duration(milliseconds: 350),
  }) : _debounce = debounce;

  final Question question;
  final String locale;
  final Duration _debounce;

  Timer? _timer;
  String? _error;
  bool _dirty = false;
  bool _submitAttempted = false;

  /// Current error text. Null on pristine fields or when validation passes.
  /// Gated by `_dirty || _submitAttempted` so pristine screens aren't red.
  String? get error => (_dirty || _submitAttempted) ? _error : null;

  void onChanged(dynamic value) {
    _dirty = true;
    _timer?.cancel();
    _timer = Timer(_debounce, () => _evaluate(value));
  }

  void onBlur(dynamic value) {
    _timer?.cancel();
    _evaluate(value);
  }

  void markSubmitAttempted() {
    _submitAttempted = true;
    notifyListeners();
  }

  void _evaluate(dynamic value) {
    final errors = SurveyValidator.validateQuestion(
      question: question,
      value: value,
      locale: locale,
      isRequired: question.isRequired ?? false,
    );
    final next = errors.isEmpty ? null : errors.first;
    if (next != _error) {
      _error = next;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
