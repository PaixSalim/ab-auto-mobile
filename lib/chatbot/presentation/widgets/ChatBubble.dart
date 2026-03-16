import 'package:auto/chatbot/data/models/chat_message_model.dart';
import 'package:auto/chatbot/data/models/feedback_model.dart';
import 'package:auto/chatbot/data/utils/link_detector.dart';
import 'package:auto/chatbot/presentation/bloc/remote/chat_bloc.dart';
import 'package:auto/config/theme/customToast.dart';
import 'package:auto/core/resources/network_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class ChatBubble extends StatefulWidget {
  final ChatMessageModel message;

  const ChatBubble({super.key, required this.message});

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  // État du feedback
  bool? _isPositiveFeedback;

  @override
  Widget build(BuildContext context) {
    return widget.message.isUser!
        ? _buildUserMessage(context)
        : _buildAssistantMessage(context);
  }

  Widget _buildUserMessage(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.65,
            ),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Text(
              widget.message.text!,
              style: const TextStyle(color: Color(0xFF333333)),
            ),
          ),
        ),
        const SizedBox(width: 8),
        _buildAvatar(context, true),
      ],
    );
  }

  Widget _buildAssistantMessage(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAvatar(context, false),
        const SizedBox(width: 8),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Message bubble
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.65,
                ),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: buildRichTextWithWidgets(context, widget.message.text!),
              ),

              if (widget.message.id != 'initial')
                Padding(
                  padding: const EdgeInsets.only(top: 6.0, left: 4.0),
                  child: _buildFeedbackSection(context),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeedbackSection(BuildContext context) {
    // Si l'utilisateur a déjà donné son avis, afficher un message de remerciement
    if (_isPositiveFeedback != null) {
      return AnimatedOpacity(
        opacity: 1.0,
        duration: const Duration(milliseconds: 300),
        child: Text(
          _isPositiveFeedback!
              ? 'Merci pour votre retour !'
              : 'Merci pour votre signalement',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    // Sinon, afficher les icônes de feedback
    return Row(
      children: [
        Text(
          'Cette réponse était-elle utile ?',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        const SizedBox(width: 8),
        _buildFeedbackButton(
          icon: Icons.thumb_up_outlined,
          color: Colors.green,
          onTap: () => _handleFeedback(true),
        ),
        const SizedBox(width: 8),
        _buildFeedbackButton(
          icon: Icons.thumb_down_outlined,
          color: Colors.red,
          onTap: () => _handleFeedback(false),
        ),
      ],
    );
  }

  Widget _buildFeedbackButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, bool isUser) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color:
            isUser ? const Color(0xFFE0E0E0) : Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        isUser ? Icons.person : Icons.smart_toy,
        color: isUser ? const Color(0xFF666666) : Colors.white,
        size: 16,
      ),
    );
  }

  void _handleFeedback(bool isPositive) {
    if (isPositive) {
      _showFeedbackModal(context, isPositive);
    } else {
      _showFeedbackModal(context, isPositive);
    }
  }

  void _showFeedbackModal(BuildContext context, bool isPositive) {
    // Définir les options à afficher en fonction du type de feedback
    final List<String> options =
        isPositive
            ? ['Réponse précise', 'Réponse utile', 'Bien expliqué']
            : [
              'Réponse incomplète',
              'Information incorrecte',
              'Hors sujet',
              'Difficile à comprendre',
              'Autre problème',
            ];

    // Calculer une largeur appropriée pour le dialog
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth > 600 ? 500.0 : screenWidth * 0.85;

    // Map pour stocker l'état des checkboxes
    final Map<String, bool> feedbackOptions = {
      for (var option in options) option: false,
    };

    String additionalInfo = '';

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setStateDialog) {
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                insetPadding: EdgeInsets.symmetric(
                  horizontal: (screenWidth - dialogWidth) / 2,
                  vertical: 24.0,
                ),
                child: Container(
                  width: dialogWidth,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Titre du modal
                      Text(
                        isPositive
                            ? 'Qu\'avez-vous apprécié ?'
                            : 'Qu\'est-ce qui n\'allait pas ?',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Sous-titre
                      Text(
                        isPositive
                            ? 'Sélectionnez ce que vous avez aimé dans cette réponse'
                            : 'Sélectionnez les problèmes que vous avez rencontrés',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 16),

                      // Liste des options à cocher
                      Flexible(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children:
                                options
                                    .map(
                                      (option) => CheckboxListTile(
                                        title: Text(
                                          option,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                        value: feedbackOptions[option],
                                        onChanged: (bool? value) {
                                          // Utiliser setStateDialog pour mettre à jour l'état dans le Dialog
                                          setStateDialog(() {
                                            feedbackOptions[option] =
                                                value ?? false;
                                            debugPrint(
                                              'Option $option: ${feedbackOptions[option]}',
                                            );
                                          });
                                        },
                                        controlAffinity:
                                            ListTileControlAffinity.leading,
                                        contentPadding: EdgeInsets.zero,
                                        dense: true,
                                        activeColor:
                                            Theme.of(context).primaryColor,
                                      ),
                                    )
                                    .toList(),
                          ),
                        ),
                      ),

                      // Champ de texte pour informations supplémentaires
                      if (!isPositive) ...[
                        const SizedBox(height: 16),
                        TextField(
                          decoration: const InputDecoration(
                            labelText:
                                'Informations complémentaires (optionnel)',
                            border: OutlineInputBorder(),
                            hintText: 'Décrivez le problème plus en détail...',
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                          maxLines: 3,
                          onChanged: (value) {
                            additionalInfo = value;
                          },
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Boutons d'action
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Bouton Annuler
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Annuler'),
                          ),
                          const SizedBox(width: 8),
                          // Bouton Envoyer
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  8,
                                ), // Remplacez 20 par la valeur souhaitée
                              ),
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () async {
                              final networkInfo = NetworkInfo(
                                InternetConnection(),
                              );
                              final isOnline = await networkInfo.isConnected;
                              if (isOnline) {
                                final selectedOptions =
                                    feedbackOptions.entries
                                        .where((entry) => entry.value)
                                        .map((entry) => entry.key)
                                        .toList();

                                final bloc = context.read<ChatBloc>();
                                final lastMessages =
                                    bloc.state.messages!.where((m) {
                                      return m.timestamp!.isBefore(
                                        widget.message.timestamp!,
                                      );
                                    }).toList();

                                final feedback = FeedbackModel(
                                  request: lastMessages.last.text!,
                                  response: widget.message.text!,
                                  isPositive: isPositive,
                                  selectedOptions: selectedOptions,
                                  additionalInfo: additionalInfo,
                                );

                                bloc.add(SendFeedbackEvent(feedback));

                                Navigator.of(context).pop();

                                setState(() {
                                  _isPositiveFeedback = isPositive;
                                });

                                showCustomToast(
                                  context,
                                  "Merci",
                                  isPositive
                                      ? 'Merci pour votre retour positif !'
                                      : 'Merci pour votre signalement. Nous allons examiner ce problème.',
                                  true,
                                );
                              } else {
                                showCustomToast(
                                  context,
                                  "Pas d'internet",
                                  "Veuillez bien vouloir vous connecter à internet bien avant !",
                                  false,
                                );
                              }
                            },
                            child: Text(isPositive ? 'Envoyer' : 'Signaler'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }
}
