import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import 'manual_steering.dart';

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
              context.go('/sign-in'); // <--- FIX
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
                context.push(ManualSteering.routePath); // <--- FIX
              },
              child: const Text("Manual Steering öffnen"),
            ),
          ],
        ),
      ),
    );
  }
}
