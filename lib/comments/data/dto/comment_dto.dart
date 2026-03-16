import 'package:auto/comments/data/models/comment_post_model.dart';
import 'package:auto/comments/domain/entities/comment_entity.dart';
import 'package:auto/comments/domain/entities/comment_post_entity.dart';

import '../models/comment_model.dart';

class CommentDto {
  static postToModel(CommentPostEntity entity) {
    return CommentPostModel(
      user: entity.user,
      comment: entity.comment,
      productId: entity.productId,
    );
  }

  static getToModel(CommentEntity entity) {
    return CommentModel(
      id: entity.id,
      user: entity.user,
      comment: entity.comment,
      productId: entity.productId,
      createdAt: entity.createdAt,
    );
  }
}
