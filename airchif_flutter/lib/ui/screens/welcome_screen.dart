import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'sign_in_screen.dart';
import 'sign_up_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});
  static const routePath = '/';

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _hover;

  @override
  void initState() {
    super.initState();
    _hover = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _hover.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Farben
    const accentYellow = Color(0xFFF2C23A);
    const darkGold = Color(0xFFC58B07);
    const lightBeige = Color(0xFFF9EFCF);
    const boxYellow = Color(0xFFF4DA7A);
    const pageBg = Colors.white;

    // Größen (fein abgestimmt)
    const double heroHeight = 320;     // Höhe der gelben Box
    const double padSize = 240;        // Größe des H
    const double droneMaxWidth = 500;  // Drohne größer, aber noch „inside“
    const Color hTint = Color(0xFF3F3F3F); // H etwas heller als tiefschwarz

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
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // H (Landing Pad) – etwas heller als Schwarz
                        ColorFiltered(
                          colorFilter: const ColorFilter.mode(hTint, BlendMode.srcIn),
                          child: SizedBox(
                            width: padSize,
                            height: padSize,
                            child: Image.asset('assets/landingH.png', fit: BoxFit.contain),
                          ),
                        ),

                        // Hover-Shadow (Ellipse) unter der Drohne
                        AnimatedBuilder(
                          animation: _hover,
                          builder: (context, _) {
                            // t in [0,1] -> smooth curve
                            final t = (1 - math.cos(_hover.value * math.pi)) / 2; // ease in-out
                            final shadowScale = 1.0 - (t * 0.12); // kleiner wenn Drohne höher
                            final shadowOpacity = 0.28 - (t * 0.12);

                            return Transform.scale(
                              scale: shadowScale,
                              child: Opacity(
                                opacity: shadowOpacity.clamp(0.0, 1.0),
                                child: Container(
                                  width: 180,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(40),
                                    boxShadow: [
                                      BoxShadow(
                                        blurRadius: 30,
                                        spreadRadius: 2,
                                        color: Colors.black.withOpacity(0.35),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        // Drohne – exakt zentriert, größer, sanft schwebend
                        AnimatedBuilder(
                          animation: _hover,
                          builder: (context, _) {
                            final t = (1 - math.cos(_hover.value * math.pi)) / 2; // smooth 0..1
                            final dy = lerpDouble(-6, 6, t)!;      // vertikales Schweben
                            final scale = lerpDouble(1.02, 0.98, t)!; // minimale Skalierung

                            return Transform.translate(
                              offset: Offset(0, dy),
                              child: Transform.scale(
                                scale: scale,
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: droneMaxWidth),
                                  child: Image.asset(
                                    'assets/drone_image.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ===== HEADLINE =====
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(fontSize: 26, height: 1.2, fontWeight: FontWeight.w900),
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
                      style: TextStyle(color: Colors.black, height: 1.35, fontSize: 15.5, letterSpacing: .25),
                    ),
                  ),
                  const SizedBox(height: 22),

                  Center(child: Container(height: 1.5, width: 120, color: Colors.black)),
                  const SizedBox(height: 22),

                  // ===== Buttons =====
                  Center(
                    child: Column(
                      children: [
                        SizedBox(
                          width: 230, height: 48,
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
                          width: 230, height: 48,
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

// kleine Hilfsfunktion
double? lerpDouble(num a, num b, double t) => a + (b - a) * t;
