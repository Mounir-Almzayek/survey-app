import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/widgets/loading_widget.dart';
import '../bloc/image_download/image_download_bloc.dart';

/// Network Image Viewer
/// Widget for viewing and downloading network images
class NetworkImageViewer extends StatelessWidget {
  final String imageUrl;
  final String? placeholder;
  final BoxFit fit;

  const NetworkImageViewer({
    super.key,
    required this.imageUrl,
    this.placeholder,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ImageDownloadBloc(),
      child: BlocBuilder<ImageDownloadBloc, ImageDownloadState>(
        builder: (context, state) {
          return Stack(
            children: [
              Image.network(
                imageUrl,
                fit: fit,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const LoadingWidget();
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.error, size: 48);
                },
              ),
              if (state is ImageDownloadLoading ||
                  state is ImageDownloadProgress)
                const Positioned.fill(
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        },
      ),
    );
  }
}
