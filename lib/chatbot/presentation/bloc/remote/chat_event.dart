part of 'chat_bloc.dart';

sealed class ChatEvent {
  const ChatEvent();
}

class GetLocalMessages extends ChatEvent {
  const GetLocalMessages();
}

class SendPrompt extends ChatEvent {
  final PromptRequestModel prompt;
  SendPrompt(this.prompt);
}

class ChatInitialized extends ChatEvent {
  const ChatInitialized();
}

class MessageSent extends ChatEvent {
  final String message;

  const MessageSent(this.message);

  List<Object> get props => [message];
}

class MessageReceived extends ChatEvent {
  final ChatMessageModel message;

  const MessageReceived(this.message);

  List<Object> get props => [message];
}

class TypingStarted extends ChatEvent {
  const TypingStarted();
}

class TypingStopped extends ChatEvent {
  const TypingStopped();
}

class ChatToggled extends ChatEvent {
  const ChatToggled();
}

class SendFeedbackEvent extends ChatEvent {
  final FeedbackModel feedback;

  SendFeedbackEvent(this.feedback);
}
