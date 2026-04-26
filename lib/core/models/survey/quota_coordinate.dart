import 'package:equatable/equatable.dart';

/// One axis of a [QuotaTarget]'s identity. The full coordinate set of a target
/// uniquely identifies it within a sampling scope.
class QuotaCoordinate extends Equatable {
  final int scopeCriterionId;
  final String criterionName;
  final int scopeCriterionCategoryId;
  final String categoryLabel;
  final String categoryValue;
  final int order;

  const QuotaCoordinate({
    required this.scopeCriterionId,
    required this.criterionName,
    required this.scopeCriterionCategoryId,
    required this.categoryLabel,
    required this.categoryValue,
    required this.order,
  });

  factory QuotaCoordinate.fromJson(Map<String, dynamic> json) {
    return QuotaCoordinate(
      scopeCriterionId: json['scope_criterion_id'] as int,
      criterionName: json['criterion_name'] as String,
      scopeCriterionCategoryId: json['scope_criterion_category_id'] as int,
      categoryLabel: json['category_label'] as String,
      categoryValue: json['category_value'] as String,
      order: json['order'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'scope_criterion_id': scopeCriterionId,
    'criterion_name': criterionName,
    'scope_criterion_category_id': scopeCriterionCategoryId,
    'category_label': categoryLabel,
    'category_value': categoryValue,
    'order': order,
  };

  @override
  List<Object?> get props => [
    scopeCriterionId,
    criterionName,
    scopeCriterionCategoryId,
    categoryLabel,
    categoryValue,
    order,
  ];
}
