import 'dart:io';

import 'package:auto/comments/data/data_source/remote/comment_post_remote_datasource_dio.dart';
import 'package:auto/comments/data/data_source/remote/comment_remote_datasource_dio.dart';
import 'package:auto/comments/data/models/comment_model.dart';
import 'package:auto/comments/data/models/comment_post_model.dart';
import 'package:auto/comments/domain/entities/comment_entity.dart';
import 'package:auto/comments/domain/entities/comment_post_entity.dart';
import 'package:auto/comments/domain/repositories/comment_repository_impl.dart';
import 'package:auto/core/resources/data_state.dart';
import 'package:auto/core/resources/network_info.dart';
import 'package:dio/dio.dart';

class CommentRepositoryImpl implements CommentRepository {
  final CommentPostRemoteDatasourceDio _postRemoteDatasourceDio;
  final CommentRemoteDatasourceDio _remoteDatasourceDio;
  final NetworkInfo _networkInfo;

  CommentRepositoryImpl(
    this._postRemoteDatasourceDio,
    this._remoteDatasourceDio,
    this._networkInfo,
  );
  
  @override
  Future<DataState<List<CommentModel>>> getComments(String productId) async {
    if (await _networkInfo.isConnected) {
      try {
                final httpResponse = await _remoteDatasourceDio.getComments(
          productId: productId,
        );
                
        if (httpResponse.response.statusCode == HttpStatus.ok) {
                    return DataSuccess(httpResponse.data);
        } else {
          final errorMsg = httpResponse.response.data?['message'] ?? 
                          httpResponse.response.statusMessage ?? 
                          'Erreur serveur';
                    return DataFailed(
            DioException(
              requestOptions: httpResponse.response.requestOptions,
              error: errorMsg,
              response: httpResponse.response,
              type: DioExceptionType.badResponse,
            ),
          );
        }
      } on DioException catch (e) {
                        return DataFailed(e);
      } catch (e) {
                return DataFailed(
          DioException(
            requestOptions: RequestOptions(),
            error: e.toString(),
            type: DioExceptionType.unknown,
          ),
        );
      }
    } else {
      return DataFailed(
        DioException(
          requestOptions: RequestOptions(),
          error: 'No Internet Connection',
          type: DioExceptionType.unknown,
        ),
      );
    }
  }

  @override
  Future<DataState<CommentEntity>> postComment(CommentPostEntity comment) async {
    if (await _networkInfo.isConnected) {
      try {
        final commentModel = CommentPostModel(
          productId: comment.productId,
          user: comment.user,
          comment: comment.comment,
          userId: comment.userId,
        );
                
        final httpResponse = await _postRemoteDatasourceDio.postComment(
          commentModel,
        );
        
                        
        if (httpResponse.response.statusCode == HttpStatus.ok || 
            httpResponse.response.statusCode == HttpStatus.created) {
          return DataSuccess(httpResponse.data);
        } else {
          // Extract error message from response
          final errorMsg = httpResponse.response.data?['message'] ?? 
                          httpResponse.response.data?['error'] ?? 
                          httpResponse.response.statusMessage ?? 
                          'Erreur serveur';
                    return DataFailed(
            DioException(
              requestOptions: httpResponse.response.requestOptions,
              error: errorMsg,
              response: httpResponse.response,
              type: DioExceptionType.badResponse,
            ),
          );
        }
      } on DioException catch (e) {
                        return DataFailed(e);
      } catch (e) {
                return DataFailed(
          DioException(
            requestOptions: RequestOptions(),
            error: e.toString(),
            type: DioExceptionType.unknown,
          ),
        );
      }
    } else {
      return DataFailed(
        DioException(
          requestOptions: RequestOptions(),
          error: 'No Internet Connection',
          type: DioExceptionType.unknown,
        ),
      );
    }
  }
}
