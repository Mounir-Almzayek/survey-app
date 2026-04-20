import 'package:flutter/foundation.dart';

class SurveyInProgressNotifier extends ValueNotifier<bool> {
  SurveyInProgressNotifier._() : super(false);
  static final SurveyInProgressNotifier instance = SurveyInProgressNotifier._();
}
