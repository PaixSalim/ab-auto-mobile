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
import 'package:url_launcher/url_launcher.dart';

import 'package:auto/products/presentation/widgets/search.index.bar.dart';
// import '../../injection_container.dart';
import '../../../main.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
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
              ),
              child: const Text('Se déconnecter'),
            ),
          ],
        );
      },
    );
  }

  // Widget _buildOrdersTab() {
  //   if (LocalStorageService.isLoggedIn) {
  //     return BlocProvider(
  //       create: (_) => sl<MyOrdersBloc>(),
  //       child: const MyOrdersPage(),
  //     );
  //   }
  //   return const _LoginPromptPage();
  // }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Rafraîchir la page commandes après login/logout
        if (state is AuthAuthenticated || state is AuthInitial) {
          setState(() {});
        }
        // Show success message after logout
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
      child: Scaffold(
        appBar: AppBar(
          title: const Padding(
            padding: EdgeInsets.all(1),
            child: HomeSearchbar(),
          ),
          actions: [
            IconButton(
              icon: const Icon(LucideIcons.bell, size: 24),
              onPressed: () {
                Navigator.of(context)
                    .push(
                      MaterialPageRoute(
                        builder: (_) => const NotificationCenterPage(),
                      ),
                    )
                    .then(
                      (_) => setState(() {}),
                    ); // Refresh unread count on return
              },
            ),
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is AuthAuthenticated) {
                  return PopupMenuButton<String>(
                    icon: const Icon(Icons.account_circle, size: 28),
                    onSelected: (value) async {
                      if (value == 'logout') {
                        _showLogoutDialog(context);
                      }
                    },
                    itemBuilder:
                        (_) => [
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
                                Icon(
                                  Icons.logout_rounded,
                                  size: 22,
                                  color: Colors.redAccent,
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Se déconnecter',
                                  style: TextStyle(
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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
            // _buildOrdersTab(), // Temporairement désactivé
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          selectedItemColor: primary,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.home),
              label: 'Accueil',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.shoppingBag),
              label: 'Recherche par marque',
            ),
            // BottomNavigationBarItem(icon: Icon(LucideIcons.clipboardList), label: 'Commandes'), // Temporairement désactivé
          ],
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
//                   print('🔗 NAVIGATION - Attempting to navigate to LoginPage');
//                   try {
//                     Navigator.of(context).push(
//                       MaterialPageRoute(builder: (_) => const LoginPage()),
//                     );
//                     print('🔗 NAVIGATION - Navigation successful');
//                   } catch (e) {
//                     print('🔗 NAVIGATION - Navigation failed: $e');
//                   }
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
