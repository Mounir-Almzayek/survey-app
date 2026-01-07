import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/l10n/generated/l10n.dart';
import '../bloc/responses_list/responses_list_bloc.dart';
import 'responses_list_screen.dart';

class ResponsesListPage extends StatelessWidget {
  final int surveyId;

  const ResponsesListPage({
    super.key,
    required this.surveyId,
  });

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);
    return BlocProvider(
      create: (_) => ResponsesListBloc(),
      child: Scaffold(
        appBar: AppBar(title: Text(locale.responses_title)),
        body: SafeArea(
          child: ResponsesListScreen(surveyId: surveyId),
        ),
      ),
    );
  }
}


