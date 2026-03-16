class FeedbackModel {
  final String request;
  final String response;
  final bool isPositive;
  final List<String> selectedOptions;
  final String? additionalInfo;

  FeedbackModel({
    required this.request,
    required this.response,
    required this.isPositive,
    required this.selectedOptions,
    this.additionalInfo,
  });

  Map<String, dynamic> toJson() => {
    'request': request,
    'response': response,
    'isPositive': isPositive,
    'selectedOptions': selectedOptions,
    if (additionalInfo != null && additionalInfo!.isNotEmpty)
      'additionalInfo': additionalInfo,
  };

  @override
  String toString() {
    return 'FeedbackModel(request: $request, response: $response, isPositive: $isPositive, selectedOptions: , additionalInfo: $additionalInfo)';
  }
}

class FeedbackResponseModel {
  final bool? isSent;

  FeedbackResponseModel({this.isSent});

  factory FeedbackResponseModel.fromJson(Map<String, dynamic> json) {
    return FeedbackResponseModel(isSent: json['isSent'] ?? false);
  }
}
