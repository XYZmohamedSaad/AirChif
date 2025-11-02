import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import 'home_screen.dart';
import 'sign_in_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  static const routePath = '/sign-up';

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  final _auth = AuthService();

  bool _loading = false;
  bool _obscurePw = true;
  bool _obscureConfirm = true;

  // Farben passend zu deinem Design
  static const Color _accentYellow = Color(0xFFF2C23A);
  static const Color _fieldFill = Color(0xFFF4DA7A);
  static const Color _goldButton = Color(0xFFC58B07);
  static const BorderSide _fieldBorder =
  BorderSide(color: Colors.black, width: 1.2);

  InputDecoration _input(String label, {bool isPassword = false, VoidCallback? onToggle}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black, fontSize: 14),
      filled: true,
      fillColor: _fieldFill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: _fieldBorder,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: _fieldBorder,
      ),
      suffixIcon: isPassword
          ? IconButton(
        splashRadius: 18,
        icon: const Icon(Icons.remove_red_eye),
        color: Colors.black,
        onPressed: onToggle,
      )
          : null,
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final ok = await _auth.signUp(
      email: _emailController.text.trim(),
      username: _usernameController.text.trim(),
      password: _passwordController.text,
    );

    if (ok) {
      final loginOk = await _auth.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (loginOk && mounted) {
        context.go(HomeScreen.routePath);
      }
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signup fehlgeschlagen')),
      );
    }

    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 8),
                    const Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w700,
                        color: _accentYellow,
                        letterSpacing: .5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Are you ready to join the team?',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 22),

                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _input('Email'),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Email required';
                        }
                        if (!v.contains('@')) return 'Invalid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _usernameController,
                      decoration: _input('Username'),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Username required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePw,
                      decoration: _input(
                        'Password',
                        isPassword: true,
                        onToggle: () => setState(() => _obscurePw = !_obscurePw),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Password required';
                        if (v.length < 6) return 'Min. 6 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _confirmController,
                      obscureText: _obscureConfirm,
                      decoration: _input(
                        'Confirm Password',
                        isPassword: true,
                        onToggle: () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                      onFieldSubmitted: (_) => _submit(),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (v != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 28),

                    if (_loading) const CircularProgressIndicator(),

                    const SizedBox(height: 28),

                    SizedBox(
                      width: 200,
                      height: 44,
                      child: FilledButton(
                        onPressed: () => context.go(SignInScreen.routePath),
                        style: FilledButton.styleFrom(
                          backgroundColor: _goldButton,
                          shape: const StadiumBorder(),
                          side: const BorderSide(color: Colors.black, width: 1.2),
                          elevation: 0,
                          foregroundColor: Colors.black,
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        child: const Text('Login'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
