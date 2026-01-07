import 'package:equatable/equatable.dart';

import '../../surveys/models/survey.dart';
import '../../surveys/models/assignment.dart';
import '../../public_links/models/public_link.dart';
import 'response_answer.dart';
import 'response_status.dart';

/// Detailed response model matching ResponseService.getDetails shape.
///
/// NOTE: This is a best-effort mapping based on admin API usage; adjust if
/// backend changes the exact fields.
class ResponseDetails extends Equatable {
  final int id;
  final ResponseStatus status;
  final Survey survey;
  final Assignment? assignment;
  final PublicLink? publicLink;
  final List<ResponseAnswer> answers;

  const ResponseDetails({
    required this.id,
    required this.status,
    required this.survey,
    this.assignment,
    this.publicLink,
    this.answers = const [],
  });

  factory ResponseDetails.fromJson(Map<String, dynamic> json) {
    return ResponseDetails(
      id: json['id'] as int,
      status: ResponseStatusX.fromString(json['status'] as String? ?? 'DRAFT'),
      survey: Survey.fromJson(json['survey'] as Map<String, dynamic>),
      assignment: json['assignment'] is Map<String, dynamic>
          ? Assignment.fromJson(json['assignment'] as Map<String, dynamic>)
          : null,
      publicLink: json['public_link'] is Map<String, dynamic>
          ? PublicLink.fromJson(json['public_link'] as Map<String, dynamic>)
          : null,
      answers: (json['answers'] as List<dynamic>? ?? [])
          .map(
            (a) => ResponseAnswer.fromJson(a as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        status,
        survey,
        assignment,
        publicLink,
        answers,
      ];
}


