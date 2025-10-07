import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'sign_in_screen.dart';
import 'sign_up_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});
  static const routePath = '/';

  @override
  Widget build(BuildContext context) {
    // Farben
    const accentYellow = Color(0xFFF2C23A);
    const darkGold     = Color(0xFFC58B07);
    const lightBeige   = Color(0xFFF9EFCF);
    const boxYellow    = Color(0xFFF4DA7A);
    const pageBg       = Colors.white;

    // Größen (angepasst für größere Drohne)
    const double heroHeight     = 280;  // etwas höherer Bereich
    const double padSize        = 210;  // H bleibt gleich
    const double droneMaxWidth  = 460;  // Drohne größer (bedeckt H)
    const double landingOpacity = 0.05; // fast unsichtbar

    return Scaffold(
      backgroundColor: pageBg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ===== HERO BOX =====
                  Container(
                    width: double.infinity,
                    height: heroHeight,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                    decoration: BoxDecoration(
                      color: boxYellow,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: Colors.black.withOpacity(.55), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 10,
                          offset: const Offset(0, 6),
                          color: Colors.black.withOpacity(.18),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Landing Pad (leicht durchsichtig)
                          Opacity(
                            opacity: landingOpacity,
                            child: SizedBox(
                              width: padSize,
                              height: padSize,
                              child: Image.asset(
                                'assets/landingH.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          // Drohne – größer, liegt oben
                          ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: droneMaxWidth),
                            child: Image.asset(
                              'assets/drone_image.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // ===== HEADLINE =====
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 26,
                        height: 1.2,
                        fontWeight: FontWeight.w900,
                      ),
                      children: [
                        TextSpan(text: 'Save the ', style: TextStyle(color: Colors.black)),
                        TextSpan(text: 'World and its Future\n', style: TextStyle(color: accentYellow)),
                        TextSpan(text: 'From a ', style: TextStyle(color: Colors.black)),
                        TextSpan(text: 'Birds Perspective', style: TextStyle(color: accentYellow)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ===== AIRCHIF =====
                  const Text(
                    'AIRCHIF',
                    style: TextStyle(
                      color: accentYellow,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ===== Beschreibung =====
                  const SizedBox(
                    width: 320,
                    child: Text(
                      'With this app, you can connect to a DJI\n'
                          'Tello and use its features to combat environmental pollution.',
                      style: TextStyle(
                        color: Colors.black,
                        height: 1.35,
                        fontSize: 15.5,
                        letterSpacing: .25,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),

                  // ===== Divider =====
                  Center(child: Container(height: 1.5, width: 120, color: Colors.black)),
                  const SizedBox(height: 22),

                  // ===== Buttons =====
                  Center(
                    child: Column(
                      children: [
                        SizedBox(
                          width: 230,
                          height: 48,
                          child: FilledButton(
                            onPressed: () => context.go(SignInScreen.routePath),
                            style: FilledButton.styleFrom(
                              backgroundColor: darkGold,
                              shape: const StadiumBorder(),
                              side: const BorderSide(color: Colors.black, width: 1.2),
                              elevation: 0,
                              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Sign in'),
                          ),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: 230,
                          height: 48,
                          child: OutlinedButton(
                            onPressed: () => context.go(SignUpScreen.routePath),
                            style: OutlinedButton.styleFrom(
                              shape: const StadiumBorder(),
                              side: const BorderSide(color: Colors.black, width: 1.2),
                              backgroundColor: lightBeige,
                              foregroundColor: Colors.black,
                              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
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
        ),
      ),
    );
  }
}
