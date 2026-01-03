class ResearcherLoginInitiateResponse {
  final String method;
  final Map<String, dynamic>? options;

  ResearcherLoginInitiateResponse({required this.method, this.options});

  factory ResearcherLoginInitiateResponse.fromJson(Map<String, dynamic> json) {
    return ResearcherLoginInitiateResponse(
      method: json['method'] ?? '',
      options: json['options'],
    );
  }
}
