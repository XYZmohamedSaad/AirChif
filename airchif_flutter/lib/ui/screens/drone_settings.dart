import 'package:flutter/material.dart';

class DroneSettingsScreen extends StatelessWidget {
  const DroneSettingsScreen({super.key});
  static const routePath = '/drone-settings';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Drone Settings')),
      body: const Center(
        child: Text(
          'Drone Settings (Platzhalter)',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
