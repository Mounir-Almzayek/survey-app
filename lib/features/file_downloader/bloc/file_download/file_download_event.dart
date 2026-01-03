part of 'file_download_bloc.dart';

abstract class FileDownloadEvent {
  const FileDownloadEvent();
}

class FileDownloadStarted extends FileDownloadEvent {
  final String url;
  final String savePath;
  const FileDownloadStarted({required this.url, required this.savePath});
}

class FileDownloadCancelled extends FileDownloadEvent {
  const FileDownloadCancelled();
}
