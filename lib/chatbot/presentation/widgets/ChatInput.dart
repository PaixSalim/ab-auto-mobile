import 'package:auto/config/theme/customToast.dart';
import 'package:auto/core/resources/network_info.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class ChatInput extends StatefulWidget {
  final bool isTyping;
  final Function(String) onSend;

  const ChatInput({Key? key, required this.isTyping, required this.onSend})
    : super(key: key);

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSend() {
    if (_controller.text.trim().isNotEmpty && !widget.isTyping) {
      widget.onSend(_controller.text);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE0E0E0), width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Tapez votre message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: const Color(0xFFF0F0F0),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                isDense: true,
              ),
              enabled: !widget.isTyping,
              onSubmitted: (_) => _handleSend(),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(24),
            child: InkWell(
              onTap:
                  widget.isTyping
                      ? null
                      : () async {
                        final networkInfo = NetworkInfo(InternetConnection());
                        final isOnline = await networkInfo.isConnected;
                        if (isOnline) {
                          _handleSend();
                        } else {
                          FocusScope.of(context).unfocus();
                          showCustomToast(
                            context,
                            "Pas d'internet",
                            "Veuillez bien vouloir vous connecter à internet bien avant !",
                            false,
                          );
                        }
                      },
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.all(10),
                child: Icon(
                  Icons.send,
                  color:
                      widget.isTyping || _controller.text.trim().isEmpty
                          ? Colors.white.withValues(alpha: 0.8)
                          : Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
