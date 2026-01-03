/// Download Progress Model
/// Represents download progress data
class DownloadProgress {
  final int received;
  final int total;
  final double progress;

  DownloadProgress({
    required this.received,
    required this.total,
  }) : progress = total > 0 ? received / total : 0.0;

  bool get isComplete => received >= total;
}
