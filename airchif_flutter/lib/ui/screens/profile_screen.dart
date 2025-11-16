import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/auth_service.dart';
import 'home_screen.dart';
import 'sign_in_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  static const routePath = '/profile';

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;

  static const Color _accentYellow = Color(0xFFF2C23A);
  static const Color _cardYellow = Color(0xFFF4DA7A);
  static const Color _bottomNavYellow = Color(0xFFF4DA7A);
  static const Color _goldButton = Color(0xFFC58B07);

  final _auth = AuthService();

  Future<void> _logout() async {
    await _auth.logout();
    if (!mounted) return;
    context.go(SignInScreen.routePath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 90),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Titel
              const Center(
                child: Text(
                  'Profile',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Profilkarte mit Platzhalter-Bild
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: _cardYellow,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.black.withOpacity(0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 30, color: Colors.black),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hassan Demirbay', // Platzhalter
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'hassan.hassan@gmail.com', // Platzhalter
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              const Divider(thickness: 1),

              const SizedBox(height: 16),

              // ===== General Card =====
              _SectionCard(
                title: 'General',
                children: [
                  _SettingsRow(
                    icon: Icons.person_outline,
                    title: 'Edit Profile',
                    subtitle: 'Change username, email etc.',
                    onTap: () {
                      // TODO: Edit-Profile-Seite
                    },
                  ),
                  const SizedBox(height: 10),
                  _SettingsRow(
                    icon: Icons.lock_outline,
                    title: 'Change Password',
                    subtitle: 'Update and strengthen account security',
                    onTap: () {
                      // TODO: Change-Password-Seite
                    },
                  ),
                  const SizedBox(height: 10),
                  _SettingsRow(
                    icon: Icons.article_outlined,
                    title: 'Terms of Use',
                    subtitle: 'terms and so on',
                    onTap: () {
                      // TODO: Terms-of-use-Seite
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20),
              const Divider(thickness: 1),
              const SizedBox(height: 12),

              // ===== App Preferences Card =====
              _SectionCard(
                title: 'App Preferences',
                children: [
                  // Notifications mit Switch
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.notifications_none, size: 26),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Notifications',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Enable or disable notifications',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _notificationsEnabled,
                          activeColor: Colors.white,
                          activeTrackColor: _goldButton,
                          onChanged: (v) =>
                              setState(() => _notificationsEnabled = v),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  _SettingsRow(
                    icon: Icons.build_outlined,
                    title: 'General Settings',
                    subtitle: 'Settings for the app, drone etc.',
                    onTap: () {
                      // TODO: Settings-Seite
                    },
                  ),

                  const SizedBox(height: 10),

                  // Logout (rot)
                  _SettingsRow(
                    icon: Icons.logout,
                    title: 'Logout',
                    subtitle: 'Securely log out of account',
                    iconColor: Colors.red,
                    textColor: Colors.red,
                    onTap: _logout,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),

      // ===== Bottom Navigation Bar =====
      bottomNavigationBar: Container(
        height: 70,
        decoration: BoxDecoration(
          color: _bottomNavYellow,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(26),
            topRight: Radius.circular(26),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: IconButton(
                onPressed: () {
                  // schon auf Profile – nichts tun
                },
                icon: const Icon(Icons.person, size: 28),
              ),
            ),
            Expanded(
              child: IconButton(
                onPressed: () => context.go(HomeScreen.routePath),
                icon: const Icon(Icons.home, size: 28),
              ),
            ),
            Expanded(
              child: IconButton(
                onPressed: () {
                  // TODO: Statistik / Dashboard-Seite
                },
                icon: const Icon(Icons.pie_chart_outline, size: 28),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// gelbe Karten („General“, „App Preferences“)
class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF4DA7A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.2)),
      ),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          const Divider(thickness: 0.8),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

/// einzelne Zeile mit Icon, Titel, Untertitel und Pfeil
class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.iconColor,
    this.textColor,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color? iconColor;
  final Color? textColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color effectiveTextColor = textColor ?? Colors.black;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 26, color: iconColor ?? Colors.black),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: effectiveTextColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: effectiveTextColor.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 24, color: Colors.black),
          ],
        ),
      ),
    );
  }
}
