import 'package:auto/chatbot/data/models/chat_message_model.dart';
import 'package:auto/chatbot/domain/repository/chat_repository.dart';
import 'package:auto/core/resources/data_state.dart';
import 'package:auto/core/usecases/usecase.dart';

class SendPromptUseCase implements Usecase {
  final ChatMessageRepository _chatMessageRepository;

  SendPromptUseCase(this._chatMessageRepository);
  @override
  Future<DataState<ChatMessageModel>> call({params}) {
    return _chatMessageRepository.sendPrompt(params);
  }
}
