import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/l10n/generated/l10n.dart';
import '../bloc/responses_list/responses_list_bloc.dart';
import '../models/response.dart';
import '../models/response_status.dart';
import 'widgets/response_card.dart';
import 'widgets/response_filter.dart';

class ResponsesListScreen extends StatefulWidget {
  final int surveyId;

  const ResponsesListScreen({
    super.key,
    required this.surveyId,
  });

  @override
  State<ResponsesListScreen> createState() => _ResponsesListScreenState();
}

class _ResponsesListScreenState extends State<ResponsesListScreen> {
  ResponseStatus? _statusFilter;

  @override
  void initState() {
    super.initState();
    context
        .read<ResponsesListBloc>()
        .add(LoadResponsesForSurvey(surveyId: widget.surveyId));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ResponseFilter(
                status: _statusFilter,
                onChanged: (value) {
                  setState(() {
                    _statusFilter = value;
                  });
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: BlocBuilder<ResponsesListBloc, ResponsesListState>(
            builder: (context, state) {
              if (state is ResponsesListLoading &&
                  state is! ResponsesListLoaded) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is ResponsesListError) {
                return Center(child: Text(state.message));
              }

              if (state is ResponsesListLoaded) {
                final responses = _applyFilters(state.responses);
                if (responses.isEmpty) {
                  return Center(
                    child: Text(S.of(context).no_responses_found),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: responses.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final r = responses[index];
                    return ResponseCard(
                      response: r,
                      // TODO: wire to navigation for view/review when routes exist.
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

  List<ResponseSummary> _applyFilters(List<ResponseSummary> responses) {
    return responses.where((r) {
      if (_statusFilter != null && r.status != _statusFilter) {
        return false;
      }
      return true;
    }).toList();
  }
}


