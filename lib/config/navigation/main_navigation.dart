import 'package:auto/auth/presentation/bloc/auth_bloc.dart';
// import 'package:auto/auth/presentation/pages/login_page.dart';
// import 'package:auto/core/resources/local_storage_service.dart';
// import 'package:auto/orders/presentation/bloc/my_orders_bloc.dart';
// import 'package:auto/orders/presentation/pages/my_orders_page.dart';
import 'package:auto/products/presentation/pages/ProductCatalogPage.dart';
import 'package:auto/notifications/presentation/pages/NotificationCenterPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:auto/products/presentation/widgets/search.index.bar.dart';
// import '../../injection_container.dart';
import '../../../main.dart';

import 'dart:ui';

class MainNavigation extends StatefulWidget {
  final int initialIndex;
  const MainNavigation({super.key, this.initialIndex = 0});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.logout, color: Colors.red),
              SizedBox(width: 8),
              Text('Déconnexion'),
            ],
          ),
          content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<AuthBloc>().add(const LogoutRequested());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Se déconnecter'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated || state is AuthInitial) {
          setState(() {});
        }
        if (state is AuthInitial) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vous avez été déconnecté avec succès'),
              backgroundColor: Colors.grey,
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      child: Container(
        // Fond dégradé subtil pour révéler le glassmorphism
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE0EAFC), // Bleu clair vibrant
              Color(0xFFCFDEF3), // Bleu ciel doux
              Color(0xFFE2D4F0), // Touche violet pastel
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent, // Important pour voir le dégradé
          extendBodyBehindAppBar: true,
          extendBody: true, // Pour que le contenu glisse sous la nav bar
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Container(
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
            ),
            title: const Padding(
              padding: EdgeInsets.all(1),
              child: HomeSearchbar(),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(LucideIcons.bell, size: 22, color: Colors.black87),
                  onPressed: () {
                    Navigator.of(context)
                        .push(
                          MaterialPageRoute(
                            builder: (_) => const NotificationCenterPage(),
                          ),
                        )
                        .then((_) => setState(() {}));
                  },
                ),
              ),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state is AuthAuthenticated) {
                    return Container(
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: PopupMenuButton<String>(
                        icon: const Icon(Icons.account_circle, size: 26, color: Colors.black87),
                        offset: const Offset(0, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        onSelected: (value) async {
                          if (value == 'logout') {
                            _showLogoutDialog(context);
                          }
                        },
                        itemBuilder: (_) => [
                          PopupMenuItem(
                            enabled: false,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  state.user.fullName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  state.user.email,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const PopupMenuDivider(),
                          const PopupMenuItem(
                            value: 'logout',
                            child: Row(
                              children: [
                                Icon(Icons.logout_rounded, size: 22, color: Colors.redAccent),
                                SizedBox(width: 12),
                                Text(
                                  'Se déconnecter',
                                  style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ],
          ),
          body: IndexedStack(
            index: _currentIndex,
            children: [
              const HomePage(),
              const ProductCatalogPage(),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 0,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: BottomNavigationBar(
                      elevation: 0,
                      backgroundColor: Colors.transparent,
                      currentIndex: _currentIndex,
                      onTap: (index) => setState(() => _currentIndex = index),
                      selectedItemColor: primary,
                      unselectedItemColor: Colors.grey.shade600,
                      showUnselectedLabels: true,
                      showSelectedLabels: true,
                      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
                      items: const [
                        BottomNavigationBarItem(
                          icon: Icon(LucideIcons.home),
                          activeIcon: Icon(Icons.home_rounded),
                          label: 'Accueil',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(LucideIcons.shoppingBag),
                          activeIcon: Icon(Icons.shopping_bag_rounded),
                          label: 'Recherche par marque',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// class _LoginPromptPage extends StatelessWidget {
//   const _LoginPromptPage();

//   @override
//   Widget build(BuildContext context) {
//     final primary = Theme.of(context).primaryColor;
//     return Scaffold(
//       appBar: AppBar(title: const Text('Mes commandes')),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(32),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(LucideIcons.logIn, size: 64, color: Colors.grey[400]),
//               const SizedBox(height: 16),
//               const Text(
//                 'Connectez-vous pour voir vos commandes',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(fontSize: 16, color: Colors.grey),
//               ),
//               const SizedBox(height: 24),
//               ElevatedButton(
//                 onPressed: () {
//                   //                   try {
//                     Navigator.of(context).push(
//                       MaterialPageRoute(builder: (_) => const LoginPage()),
//                     );
//                     //                   } catch (e) {
//                     //                   }
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: primary,
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                 ),
//                 child: const Text('Se connecter'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
