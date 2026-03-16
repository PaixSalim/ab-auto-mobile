import 'package:auto/chatbot/data/models/chat_message_model.dart';
import 'package:auto/core/constants/constants.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'chat_remote_datasource_dio.g.dart';

//@RestApi(baseUrl: localAPIBaseUrl)
@RestApi(baseUrl: localAPIBaseUrl)
abstract class ChatRemoteDatasourceDio {
  factory ChatRemoteDatasourceDio(Dio dio) = _ChatRemoteDatasourceDio;

  @POST('/generate/chat')
  Future<HttpResponse<ChatMessageModel>> sendPrompt(
    @Body() PromptRequestModel body,
  );
}
