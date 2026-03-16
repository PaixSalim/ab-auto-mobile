part of 'comment_bloc.dart';

sealed class CommentState {
  const CommentState();
}

final class CommentInitial extends CommentState {
  List<Object> get props => [];
}

class CommentsLoading extends CommentState {}

class CommentsLoaded extends CommentState {
  final List<CommentModel> comments;
  final CommentModel? lastAddedComment;

  const CommentsLoaded(this.comments, {this.lastAddedComment});

  List<Object> get props => [
        ...comments,
        if (lastAddedComment != null) lastAddedComment!,
      ];
}

class CommentsError extends CommentState {
  final String message;

  const CommentsError(this.message);

  List<Object> get props => [message];
}
