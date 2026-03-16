class ChatMessageEntity {
  final String? id;
  final String? text;
  final bool? isUser;
  final DateTime? timestamp;

  const ChatMessageEntity({this.id, this.text, this.isUser, this.timestamp});
}

class PromptRequestEntity {
  final String? prompt;
  final String? type;

  const PromptRequestEntity({this.prompt, this.type});
}
