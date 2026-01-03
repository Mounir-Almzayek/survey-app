part of 'image_download_bloc.dart';

abstract class ImageDownloadEvent {
  const ImageDownloadEvent();
}

class ImageDownloadStarted extends ImageDownloadEvent {
  final String url;
  final String savePath;
  const ImageDownloadStarted({required this.url, required this.savePath});
}

class ImageDownloadCancelled extends ImageDownloadEvent {
  const ImageDownloadCancelled();
}
