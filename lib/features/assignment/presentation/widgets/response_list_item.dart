import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/styles/app_colors.dart';
import '../../repository/assignment_local_repository.dart';
import '../../bloc/assignments_list/assignments_list_bloc.dart';
import 'delete_response_dialog.dart';

class ResponseListItem extends StatelessWidget {
  final int responseId;
  final int surveyId;

  const ResponseListItem({
    super.key,
    required this.responseId,
    required this.surveyId,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.assignment_outlined, size: 20, color: AppColors.secondaryText),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              s.response_number(responseId),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryText,
              ),
            ),
          ),
          _buildActionButton(
            label: s.resume_survey,
            icon: Icons.play_arrow_rounded,
            color: AppColors.primary,
            onPressed: () {
              // TODO: Navigate to survey continuation
            },
          ),
          const SizedBox(width: 8),
          _buildActionButton(
            label: s.delete,
            icon: Icons.delete_outline_rounded,
            color: AppColors.error,
            onPressed: () => _handleDelete(context),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => DeleteResponseDialog(responseId: responseId),
    );

    if (confirmed == true) {
      await AssignmentLocalRepository.removeResponseDraft(responseId);
      await AssignmentLocalRepository.unlinkResponseFromSurvey(surveyId, responseId);
      
      if (context.mounted) {
        // Refresh the assignments list to reflect changes
        context.read<AssignmentsListBloc>().add(LoadAssignments());
      }
    }
  }
}
