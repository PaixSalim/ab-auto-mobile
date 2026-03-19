import 'package:auto/auth/presentation/bloc/auth_bloc.dart';
import 'package:auto/auth/presentation/pages/login_page.dart';
import 'package:auto/core/resources/local_storage_service.dart';
import 'package:auto/orders/presentation/bloc/my_orders_bloc.dart';
import 'package:auto/orders/presentation/pages/my_orders_page.dart';
import 'package:auto/products/presentation/pages/ProductCatalogPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:auto/products/presentation/widgets/search.index.bar.dart';
import '../../injection_container.dart';
import '../../../main.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  Widget _buildOrdersTab() {
    if (LocalStorageService.isLoggedIn) {
      return BlocProvider(
        create: (_) => sl<MyOrdersBloc>(),
        child: const MyOrdersPage(),
      );
    }
    return const _LoginPromptPage();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Rafraîchir la page commandes après login/logout
        if (state is AuthAuthenticated || state is AuthInitial) {
          setState(() {});
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Padding(
            padding: EdgeInsets.all(1),
            child: HomeSearchbar(),
          ),
          actions: [
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is AuthAuthenticated) {
                  return PopupMenuButton<String>(
                    icon: const Icon(Icons.account_circle),
                    onSelected: (value) {
                      if (value == 'logout') {
                        context.read<AuthBloc>().add(const LogoutRequested());
                      }
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        enabled: false,
                        child: Text(
                          state.user.fullName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 'logout',
                        child: Row(
                          children: [
                            Icon(Icons.logout, size: 18),
                            SizedBox(width: 8),
                            Text('Se déconnecter'),
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
            _buildOrdersTab(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          selectedItemColor: primary,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(icon: Icon(LucideIcons.home), label: 'Accueil'),
            BottomNavigationBarItem(icon: Icon(LucideIcons.shoppingBag), label: 'Catalogue'),
            BottomNavigationBarItem(icon: Icon(LucideIcons.clipboardList), label: 'Commandes'),
          ],
        ),
      ),
    );
  }
}

class _LoginPromptPage extends StatelessWidget {
  const _LoginPromptPage();

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return Scaffold(
      appBar: AppBar(title: const Text('Mes commandes')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.logIn, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              const Text(
                'Connectez-vous pour voir vos commandes',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Se connecter'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
