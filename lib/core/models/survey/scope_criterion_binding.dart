import 'package:equatable/equatable.dart';

/// Inferred link from a survey question to a scope criterion. Populated by
/// `BindingInferer` after the survey is fetched and persisted on
/// `Survey.bindings` in the local cache.
class ScopeCriterionBinding extends Equatable {
  final int sourceQuestionId;
  final int scopeCriterionId;

  const ScopeCriterionBinding({
    required this.sourceQuestionId,
    required this.scopeCriterionId,
  });

  factory ScopeCriterionBinding.fromJson(Map<String, dynamic> json) {
    return ScopeCriterionBinding(
      sourceQuestionId: json['source_question_id'] as int,
      scopeCriterionId: json['scope_criterion_id'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'source_question_id': sourceQuestionId,
    'scope_criterion_id': scopeCriterionId,
  };

  @override
  List<Object?> get props => [sourceQuestionId, scopeCriterionId];
}
