import 'package:auto/comments/domain/entities/comment_entity.dart';

class CommentModel extends CommentEntity {
  CommentModel({
    super.id,
    super.productId,
    super.user,
    super.comment,
    super.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'],
      productId: json['productId'],
      user: json['user'],
      comment: json['comment'],
      createdAt: json['createdAt'],
    );
  }

  @override
  String toString() {
    return "CommentModel:(id: $id, productId: $productId, user: $user, comment: $comment, createdAt: $createdAt)";
  }
}
