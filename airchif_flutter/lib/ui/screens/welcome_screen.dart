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

    // Größen
    const double heroHeight = 320; // Box-Höhe

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
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // Insets, damit die Drohne "fast" die Ecken berührt, aber nicht raus ragt
                        const edgeInset = 1.0;
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            // Reines H-Icon ohne Muster/Striche
                            CustomPaint(
                              size: Size(constraints.maxWidth, constraints.maxHeight),
                              painter: _LandingPadPainter(
                                color: const Color(0xFF4A4A4A), // dunkles Grau (heller als Schwarz)
                                ringStroke: 9,
                                hBarWidth: 13,
                                hBarHeightFactor: 0.30, // Höhe der H-Schenkel relativ zur Box
                                ringScale: 0.66, // Ring-Durchmesser relativ zur Box
                              ),
                            ),

                            // Drohne – maximal groß innerhalb der Box
                            Positioned.fill(
                              left: edgeInset,
                              right: edgeInset,
                              top: edgeInset,
                              bottom: edgeInset,
                              child: FittedBox(
                                fit: BoxFit.contain,
                                child: Image.asset('assets/drone_image.png'),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ===== HEADLINE =====
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 26,
                        height: 1.2,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                      children: [
                        TextSpan(text: 'Save the '),
                        TextSpan(text: 'World and its Future\n', style: TextStyle(color: accentYellow)),
                        TextSpan(text: 'From a '),
                        TextSpan(text: 'Birds Perspective', style: TextStyle(color: accentYellow)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ===== AirChif =====
                  const Text(
                    'AirChif',
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

/// Zeichnet das Landing-Pad (Ring + H) ohne Muster/Striche.
class _LandingPadPainter extends CustomPainter {
  _LandingPadPainter({
    required this.color,
    required this.ringStroke,
    required this.hBarWidth,
    required this.hBarHeightFactor,
    required this.ringScale,
  });

  final Color color;
  final double ringStroke;
  final double hBarWidth;
  final double hBarHeightFactor; // 0..1 der Boxhöhe
  final double ringScale; // 0..1: wie groß der Ring relativ zur Box ist

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide * ringScale) / 2;

    // Ring
    final ring = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = ringStroke
      ..isAntiAlias = true;
    canvas.drawCircle(center, radius, ring);

    // H-Schenkel
    final hHeight = size.height * hBarHeightFactor;
    final hTop = center.dy - hHeight / 2;
    final hBottom = center.dy + hHeight / 2;

    final barPaint = Paint()..color = color..isAntiAlias = true;

    final leftBar = Rect.fromCenter(
      center: Offset(center.dx - radius * 0.28, center.dy),
      width: hBarWidth,
      height: hHeight,
    );
    final rightBar = Rect.fromCenter(
      center: Offset(center.dx + radius * 0.28, center.dy),
      width: hBarWidth,
      height: hHeight,
    );

    canvas.drawRRect(RRect.fromRectAndRadius(leftBar, const Radius.circular(6)), barPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(rightBar, const Radius.circular(6)), barPaint);
  }

  @override
  bool shouldRepaint(covariant _LandingPadPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.ringStroke != ringStroke ||
        oldDelegate.hBarWidth != hBarWidth ||
        oldDelegate.hBarHeightFactor != hBarHeightFactor ||
        oldDelegate.ringScale != ringScale;
  }
}
