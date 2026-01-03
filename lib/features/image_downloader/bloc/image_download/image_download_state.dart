part of 'image_download_bloc.dart';

abstract class ImageDownloadState {
  const ImageDownloadState();
}

class ImageDownloadInitial extends ImageDownloadState {
  const ImageDownloadInitial();
}

class ImageDownloadLoading extends ImageDownloadState {
  const ImageDownloadLoading();
}

class ImageDownloadProgress extends ImageDownloadState {
  final int received;
  final int total;
  const ImageDownloadProgress({required this.received, required this.total});

  double get progress => total > 0 ? received / total : 0;
}

class ImageDownloadSuccess extends ImageDownloadState {
  final String path;
  const ImageDownloadSuccess({required this.path});
}

class ImageDownloadError extends ImageDownloadState {
  final String message;
  const ImageDownloadError({required this.message});
}
