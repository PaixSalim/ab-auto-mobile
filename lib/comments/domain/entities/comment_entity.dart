class CommentEntity {
  final int? id;
  final int? productId;
  final String? user;
  final String? comment;
  final String? createdAt;

  CommentEntity({
    this.id,
    this.productId,
    this.user,
    this.comment,
    this.createdAt,
  });
}
