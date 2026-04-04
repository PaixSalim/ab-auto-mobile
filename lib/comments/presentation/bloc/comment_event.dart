part of 'comment_bloc.dart';

sealed class CommentEvent {
  const CommentEvent();
}

class FetchComments extends CommentEvent {
  final String productId; // Changé de int à String

  const FetchComments(this.productId);

  @override
  List<Object> get props => [productId];
}

class AddComment extends CommentEvent {
  final String productId; // Changé de int à String
  final String user;
  final String comment;

  const AddComment({
    required this.productId,
    required this.user,
    required this.comment,
  });

  @override
  List<Object> get props => [productId, user, comment];
}
