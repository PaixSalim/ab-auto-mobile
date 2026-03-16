import 'package:auto/comments/domain/entities/comment_post_entity.dart';

class CommentPostModel extends CommentPostEntity {
  CommentPostModel({super.productId, super.user, super.comment});

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'user': user,
    'comment': comment,
  };

  @override
  String toString() {
    return "CommentPostModel:(productId: $productId, user: $user, comment: $comment)";
  }
}
