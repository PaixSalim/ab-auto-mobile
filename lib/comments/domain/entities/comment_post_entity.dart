class CommentPostEntity {
  final String? productId; // Changé de int à String
  final String? user;
  final String? comment;
  final String? userId;

  CommentPostEntity({this.productId, this.user, this.comment, this.userId});
}
