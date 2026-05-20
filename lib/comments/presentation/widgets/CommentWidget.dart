import 'package:auto/auth/presentation/pages/login_page.dart';
import 'package:auto/config/theme/customToast.dart';
import 'package:auto/core/resources/local_storage_service.dart';
import 'package:auto/core/resources/network_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../bloc/comment_bloc.dart';
import 'CommentItem.dart';

class ProductCommentsSection extends StatefulWidget {
  final String productId; // Changé de int à String
  final Color backgroundColor;
  final Color textColor;

  const ProductCommentsSection({
    super.key,
    required this.productId, // Couleur primaire par défaut
    this.backgroundColor = Colors.white,
    this.textColor = const Color(0xFF333333),
  });

  @override
  State<ProductCommentsSection> createState() => _ProductCommentsSectionState();
}

class _ProductCommentsSectionState extends State<ProductCommentsSection> {
  late CommentBloc _commentsBloc;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  bool _isFormExpanded = false;

  @override
  void initState() {
    super.initState();
    _commentsBloc = GetIt.instance<CommentBloc>();
    _commentsBloc.add(FetchComments(widget.productId));
    _loadUserName();
  }

  void _loadUserName() {
    // Load username from local storage if logged in
    if (LocalStorageService.isLoggedIn) {
      _nameController.text = LocalStorageService.userFullName ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _commentController.dispose();
    _commentsBloc.close();
    super.dispose();
  }

  void _submitComment() async {
    final networkInfo = NetworkInfo(InternetConnection());
    final isOnline = await networkInfo.isConnected;
    if (isOnline) {
      if (_nameController.text.trim().isEmpty ||
          _commentController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Veuillez remplir tous les champs',
              style: TextStyle(color: widget.backgroundColor),
            ),
            backgroundColor: Theme.of(context).primaryColor,
          ),
        );
        return;
      }

      _commentsBloc.add(
        AddComment(
          productId: widget.productId,
          user: _nameController.text.trim(),
          comment: _commentController.text.trim(),
        ),
      );

      _commentController.clear();
      _nameController.clear();
      setState(() {
        _isFormExpanded = false;
      });
    } else {
      showCustomToast(
        context,
        "Pas d'internet",
        "Veuillez bien vouloir vous connecter à internet bien avant !",
        false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _commentsBloc,
      child: Container(
        color: widget.backgroundColor,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre de la section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Commentaires',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: widget.textColor,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _isFormExpanded ? Icons.remove : Icons.add,
                    color: Theme.of(context).primaryColor,
                  ),
                  onPressed: () {
                    if (!LocalStorageService.isLoggedIn) {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Connexion requise'),
                          content: const Text(
                              'Vous devez être connecté pour laisser un commentaire.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.grey[600],
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              ),
                              child: const Text('Annuler'),
                            ),
                            ElevatedButton.icon(
                              onPressed: () async {
                                final url = 'https://ab-autox.com/login';
                                if (await canLaunchUrl(Uri.parse(url))) {
                                  await launchUrl(Uri.parse(url));
                                } else {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Impossible d\'ouvrir le lien')),
                                    );
                                  }
                                }
                              },
                              icon: const Icon(Icons.store, size: 16),
                              label: const Text('Devenez vendeur'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF25D366), // Vert WhatsApp
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () async {
                                Navigator.pop(ctx);
                                // Navigate to login with return route
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LoginPage(returnRoute: 'comments'),
                                  ),
                                );
                                // If login was successful, refresh username and expand form
                                if (result == true) {
                                  _loadUserName();
                                  setState(() {
                                    _isFormExpanded = true;
                                  });
                                }
                              },
                              icon: const Icon(Icons.login, size: 16),
                              label: const Text('Se connecter'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                      return;
                    }
                    setState(() {
                      _isFormExpanded = !_isFormExpanded;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Formulaire d'ajout de commentaire
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: _isFormExpanded ? null : 0,
              child:
                  _isFormExpanded
                      ? Card(
                        elevation: 2,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            color: Theme.of(
                              context,
                            ).primaryColor.withValues(alpha: 0.2),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ajouter un commentaire',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: widget.textColor,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Champ pour le nom
                              TextField(
                                controller: _nameController,
                                readOnly: LocalStorageService.isLoggedIn,
                                decoration: InputDecoration(
                                  labelText: 'Votre nom',
                                  suffixIcon: LocalStorageService.isLoggedIn
                                      ? const Icon(Icons.lock_outline, size: 18, color: Colors.grey)
                                      : null,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Theme.of(context).primaryColor,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Champ pour le commentaire
                              TextField(
                                controller: _commentController,
                                maxLines: 3,
                                decoration: InputDecoration(
                                  labelText: 'Votre commentaire',
                                  alignLabelWithHint: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Theme.of(context).primaryColor,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _submitComment,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Theme.of(context).primaryColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text('Publier'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      : const SizedBox.shrink(),
            ),

            const SizedBox(height: 16),

            // Liste des commentaires
            BlocConsumer<CommentBloc, CommentState>(
              listener: (context, state) {
                if (state is CommentsLoaded && state.lastAddedComment != null) {
                  showCustomToast(
                    context,
                    "Félicitations",
                    "Commentaire soumis pour validation par un moderateur avec succès!",
                    true,
                  );
                } else if (state is CommentsError) {
                  showCustomToast(
                    context,
                    "Erreur imprévue",
                    state.message,
                    false,
                  );
                }
              },
              builder: (context, state) {
                if (state is CommentsLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is CommentsLoaded) {
                  if (state.comments.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Soyez le premier à commenter ce produit',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.comments.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final comment = state.comments[index];
                      return CommentItem(
                        comment: comment,
                        primaryColor: Theme.of(context).primaryColor,
                        textColor: widget.textColor,
                      );
                    },
                  );
                } else if (state is CommentsError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Erreur lors du chargement des commentaires',
                            style: TextStyle(
                              color: Colors.red[600],
                              fontSize: 16,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              _commentsBloc.add(
                                FetchComments(widget.productId),
                              );
                            },
                            child: Text(
                              'Réessayer',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}
