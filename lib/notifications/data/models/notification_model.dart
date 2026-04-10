import 'package:objectbox/objectbox.dart';

@Entity()
class NotificationObjectBox {
  @Id()
  int id = 0;

  String? title;
  String? body;
  String? type; // e.g., 'promotion_created'
  String? data; // JSON representation of extra data
  DateTime? receivedAt;
  bool isRead = false;

  NotificationObjectBox({
    this.id = 0,
    this.title,
    this.body,
    this.type,
    this.data,
    this.receivedAt,
    this.isRead = false,
  });
}
