part of 'chat_bloc.dart';

class ChatState {
  final List<ChatMessageModel>? messages;
  final bool? isTyping;
  final bool? isChatOpen;
  final FeedbackResponseModel? feedbackResponse;
  final DioException? error;

  final ChatMessageEntity? message;
  const ChatState({
    this.messages,
    this.isTyping,
    this.isChatOpen,
    this.feedbackResponse,
    this.message,
    this.error,
  });

  // Copier avec de nouvelles valeurs
  ChatState copyWith({
    List<ChatMessageModel>? messages,
    bool? isTyping,
    bool? isChatOpen,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
      isChatOpen: isChatOpen ?? this.isChatOpen,
    );
  }

  List<Object> get props => [message!, isTyping!, isChatOpen!, error!];
}

final class ChatInitial extends ChatState {
  ChatInitial()
    : super(
        messages: [
          ChatMessageModel.assistant(
            initial: 'initial',
            text:
                "Bonjour ! Besoin d’aide pour trouver une pièce ou un produit ? Je suis là pour vous simplifier la tâche.",
          ),
        ],
        isTyping: false,
        isChatOpen: false,
      );
}

final class LocalMessagesLoading extends ChatState {
  const LocalMessagesLoading();
}

final class LocalMessagesDone extends ChatState {
  const LocalMessagesDone(List<ChatMessageModel> messages)
    : super(messages: messages);
}

final class RemoteMessageDone extends ChatState {
  const RemoteMessageDone(ChatMessageEntity message) : super(message: message);
}

final class RemoteMessageError extends ChatState {
  const RemoteMessageError(DioException error) : super(error: error);
}

final class FeedbackSent extends ChatState {
  const FeedbackSent(FeedbackResponseModel feedbackResponse)
    : super(feedbackResponse: feedbackResponse);
}
