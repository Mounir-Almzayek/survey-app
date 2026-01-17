import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../utils/responsive_layout.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../l10n/generated/l10n.dart';
import '../../styles/app_colors.dart';
import '../models/request_queue_item.dart';
import 'queue_session/queue_session_bloc.dart';

class QueueSummaryDialog extends StatelessWidget {
  const QueueSummaryDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);

    return BlocBuilder<QueueSessionBloc, QueueSessionState>(
      builder: (context, state) {
        final items = state.items.values.toList()
          ..sort((a, b) => a.item.queuedAt.compareTo(b.item.queuedAt));

        if (items.isEmpty) {
          return const SizedBox.shrink();
        }

        return AlertDialog(
          title: Text(locale.queue_summary_title),
          content: SizedBox(
            width: double.maxFinite,
            height: 320,
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final vm = items[index];
                final item = vm.item;
                final result = vm.lastResponse;

                IconData icon;
                Color iconColor;
                String statusText;

                switch (item.status) {
                  case QueueItemStatus.pending:
                  case QueueItemStatus.processing:
                    icon = Icons.cloud_upload_rounded;
                    iconColor = Colors.orange;
                    statusText = locale.queue_status_processing;
                    break;
                  case QueueItemStatus.completed:
                    icon = Icons.check_circle_rounded;
                    iconColor = Colors.green;
                    statusText = locale.queue_status_completed;
                    break;
                  case QueueItemStatus.failed:
                    icon = Icons.error_rounded;
                    iconColor = Colors.red;
                    statusText = locale.queue_status_failed;
                    break;
                }

                final path = item.request.path;
                final method = item.request.method
                    .toString()
                    .split('.')
                    .last
                    .toUpperCase();

                String? responseStatusText;
                String? responseBodyText;
                final rawResponse = result?.response;
                if (rawResponse is Response) {
                  responseStatusText =
                      'Status: ${rawResponse.statusCode ?? '-'}';
                  responseBodyText = rawResponse.data?.toString();
                } else if (rawResponse != null) {
                  responseBodyText = rawResponse.toString();
                }

                return ExpansionTile(
                  leading: Icon(icon, color: iconColor),
                  title: Text(
                    item.metadata?['message'] as String? ?? '$method $path',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    statusText,
                    style: TextStyle(
                      color: item.status == QueueItemStatus.completed
                          ? Colors.green
                          : item.status == QueueItemStatus.failed
                          ? Colors.red
                          : Colors.orange,
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (item.request.body != null)
                            Text(
                              '${locale.queue_detail_body}: ${item.request.body}',
                              style: TextStyle(fontSize: context.adaptiveFont(12.sp)),
                            ),
                          if (item.status == QueueItemStatus.failed &&
                              result?.error != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              '${locale.queue_detail_error}: ${result!.error}',
                              style: TextStyle(
                                fontSize: context.adaptiveFont(12.sp),
                                color: Colors.red,
                              ),
                            ),
                          ],
                          if (responseStatusText != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              responseStatusText,
                              style: TextStyle(
                                fontSize: context.adaptiveFont(12.sp),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                          if (responseBodyText != null &&
                              responseBodyText.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              responseBodyText,
                              style: TextStyle(fontSize: context.adaptiveFont(12.sp)),
                              maxLines: 5,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          actions: [
            if (items.any((vm) => vm.item.status == QueueItemStatus.failed))
              TextButton(
                onPressed: () {
                  context.read<QueueSessionBloc>().add(const QueueSessionRetryAll());
                },
                child: Text(
                  locale.retry_all,
                  style: const TextStyle(color: AppColors.primary),
                ),
              ),
            TextButton(
              onPressed: () {
                context.read<QueueSessionBloc>().add(const QueueSessionClearAll());
              },
              child: Text(
                locale.clear_all,
                style: const TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                locale.ok,
                style: const TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        );
      },
    );
  }
}
