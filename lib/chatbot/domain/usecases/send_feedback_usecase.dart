import 'package:auto/chatbot/domain/repository/chat_repository.dart';
import 'package:auto/core/usecases/usecase.dart';

class SendFeedbackUseCase implements Usecase {
  final ChatMessageRepository _chatMessageRepository;

  SendFeedbackUseCase(this._chatMessageRepository);

  @override
  Future call({params}) {
    return _chatMessageRepository.sendFeedback(params);
  }
}
