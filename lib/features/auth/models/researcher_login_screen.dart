class ResearcherLoginScreen {
  final int width;
  final int height;

  const ResearcherLoginScreen({this.width = 0, this.height = 0});

  Map<String, dynamic> toJson() => {'width': width, 'height': height};
}
