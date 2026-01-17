import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/generated/l10n.dart';
import '../../../core/routes/app_routes.dart';
import '../bloc/responses_list/responses_list_bloc.dart';
import '../../assignment/presentation/widgets/response_id_card.dart';

class ResponsesListScreen extends StatefulWidget {
  final int surveyId;

  const ResponsesListScreen({super.key, required this.surveyId});

  @override
  State<ResponsesListScreen> createState() => _ResponsesListScreenState();
}

class _ResponsesListScreenState extends State<ResponsesListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ResponsesListBloc>().add(
      LoadResponsesForSurvey(surveyId: widget.surveyId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
                final responseIds = state.responseIds;
                if (responseIds.isEmpty) {
                  return Center(child: Text(S.of(context).no_responses_found));
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: responseIds.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final rId = responseIds[index];
                    return ResponseIdCard(
                      responseId: rId,
                      onTap: () {
                        context.push(
                          Routes.completedResponseViewPath,
                          extra: {'responseId': rId},
                        );
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
}
