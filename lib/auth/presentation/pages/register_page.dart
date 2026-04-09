import 'package:auto/auth/presentation/bloc/auth_bloc.dart';
import 'package:auto/auth/presentation/pages/login_page.dart';
import 'package:auto/config/navigation/main_navigation.dart';
import 'package:auto/config/theme/builldInputDecoration.dart';
import 'package:auto/config/theme/customToast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';

class RegisterPage extends StatefulWidget {
  final String? returnRoute;
  
  const RegisterPage({super.key, this.returnRoute});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isSeller = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    
    // Validation des champs obligatoires (comme le web)
    if (fullName.isEmpty || phone.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      showCustomToast(context, 'Erreur', 'Veuillez remplir tous les champs obligatoires', false);
      return;
    }
    if (phone.length < 8) {
      showCustomToast(context, 'Erreur', 'Le numéro de téléphone doit contenir au moins 8 caractères', false);
      return;
    }
    if (password.length < 8) {
      showCustomToast(context, 'Erreur', 'Le mot de passe doit contenir au moins 8 caractères', false);
      return;
    }
    if (password != confirmPassword) {
      showCustomToast(context, 'Erreur', 'Les mots de passe ne correspondent pas', false);
      return;
    }
    
    context.read<AuthBloc>().add(
          RegisterRequested(
            fullName: fullName,
            email: email.isNotEmpty ? email : null,
            password: password,
            phone: phone,
            confirmPassword: confirmPassword,
            isSeller: _isSeller,
          ),
        );
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
            // If there's a return route, go back instead of navigating to main
            if (widget.returnRoute == 'comments' && Navigator.canPop(context)) {
              Navigator.of(context).pop(true); // Return true to indicate successful registration
            } else {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const MainNavigation()),
                (_) => false,
              );
            }
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
                    'Créer un compte',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: primary),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Inscrivez-vous pour commander facilement',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _fullNameController,
                    decoration: buildInputDecoration(
                      context,
                      'Nom complet',
                      const Icon(LucideIcons.user),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: buildInputDecoration(
                      context,
                      'Téléphone',
                      const Icon(LucideIcons.phone),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: buildInputDecoration(
                      context,
                      'Adresse email (optionnel)',
                      const Icon(LucideIcons.mail),
                    ),
                  ),
                  // const SizedBox(height: 16),
                  // TextField(
                  //   controller: _cityController,
                  //   decoration: buildInputDecoration(
                  //     context,
                  //     'Ville',
                  //     const Icon(LucideIcons.mapPin),
                  //   ),
                  // ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: buildInputDecoration(
                      context,
                      'Mot de passe (min. 8 caractères)',
                      const Icon(LucideIcons.lock),
                    ).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    decoration: buildInputDecoration(
                      context,
                      'Confirmer le mot de passe',
                      const Icon(LucideIcons.lock),
                    ).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(_obscureConfirmPassword ? LucideIcons.eyeOff : LucideIcons.eye),
                        onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                      ),
                    ),
                  ),
                  // const SizedBox(height: 16),
                  // CheckboxListTile(
                  //   title: const Text('Je suis un vendeur professionnel'),
                  //   value: _isSeller,
                  //   onChanged: (bool? value) {
                  //     setState(() {
                  //       _isSeller = value ?? false;
                  //     });
                  //   },
                  //   controlAffinity: ListTileControlAffinity.leading,
                  // ),
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
                          : const Text('S\'inscrire', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Déjà un compte ? '),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                        ),
                        child: Text(
                          'Se connecter',
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
