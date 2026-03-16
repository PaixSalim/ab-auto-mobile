import 'package:auto/comments/domain/entities/comment_entity.dart';
import 'package:auto/comments/domain/entities/comment_post_entity.dart';
import 'package:auto/core/resources/data_state.dart';

abstract class CommentRepository {
  Future<DataState<List<CommentEntity>>> getComments(int productId);
  Future<DataState<CommentEntity>> postComment(CommentPostEntity comment);
}
