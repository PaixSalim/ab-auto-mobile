import 'package:auto/comments/domain/entities/comment_post_entity.dart';

class CommentPostModel extends CommentPostEntity {
  CommentPostModel({
    super.productId,
    super.user,
    super.comment,
    String? userId,
  }) : super(userId: userId);

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'user': user,
    'comment': comment,
    if (userId != null) 'userId': userId,
  };

  @override
  String toString() {
    return "CommentPostModel:(productId: $productId, user: $user, comment: $comment, userId: $userId)";
  }
}
