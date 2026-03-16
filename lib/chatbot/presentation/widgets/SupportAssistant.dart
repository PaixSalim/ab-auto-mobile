import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../bloc/remote/chat_bloc.dart';
import 'ChatBubble.dart';
import 'ChatFooter.dart';
import 'ChatHeader.dart';
import 'ChatInput.dart';
import 'TypingIndicator.dart';

class SupportAssistant extends StatefulWidget {
  const SupportAssistant({super.key});

  @override
  State<SupportAssistant> createState() => _SupportAssistantState();
}

class _SupportAssistantState extends State<SupportAssistant>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatBloc, ChatState>(
      listenWhen:
          (previous, current) =>
              previous.messages!.length != current.messages!.length ||
              previous.isTyping != current.isTyping ||
              previous.isChatOpen != current.isChatOpen,

      listener: (context, state) {
        if (state.isChatOpen!) {
          _animationController.forward();
        } else {
          _animationController.reverse();
        }

        // ✅ Tu peux juste appeler _scrollToBottom sans faire la vérif ici
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      },
      builder: (context, state) {
        return Stack(
          children: [
            // Floating button (visible when chat is closed)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              right: 16,
              bottom: 16,
              child: AnimatedOpacity(
                opacity: state.isChatOpen! ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: AnimatedScale(
                  scale: state.isChatOpen! ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: FloatingActionButton(
                    onPressed:
                        state.isChatOpen!
                            ? null
                            : () => context.read<ChatBloc>().add(
                              const ChatToggled(),
                            ),
                    backgroundColor: Theme.of(context).primaryColor,
                    child: const Icon(LucideIcons.bot, color: Colors.white),
                  ),
                ),
              ),
            ),

            // Chat window
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Positioned(
                  right: 16,
                  bottom: 16,
                  child: Visibility(
                    visible: state.isChatOpen!,
                    child: Transform.scale(
                      scale: _animation.value,
                      alignment: Alignment.bottomRight,
                      child: Opacity(
                        opacity: _animation.value,
                        child: Container(
                          width: 320,
                          height: 500,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              ChatHeader(
                                onClose:
                                    () => context.read<ChatBloc>().add(
                                      const ChatToggled(),
                                    ),
                              ),
                              Expanded(
                                child: Container(
                                  color: const Color(0xFFF9F9F9),
                                  child: ListView.builder(
                                    controller: _scrollController,
                                    padding: const EdgeInsets.all(16),
                                    itemCount:
                                        state.messages!.length +
                                        (state.isTyping! ? 1 : 0),
                                    itemBuilder: (context, index) {
                                      if (index == state.messages!.length) {
                                        return const TypingIndicator();
                                      }

                                      final message = state.messages![index];
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        child: ChatBubble(message: message),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              ChatInput(
                                isTyping: state.isTyping!,
                                onSend: (message) {
                                  context.read<ChatBloc>().add(
                                    MessageSent(message),
                                  );
                                },
                              ),
                              const ChatFooter(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
