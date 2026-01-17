import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/l10n/generated/l10n.dart';
import '../../../core/widgets/error_state_widget.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/widgets/unified_snackbar.dart';
import '../bloc/file_download/file_download_bloc.dart';

/// Network File Viewer
/// Widget for viewing and downloading network files
class NetworkFileViewer extends StatelessWidget {
  final String url;
  final String fileName;

  const NetworkFileViewer({
    super.key,
    required this.url,
    required this.fileName,
  });

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);
    return BlocProvider(
      create: (_) => FileDownloadBloc(),
      child: BlocBuilder<FileDownloadBloc, FileDownloadState>(
        builder: (context, state) {
          if (state is FileDownloadLoading || state is FileDownloadProgress) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LoadingWidget(message: locale.downloading),
                if (state is FileDownloadProgress)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        LinearProgressIndicator(value: state.progress),
                        const SizedBox(height: 8),
                        Text(
                          '${(state.progress * 100).toStringAsFixed(1)}%',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<FileDownloadBloc>().add(
                      const FileDownloadCancelled(),
                    );
                  },
                  child: Text(locale.cancel_download),
                ),
              ],
            );
          }

          if (state is FileDownloadError) {
            return ErrorStateWidget(
              message: state.message,
              onRetry: () {
                context.read<FileDownloadBloc>().add(
                  FileDownloadStarted(url: url, savePath: fileName),
                );
              },
            );
          }

          if (state is FileDownloadSuccess) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: context.adaptiveIcon(48.sp)),
                const SizedBox(height: 16),
                Text('${locale.file_downloaded_colon} ${state.path}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Implement file opening logic
                    UnifiedSnackbar.success(
                      context,
                      message: locale.file_downloaded_successfully,
                    );
                  },
                  child: Text(locale.file_ready),
                ),
              ],
            );
          }

          return ElevatedButton(
            onPressed: () {
              context.read<FileDownloadBloc>().add(
                FileDownloadStarted(url: url, savePath: fileName),
              );
            },
            child: Text(locale.download_file),
          );
        },
      ),
    );
  }
}
