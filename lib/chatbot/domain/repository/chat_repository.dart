import 'package:auto/chatbot/data/models/chat_message_model.dart';
import 'package:auto/chatbot/data/models/feedback_model.dart';
import 'package:auto/core/resources/data_state.dart';

abstract class ChatMessageRepository {
  Future<DataState<ChatMessageModel>> sendPrompt(PromptRequestModel prompt);
  Future<DataState<FeedbackResponseModel>> sendFeedback(FeedbackModel feedback);
}
