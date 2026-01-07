import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/assigned_surveys/assigned_surveys_bloc.dart';
import '../models/assignment.dart';
import '../models/survey_status.dart';
import 'widgets/survey_card.dart';
import 'widgets/survey_filter.dart';
import 'widgets/survey_search.dart';

class AssignedSurveysScreen extends StatefulWidget {
  const AssignedSurveysScreen({super.key});

  @override
  State<AssignedSurveysScreen> createState() => _AssignedSurveysScreenState();
}

class _AssignedSurveysScreenState extends State<AssignedSurveysScreen> {
  SurveyStatus? _statusFilter;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<AssignedSurveysBloc>().add(LoadAssignedSurveys());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: SurveySearch(
                  query: _searchQuery,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              SurveyFilter(
                status: _statusFilter,
                onStatusChanged: (value) {
                  setState(() {
                    _statusFilter = value;
                  });
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: BlocBuilder<AssignedSurveysBloc, AssignedSurveysState>(
            builder: (context, state) {
              if (state is AssignedSurveysLoading &&
                  state is! AssignedSurveysLoaded) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is AssignedSurveysError) {
                return Center(child: Text(state.message));
              }

              if (state is AssignedSurveysLoaded) {
                final assignments = _applyFilters(state.assignments);

                if (assignments.isEmpty) {
                  return const Center(child: Text('No assigned surveys'));
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: assignments.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final assignment = assignments[index];
                    return SurveyCard(
                      assignment: assignment,
                      onTap: () {
                        // TODO: Navigate to survey details
                      },
                    );
                  },
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }

  List<Assignment> _applyFilters(List<Assignment> assignments) {
    return assignments.where((a) {
      final survey = a.survey;

      // Status filter
      if (_statusFilter != null && survey?.status != _statusFilter) {
        return false;
      }

      // Search filter on survey title
      if (_searchQuery.isNotEmpty) {
        final title = survey?.title.toLowerCase() ?? '';
        if (!title.contains(_searchQuery.toLowerCase())) {
          return false;
        }
      }

      return true;
    }).toList();
  }
}


