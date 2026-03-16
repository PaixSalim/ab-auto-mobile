import 'dart:io';

import 'package:auto/chatbot/data/data_source/remote/chat_remote_datasource_dio.dart';
import 'package:auto/chatbot/data/models/chat_message_model.dart';
import 'package:auto/chatbot/data/models/feedback_model.dart';
import 'package:auto/chatbot/domain/repository/chat_repository.dart';
import 'package:auto/core/resources/data_state.dart';
import 'package:auto/core/resources/network_info.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../data_source/remote/feedback_remote_datasource_dio.dart';

class ChatMessageRepositoryImpl implements ChatMessageRepository {
  final ChatRemoteDatasourceDio _remote;
  final FeedbackRemoteDatasourceDio _feedbackRemote;
  final NetworkInfo _network;

  ChatMessageRepositoryImpl(this._remote, this._feedbackRemote, this._network);

  @override
  Future<DataState<ChatMessageModel>> sendPrompt(
    PromptRequestModel prompt,
  ) async {
    try {
      final httpResponse = await _remote.sendPrompt(prompt);
      if (httpResponse.response.statusCode == HttpStatus.ok) {
        return DataSuccess(httpResponse.data);
      } else {
        return DataFailed(
          DioException(
            requestOptions: httpResponse.response.requestOptions,
            error: httpResponse.response.statusMessage,
            type: DioExceptionType.badResponse,
          ),
        );
      }
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<FeedbackResponseModel>> sendFeedback(
    FeedbackModel feedback,
  ) async {
    if (await _network.isConnected) {
      try {
        debugPrint('Envoi du feedback: $feedback');
        final httpResponse = await _feedbackRemote.sendFeedback(feedback);
        if (httpResponse.response.statusCode == HttpStatus.ok) {
          debugPrint('Response: ${httpResponse.data.isSent}');
          return DataSuccess(httpResponse.data);
        } else {
          return DataFailed(
            DioException(
              requestOptions: httpResponse.response.requestOptions,
              error: httpResponse.response.statusMessage,
              type: DioExceptionType.badResponse,
            ),
          );
        }
      } on DioException catch (e) {
        return DataFailed(e);
      }
    } else {
      return DataSuccess(FeedbackResponseModel(isSent: false));
    }
  }
}
