import 'package:auto/chatbot/data/models/chat_message_model.dart';
import 'package:auto/chatbot/data/models/feedback_model.dart';
import 'package:auto/chatbot/domain/entity/chat_entity.dart';
import 'package:auto/chatbot/domain/usecases/send_feedback_usecase.dart';
import 'package:auto/chatbot/domain/usecases/send_prompt_usecase.dart';
import 'package:auto/core/resources/data_state.dart';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final SendPromptUseCase _sendPromptUseCase;
  final SendFeedbackUseCase _sendFeedbackUseCase;
  ChatBloc(this._sendPromptUseCase, this._sendFeedbackUseCase)
    : super(ChatInitial()) {
    on<SendPrompt>(_onSendPrompt);
    on<ChatInitialized>(_onChatInitialized);
    on<MessageSent>(_onMessageSent);
    on<MessageReceived>(_onMessageReceived);
    on<TypingStarted>(_onTypingStarted);
    on<TypingStopped>(_onTypingStopped);
    on<ChatToggled>(_onChatToggled);
    on<SendFeedbackEvent>(_onSendFeedbackEvent);
  }

  Future<void> _onSendFeedbackEvent(
    SendFeedbackEvent event,
    Emitter<ChatState> emit,
  ) async {
    final FeedbackModel feedback = event.feedback;
    final dataState = await _sendFeedbackUseCase(params: feedback);

    if (dataState is DataSuccess) {
      //emit(FeedbackSent(dataState.data));
    }

    if (dataState is DataFailed) {
      //emit(RemoteMessageError(dataState.error!));
    }
  }

  Future<void> _onSendPrompt(SendPrompt event, Emitter<ChatState> emit) async {
    final PromptRequestModel prompt = event.prompt;
    final dataState = await _sendPromptUseCase(params: prompt);

    if (dataState is DataSuccess) {
      emit(RemoteMessageDone(dataState.data!));
    }
    if (dataState is DataFailed) {
      emit(RemoteMessageError(dataState.error!));
    }
  }

  void _onChatInitialized(ChatInitialized event, Emitter<ChatState> emit) {
    // Rien à faire ici, l'état initial est déjà configuré
  }

  Future<void> _onMessageSent(
    MessageSent event,
    Emitter<ChatState> emit,
  ) async {
    if (event.message.trim().isEmpty || state.isTyping!) return;

    final userMessage = ChatMessageModel.user(text: event.message);
    emit(state.copyWith(messages: List.of(state.messages!)..add(userMessage)));

    add(const TypingStarted());

    final PromptRequestModel prompt = PromptRequestModel(
      prompt: event.message,
      type: 'chat',
    );
    final dataState = await _sendPromptUseCase(params: prompt);

    if (dataState is DataSuccess) {
      add(const TypingStopped());

      add(MessageReceived(dataState.data!));
      //emit(RemoteMessageDone(dataState.data!));
    }
    if (dataState is DataFailed) {
      add(const TypingStopped());
      final errorMessage = ChatMessageModel.assistant(
        text:
            "Désolé, je rencontre des difficultés à me connecter. Veuillez réessayer plus tard.",
      );
      add(MessageReceived(errorMessage));

      // On n'émet quand même l'erreur
      emit(RemoteMessageError(dataState.error!));
    }
  }

  void _onMessageReceived(MessageReceived event, Emitter<ChatState> emit) {
    emit(
      state.copyWith(messages: List.of(state.messages!)..add(event.message)),
    );
  }

  void _onTypingStarted(TypingStarted event, Emitter<ChatState> emit) {
    emit(state.copyWith(isTyping: true));
  }

  void _onTypingStopped(TypingStopped event, Emitter<ChatState> emit) {
    emit(state.copyWith(isTyping: false));
  }

  void _onChatToggled(ChatToggled event, Emitter<ChatState> emit) {
    emit(state.copyWith(isChatOpen: !state.isChatOpen!));
  }
}
