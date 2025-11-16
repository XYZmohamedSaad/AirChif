import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/auth_service.dart';
import 'home_screen.dart';
import 'sign_up_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});
  static const routePath = '/sign-in';

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = AuthService();

  bool _loading = false;
  bool _obscurePw = true;

  // Farben wie in deinem Design
  static const Color _accentYellow = Color(0xFFF2C23A);
  static const Color _fieldFill = Color(0xFFF4DA7A);
  static const Color _goldButton = Color(0xFFC58B07);
  static const BorderSide _fieldBorder =
  BorderSide(color: Colors.black, width: 1.2);

  InputDecoration _input(String label, {bool password = false}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black, fontSize: 14),
      filled: true,
      fillColor: _fieldFill,
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: _fieldBorder,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: _fieldBorder,
      ),
      suffixIcon: password
          ? IconButton(
        splashRadius: 18,
        icon: Icon(
          _obscurePw ? Icons.visibility_off : Icons.visibility,
        ),
        color: Colors.black,
        onPressed: () =>
            setState(() => _obscurePw = !_obscurePw),
      )
          : null,
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final ok = await _auth.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    setState(() => _loading = false);
    if (!mounted) return;

    if (ok) {
      // ➜ nach erfolgreichem Login auf den HomeScreen
      context.go(HomeScreen.routePath);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login fehlgeschlagen')),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Hintergrundfarbe kommt aus deinem Theme (hellblau)
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w700,
                        color: _accentYellow,
                        letterSpacing: .5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "We've missed you!",
                      style:
                      TextStyle(fontSize: 18, color: Colors.black87),
                    ),
                    const SizedBox(height: 22),

                    // ========== Email ==========
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

                    // ========== Password ==========
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePw,
                      decoration: _input('Password', password: true),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Password required';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 8),

                    // Forgot password
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF1B6DA8),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Forgot Password – coming soon'),
                            ),
                          );
                        },
                        child: const Text('Forgot Password?'),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // ========== Login Button ==========
                    SizedBox(
                      width: 200,
                      height: 44,
                      child: FilledButton(
                        onPressed: _loading ? null : _login,
                        style: FilledButton.styleFrom(
                          backgroundColor: _goldButton,
                          shape: const StadiumBorder(),
                          side: const BorderSide(
                              color: Colors.black, width: 1.2),
                          elevation: 0,
                          foregroundColor: Colors.black,
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        child: _loading
                            ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                            : const Text('Login'),
                      ),
                    ),

                    // ========== Divider: or Sign in with ==========
                    const SizedBox(height: 28),
                    Row(
                      children: const [
                        Expanded(child: Divider(thickness: 1)),
                        Padding(
                          padding:
                          EdgeInsets.symmetric(horizontal: 12),
                          child: Text('or Sign in with'),
                        ),
                        Expanded(child: Divider(thickness: 1)),
                      ],
                    ),

                    // Kein Google-Button – Abschnitt bleibt leer
                    const SizedBox(height: 36),

                    // ========== Bottom link: Sign up ==========
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      alignment: WrapAlignment.center,
                      children: [
                        const Text("Don't have an account? "),
                        TextButton(
                          onPressed: () =>
                              context.go(SignUpScreen.routePath),
                          child: const Text('Sign up'),
                        ),
                      ],
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
