import 'package:auto/chatbot/domain/entity/chat_entity.dart';

class ChatMessageModel extends ChatMessageEntity {
  const ChatMessageModel({
    required super.id,
    required super.text,
    required super.isUser,
    required super.timestamp,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: json['text'] ?? "",
      isUser: false,
      timestamp: DateTime.now(),
    );
  }

  // Factory pour créer un message utilisateur
  factory ChatMessageModel.user({required String text}) {
    return ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );
  }

  // Factory pour créer un message assistant
  factory ChatMessageModel.assistant({required String text, String? initial}) {
    return ChatMessageModel(
      id: initial ?? DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: false,
      timestamp: DateTime.now(),
    );
  }
}

class PromptRequestModel extends PromptRequestEntity {
  const PromptRequestModel({required super.prompt, required super.type});

  Map<String, dynamic> toJson() => {'prompt': prompt, 'type': type};
}
