part of 'file_download_bloc.dart';

abstract class FileDownloadState {
  const FileDownloadState();
}

class FileDownloadInitial extends FileDownloadState {
  const FileDownloadInitial();
}

class FileDownloadLoading extends FileDownloadState {
  const FileDownloadLoading();
}

class FileDownloadProgress extends FileDownloadState {
  final int received;
  final int total;
  const FileDownloadProgress({required this.received, required this.total});

  double get progress => total > 0 ? received / total : 0;
}

class FileDownloadSuccess extends FileDownloadState {
  final String path;
  const FileDownloadSuccess({required this.path});
}

class FileDownloadError extends FileDownloadState {
  final String message;
  const FileDownloadError({required this.message});
}
