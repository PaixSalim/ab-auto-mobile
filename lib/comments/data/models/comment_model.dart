import 'package:auto/comments/domain/entities/comment_entity.dart';

class CommentModel extends CommentEntity {
  CommentModel({
    super.id,
    super.productId,
    super.userId,
    super.user,
    super.comment,
    super.createdAt,
    super.isActive,
    super.parentId,
    super.author,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id']?.toString(),
      productId: json['productId']?.toString() ?? json['product_id']?.toString(),
      userId: json['userId']?.toString() ?? json['user_id']?.toString(),
      user: json['user'],
      comment: json['comment'] ?? json['content'], // Fallback to content if comment is missing
      createdAt: json['createdAt'] ?? json['created_at'], // Map both camelCase and snake_case
      isActive: json['isActive'] ?? json['is_active'] ?? true,
      parentId: json['parentId']?.toString() ?? json['parent_id']?.toString(),
      author:
          json['author'] != null
              ? CommentAuthorEntity(
                id: json['author']['id']?.toString(),
                fullName: json['author']['fullName'] ?? json['author']['full_name'],
              )
              : null,
    );
  }

  @override
  String toString() {
    return "CommentModel:(id: $id, productId: $productId, user: $user, comment: $comment, createdAt: $createdAt)";
  }
}
