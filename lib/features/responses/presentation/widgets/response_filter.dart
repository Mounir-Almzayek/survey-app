import 'package:flutter/material.dart';

import '../../models/response_status.dart';

class ResponseFilter extends StatelessWidget {
  final ResponseStatus? status;
  final ValueChanged<ResponseStatus?> onChanged;

  const ResponseFilter({
    super.key,
    required this.status,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<ResponseStatus?>(
        value: status,
        hint: const Text('Status'),
        onChanged: onChanged,
        items: const [
          DropdownMenuItem<ResponseStatus?>(
            value: null,
            child: Text('All'),
          ),
          DropdownMenuItem<ResponseStatus>(
            value: ResponseStatus.draft,
            child: Text('Draft'),
          ),
          DropdownMenuItem<ResponseStatus>(
            value: ResponseStatus.submitted,
            child: Text('Submitted'),
          ),
          DropdownMenuItem<ResponseStatus>(
            value: ResponseStatus.flagged,
            child: Text('Flagged'),
          ),
          DropdownMenuItem<ResponseStatus>(
            value: ResponseStatus.rejected,
            child: Text('Rejected'),
          ),
        ],
      ),
    );
  }
}


