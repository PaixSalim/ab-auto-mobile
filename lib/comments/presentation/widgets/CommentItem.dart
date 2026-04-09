import 'package:auto/comments/data/models/comment_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CommentItem extends StatelessWidget {
  final CommentModel comment;
  final Color primaryColor;
  final Color textColor;

  const CommentItem({
    super.key,
    required this.comment,
    required this.primaryColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy à HH:mm');
    
    // Naming logic: Prioritize author relation, then user field, then default
    final commenterName = comment.author?.fullName ?? comment.user ?? 'Utilisateur';
    
    // Safer date parsing
    DateTime? createdAt;
    try {
      if (comment.createdAt != null) {
        createdAt = DateTime.parse(comment.createdAt!);
      }
    } catch (e) {
      debugPrint('Error parsing comment date: $e');
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar (première lettre du nom)
              CircleAvatar(
                backgroundColor: primaryColor.withValues(alpha: 0.2),
                child: Text(
                  commenterName.isNotEmpty
                      ? commenterName[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Nom et date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      commenterName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        fontSize: 16,
                      ),
                    ),
                    if (createdAt != null)
                      Text(
                        dateFormat.format(createdAt),
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                  ],
                ),
              ),
            ],
          ),

          // Contenu du commentaire
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 48.0),
            child: Text(
              comment.comment ?? 'Aucun contenu',
              style: TextStyle(color: textColor.withOpacity(0.8), fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
