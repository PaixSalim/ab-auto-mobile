import 'package:auto/chatbot/data/models/feedback_model.dart';
import 'package:auto/core/constants/constants.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'feedback_remote_datasource_dio.g.dart';

@RestApi(baseUrl: localAPIBaseUrl)
abstract class FeedbackRemoteDatasourceDio {
  factory FeedbackRemoteDatasourceDio(Dio dio) = _FeedbackRemoteDatasourceDio;

  @POST('/generate/feedback')
  Future<HttpResponse<FeedbackResponseModel>> sendFeedback(
    @Body() FeedbackModel body,
  );
}
