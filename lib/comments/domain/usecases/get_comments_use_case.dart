import 'package:auto/comments/domain/repositories/comment_repository_impl.dart';
import 'package:auto/core/resources/data_state.dart';
import 'package:auto/core/usecases/usecase.dart';

import '../entities/comment_entity.dart';

class GetCommentUseCase implements Usecase {
  final CommentRepository _commentRepository;

  GetCommentUseCase(this._commentRepository);
  @override
  Future<DataState<List<CommentEntity>>> call({params}) {
    return _commentRepository.getComments(params);
  }
}
