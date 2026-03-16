import 'package:auto/core/resources/data_state.dart';
import 'package:auto/core/usecases/usecase.dart';

import '../entities/comment_entity.dart';
import '../repositories/comment_repository_impl.dart';

class PostCommentUseCase implements Usecase {
  final CommentRepository _commentRepository;

  PostCommentUseCase(this._commentRepository);

  @override
  Future<DataState<CommentEntity>> call({params}) {
    return _commentRepository.postComment(params);
  }
}
