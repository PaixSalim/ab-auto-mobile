import 'package:auto/comments/data/dto/comment_dto.dart';
import 'package:auto/comments/data/models/comment_model.dart';
import 'package:auto/comments/domain/entities/comment_post_entity.dart';
import 'package:auto/comments/domain/usecases/get_comments_use_case.dart';
import 'package:auto/comments/domain/usecases/post_comment_use_case.dart';
import 'package:auto/core/resources/data_state.dart';
import 'package:auto/core/resources/local_storage_service.dart';
import 'package:bloc/bloc.dart';

part 'comment_event.dart';
part 'comment_state.dart';

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  final PostCommentUseCase _postCommentUseCase;
  final GetCommentUseCase _getCommentUseCase;
  CommentBloc(this._postCommentUseCase, this._getCommentUseCase)
    : super(CommentInitial()) {
    on<FetchComments>(_onFetchProductComments);
    on<AddComment>(_onAddProductComment);
  }

  Future<void> _onFetchProductComments(
    FetchComments event,
    Emitter<CommentState> emit,
  ) async {
    emit(CommentsLoading());
    try {
            final dataState = await _getCommentUseCase(params: event.productId);
      if (dataState is DataSuccess) {
                final comments =
            dataState.data!
                .map<CommentModel>((e) => CommentDto.getToModel(e))
                .toList();

        emit(CommentsLoaded(comments));
      }
      if (dataState is DataFailed) {
        final errorMsg = dataState.error?.message ?? 'Erreur inconnue';
                emit(CommentsError('Erreur lors du chargement des commentaires: $errorMsg'));
      }
    } catch (e) {
            emit(CommentsError('Erreur lors du chargement des commentaires: ${e.toString()}'));
    }
  }

  Future<void> _onAddProductComment(
    AddComment event,
    Emitter<CommentState> emit,
  ) async {
    try {
            
      // Get userId from local storage (should be UUID, not phone/email)
      final userId = LocalStorageService.userId;
            
      final newComment = CommentPostEntity(
        productId: event.productId,
        user: event.user,
        comment: event.comment,
        userId: userId, // Now using actual UUID
      );
            
      final dataState = await _postCommentUseCase(params: newComment);

      if (dataState is DataSuccess) {
                final returnComment = CommentDto.getToModel(dataState.data!);
        final currentComments = (state as CommentsLoaded).comments;
        final updatedComments =
            [
              returnComment,
              ...currentComments,
            ].map<CommentModel>((m) => CommentDto.getToModel(m)).toList();

        emit(CommentsLoaded(updatedComments, lastAddedComment: returnComment));
      }
      if (dataState is DataFailed) {
        final errorMsg = dataState.error?.message ?? 'Erreur inconnue';
                emit(CommentsError('Erreur lors de l\'ajout du commentaire: $errorMsg'));
      }
    } catch (e) {
            emit(
        CommentsError(
          'Erreur lors de l\'ajout du commentaire: ${e.toString()}',
        ),
      );
    }
  }
}
