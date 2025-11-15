import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'manual_steering.dart'; // <--- importiert die Datei im gleichen Ordner

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  static const routePath = '/home';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().logout();
              Navigator.of(context).pushNamed('/sign-in');
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Willkommen auf der Home-Seite!'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  ManualSteering.routePath, // <--- verwendet die statische routePath
                );
              },
              child: const Text("Manual Steering öffnen"),
            ),
          ],
        ),
      ),
    );
  }
}
