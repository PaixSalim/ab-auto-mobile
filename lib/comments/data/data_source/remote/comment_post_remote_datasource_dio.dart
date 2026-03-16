import 'package:auto/comments/data/models/comment_model.dart';
import 'package:auto/comments/data/models/comment_post_model.dart';
import 'package:auto/core/constants/constants.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'comment_post_remote_datasource_dio.g.dart';

@RestApi(baseUrl: localAPIBaseUrl)
abstract class CommentPostRemoteDatasourceDio {
  factory CommentPostRemoteDatasourceDio(Dio dio) =
      _CommentPostRemoteDatasourceDio;

  @POST('/comment')
  Future<HttpResponse<CommentModel>> postComment(@Body() CommentPostModel body);
}
