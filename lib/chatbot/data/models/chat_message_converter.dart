import 'package:auto/chatbot/data/models/chat_message_model.dart';
import 'package:auto/chatbot/domain/entity/chat_entity.dart';
import 'package:objectbox/objectbox.dart';

// --- ENTITÉS OBJECTBOX ---

@Entity()
class ChatObjectBox {
  @Id()
  int id = 0;

  String? externalId;
  String? text;
  bool? isUser;
  String? timestamp;

  ChatObjectBox({
    int? id,
    this.text,
    this.isUser,
    this.timestamp,
    this.externalId,
  }) {
    if (id != null && id > 0) this.id = id;
  }

  // Conversion depuis BannerModel
  factory ChatObjectBox.fromModel(ChatMessageEntity model) {
    return ChatObjectBox(
      id: 0,
      externalId: model.id,
      text: model.text,
      isUser: model.isUser,
      timestamp: model.timestamp.toString(),
    );
  }

  // Conversion vers BrandModel
  ChatMessageModel toModel() {
    return ChatMessageModel(
      id: externalId,
      text: text,
      isUser: isUser,
      timestamp: DateTime.tryParse(timestamp!),
    );
  }
}
