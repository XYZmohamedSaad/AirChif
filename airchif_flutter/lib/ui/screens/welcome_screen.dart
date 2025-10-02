import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'sign_in_screen.dart';
import 'sign_up_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});
  static const routePath = '/';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bildkarte
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8C66B),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.black.withOpacity(.55), width: 2),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                      color: Colors.black.withOpacity(.18),
                    ),
                  ],
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Image.asset('assets/hero.jpeg'),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 22),

              // Headline (schwarz + gelb, fett)
              RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style.copyWith(
                    fontSize: 26,
                    height: 1.2,
                    fontWeight: FontWeight.w800,
                  ),
                  children: [
                    const TextSpan(text: 'Save the '),
                    TextSpan(text: 'World and its Future\n', style: TextStyle(color: cs.primary)),
                    const TextSpan(text: 'From a '),
                    TextSpan(text: 'Birds Perspective', style: TextStyle(color: cs.primary)),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              Text(
                'AIRCHIF',
                style: TextStyle(
                  color: cs.primary,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 6),

              const Text(
                'With this app, you can connect to a DJI Tello and use its features to combat '
                    'environmental pollution.',
              ),
              const SizedBox(height: 24),

              // dünner Divider
              Opacity(
                opacity: .5,
                child: Container(height: 2, width: 120, color: Colors.black54),
              ),
              const SizedBox(height: 18),

              // Buttons
              Center(
                child: Column(
                  children: [
                    SizedBox(
                      width: 240,
                      height: 50,
                      child: FilledButton(
                        onPressed: () => context.go(SignInScreen.routePath),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFF0A51B),
                          shape: const StadiumBorder(),
                          elevation: 2,
                          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        child: const Text('Sign in'),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: 240,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () => context.go(SignUpScreen.routePath),
                        style: OutlinedButton.styleFrom(
                          shape: const StadiumBorder(),
                          side: const BorderSide(color: Color(0xFFF0A51B), width: 2),
                          backgroundColor: const Color(0xFFFFF4DA),
                          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        child: const Text('Sign up'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
