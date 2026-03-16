import 'package:auto/app_database.dart';
import 'package:auto/chatbot/data/models/chat_message_converter.dart';
import 'package:auto/chatbot/data/models/chat_message_model.dart';
import 'package:auto/chatbot/domain/entity/chat_entity.dart';

class ChatLocalDataSource {
  final ObjectBoxService _objectBox;

  ChatLocalDataSource(this._objectBox);

  Future<void> cacheBanners(List<ChatMessageEntity> chats) async {
    final box = _objectBox.box<ChatObjectBox>();
    box.removeAll();
    box.putMany(chats.map((e) => ChatObjectBox.fromModel(e)).toList());
  }

  Future<List<ChatMessageModel>> getBanners() async {
    final box = _objectBox.box<ChatObjectBox>();
    return box.getAll().map((e) => e.toModel()).toList();
  }
}
