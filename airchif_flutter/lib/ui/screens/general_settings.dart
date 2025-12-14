import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'drone-settings.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'journey_workshop.dart';


class GeneralSettingsScreen extends StatelessWidget {
  const GeneralSettingsScreen({super.key});

  /// Route-Pfad für GoRouter
  static const routePath = '/general-settings';

  // Farben im AirChif-Style
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ================= DRONE CARD =================
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _boxYellow,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: Colors.black.withOpacity(.55),
                        width: 1.4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 10,
                          offset: const Offset(0, 6),
                          color: Colors.black.withOpacity(.18),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
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
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'Connected',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.black,
                                backgroundColor: _lightBeige,
                                side: const BorderSide(
                                  color: Colors.black,
                                  width: 1.1,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 8,
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              // führt zur Detail-/Status-Seite der Drohne
                              onPressed: () =>
                                  context.go(DroneSettingsScreen.routePath),
                              child: const Text('Details'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ================= GRID MIT SETTINGS =================
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 18,
                    crossAxisSpacing: 18,
                    childAspectRatio: 1.0,
                    children: const [
                      _SettingsTile(
                        icon: Icons.videocam_outlined,
                        title: 'Camera Settings',
                        subtitle: 'Resolution, FPS',
                      ),
                      _SettingsTile(
                        icon: Icons.save_outlined,
                        title: 'Save Options',
                        subtitle: 'Storage, export',
                      ),
                      _SettingsTile(
                        icon: Icons.menu_book_outlined,
                        title: 'Credits',
                        subtitle: 'Team & libs',
                      ),
                      _SettingsTile(
                        icon: Icons.warning_amber_rounded,
                        title: 'Emergency',
                        subtitle: 'Return / land',
                      ),
                      _SettingsTile(
                        icon: Icons.settings_outlined,
                        title: 'App Settings',
                        subtitle: 'Theme, profile',
                      ),
                      _SettingsTile(
                        icon: Icons.radio_button_checked_outlined,
                        title: 'Flight Params',
                        subtitle: 'Speed, height',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      // ================= BOTTOM NAV =================
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
            // JOURNEY / WORKSHOP
            IconButton(
              icon: const Icon(Icons.pie_chart, size: 30),
              onPressed: () => context.go(JourneyWorkshopScreen.routePath),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= TILE WIDGET =================

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        // Platzhalter-Aktion
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$title – coming soon')),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: GeneralSettingsScreen._lightBeige,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.black, width: 1.1),
              ),
              child: Icon(icon, size: 34),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
