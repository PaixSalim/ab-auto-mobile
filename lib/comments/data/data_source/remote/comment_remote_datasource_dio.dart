import 'package:auto/comments/data/models/comment_model.dart';
import 'package:auto/core/constants/constants.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'comment_remote_datasource_dio.g.dart';

@RestApi(baseUrl: localAPIBaseUrl)
abstract class CommentRemoteDatasourceDio {
  factory CommentRemoteDatasourceDio(Dio dio) = _CommentRemoteDatasourceDio;

  @GET('/comments')
  Future<HttpResponse<List<CommentModel>>> getComments({
    @Query("productId") int? productId,
  });
}
