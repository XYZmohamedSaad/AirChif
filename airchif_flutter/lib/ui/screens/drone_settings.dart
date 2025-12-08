import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'home_screen.dart';

class DroneSettingsScreen extends StatelessWidget {
  const DroneSettingsScreen({super.key});
  static const routePath = "/drone-settings";

  // Farben
  static const Color _boxYellow = Color(0xFFF4DA7A);
  static const Color _lightBeige = Color(0xFFF9EFCF);

  @override
  Widget build(BuildContext context) {
    final pageBg = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: pageBg,

      appBar: AppBar(
        title: const Text("Drone Settings"),
        backgroundColor: _boxYellow,
        elevation: 0,
      ),

      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),

            child: SingleChildScrollView(   // <--- FIX GEGEN ÜBERLAUF
              padding: const EdgeInsets.all(18.0),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                  // ================== DRONE IMAGE CARD (Kleiner gemacht) ==================
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _boxYellow,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.black.withOpacity(.55), width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                          color: Colors.black.withOpacity(.18),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      height: 180,   // <--- kleiner
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          'assets/drone_image.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // ================== INFO TILES (kleiner & hübscher) ==================
                  Row(
                    children: const [
                      Expanded(
                        child: _InfoTile(
                          icon: Icons.brightness_high_outlined,
                          title: "Firmware",
                          value: "1.18.0",
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: _InfoTile(
                          icon: Icons.videocam_outlined,
                          title: "Video",
                          value: "720p",
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: _InfoTile(
                          icon: Icons.error_outline,
                          title: "Errors",
                          value: "-",
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // ================== BATTERY ==================
                  const Text("Battery:", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  const _ProgressBar(percent: 0.36, color: Colors.green),
                  const Text("36% left", style: TextStyle(fontSize: 12)),

                  const SizedBox(height: 20),

                  // ================== MEMORY ==================
                  const Text("Memory:", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  const _ProgressBar(percent: 0.50, color: Colors.blue),
                  const Text("50% left", style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ),
        ),
      ),

      // ================== BOTTOM NAV ==================
      bottomNavigationBar: Container(
        height: 70,
        decoration: const BoxDecoration(
          color: _boxYellow,
          border: Border(top: BorderSide(color: Colors.black, width: 1.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.person, size: 32),
              onPressed: () => context.go("/profile"),
            ),
            IconButton(
              icon: const Icon(Icons.home, size: 34),
              onPressed: () => context.go(HomeScreen.routePath),
            ),
            IconButton(
              icon: const Icon(Icons.settings, size: 32),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}


// ===================================================================
//                          INFO TILE WIDGET (kleiner + schöner)
// ===================================================================
class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: DroneSettingsScreen._lightBeige,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black, width: 1.1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 22),     // kleiner
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 11)),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}


// ===================================================================
//                         PROGRESS BAR (klein wie bei Design)
// ===================================================================
class _ProgressBar extends StatelessWidget {
  final double percent;
  final Color color;

  const _ProgressBar({
    required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: LinearProgressIndicator(
        minHeight: 8,     // kleiner
        value: percent,
        backgroundColor: Colors.black12,
        valueColor: AlwaysStoppedAnimation(color),
      ),
    );
  }
}
