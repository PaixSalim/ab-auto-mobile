import 'package:auto/auth/presentation/bloc/auth_bloc.dart';
import 'package:auto/auth/presentation/pages/register_page.dart';
import 'package:auto/config/navigation/main_navigation.dart';
import 'package:auto/config/theme/builldInputDecoration.dart';
import 'package:auto/config/theme/customToast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    final uid = _emailController.text.trim(); // API attend "uid" au lieu de "email"
    final password = _passwordController.text.trim();
    if (uid.isEmpty || password.isEmpty) {
      showCustomToast(context, 'Erreur', 'Veuillez remplir tous les champs', false);
      return;
    }
    context.read<AuthBloc>().add(LoginRequested(uid: uid, password: password));
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            showCustomToast(context, 'Erreur', state.message, false);
          }
          if (state is AuthAuthenticated) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const MainNavigation()),
              (_) => false,
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Center(
                    child: Image.asset('assets/images/abauto-final.png', height: 80),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Connexion',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: primary),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Connectez-vous pour suivre vos commandes',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: buildInputDecoration(
                      context,
                      'Téléphone ou email',
                      const Icon(LucideIcons.mail),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: buildInputDecoration(
                      context,
                      'Mot de passe',
                      const Icon(LucideIcons.lock),
                      Icon(
                        _obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye,
                      ),
                    ).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: state is AuthLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: state is AuthLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text('Se connecter', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Pas encore de compte ? '),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const RegisterPage()),
                        ),
                        child: Text(
                          'S\'inscrire',
                          style: TextStyle(color: primary, fontWeight: FontWeight.bold),
                        ),
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
