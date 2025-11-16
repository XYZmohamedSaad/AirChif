import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'manual_steering.dart';
import 'profile_screen.dart';
import 'automatic_steering.dart';
import 'journey_workshop.dart';
import 'drone_settings.dart'; // Platzhalter-Seite, die du erstellen wirst

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  static const routePath = '/home';

  // Farben
  static const Color _boxYellow = Color(0xFFF4DA7A);
  static const Color _lightBeige = Color(0xFFF9EFCF);

  @override
  Widget build(BuildContext context) {
    final pageBg = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: pageBg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ===== DRONE CARD =====
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _boxYellow,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: Colors.black.withOpacity(.55), width: 1.4),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 10,
                          offset: const Offset(0, 6),
                          color: Colors.black.withOpacity(.18),
                        ),
                      ],
                    ),
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: 4 / 3,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.asset(
                            'assets/drone_image.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ===== BUTTONS: automatic / manual steering =====
                  Row(
                    children: [
                      Expanded(
                        child: _HomeMenuButton(
                          label: 'automatic steering',
                          onTap: () => context.go(AutomaticSteeringScreen.routePath),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _HomeMenuButton(
                          label: 'manual steering',
                          onTap: () => context.go(ManualSteering.routePath),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ===== journey workshop =====
                  _HomeMenuButton(
                    label: 'journey workshop',
                    onTap: () => context.go(JourneyWorkshopScreen.routePath),
                  ),

                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),

      // ===== BOTTOM NAVIGATION =====
      bottomNavigationBar: Container(
        height: 70,
        decoration: const BoxDecoration(
          color: _boxYellow,
          border: Border(
            top: BorderSide(color: Colors.black, width: 1.2),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // PROFILE
            IconButton(
              icon: const Icon(Icons.person, size: 30),
              onPressed: () => context.go(ProfileScreen.routePath),
            ),

            // HOME
            IconButton(
              icon: const Icon(Icons.home, size: 32),
              onPressed: () => context.go(HomeScreen.routePath),
            ),

            // DROHNEN SETTINGS (PLATZHALTER!)
            IconButton(
              icon: const Icon(Icons.settings, size: 30),
              onPressed: () => context.go(DroneSettingsScreen.routePath),
            ),
          ],
        ),
      ),
    );
  }
}

/// Gemeinsamer Button-Style
class _HomeMenuButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _HomeMenuButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: HomeScreen._boxYellow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: const BorderSide(color: Colors.black, width: 1.2),
          elevation: 2,
          shadowColor: Colors.black.withOpacity(.2),
          foregroundColor: Colors.black,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        child: Text(label),
      ),
    );
  }
}
