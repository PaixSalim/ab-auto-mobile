class CommentAuthorEntity {
  final String? id;
  final String? fullName;

  CommentAuthorEntity({this.id, this.fullName});
}

class CommentEntity {
  final String? id;
  final String? productId;
  final String? userId;
  final String? user;
  final String? comment;
  final String? createdAt;
  final bool? isActive;
  final String? parentId;
  final CommentAuthorEntity? author;

  CommentEntity({
    this.id,
    this.productId,
    this.userId,
    this.user,
    this.comment,
    this.createdAt,
    this.isActive,
    this.parentId,
    this.author,
  });
}
