import 'package:flutter/material.dart';
import 'routing/routes.dart';

void main() => runApp(const AirChifApp());

class AirChifApp extends StatelessWidget {
  const AirChifApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFFF0A51B); // Goldton wie im Mock

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'AirChif',
      routerConfig: router,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.light),
        scaffoldBackgroundColor: const Color(0xFFEFF7FF), // sehr helles Blau
        textTheme: const TextTheme(
          headlineMedium: TextStyle(fontWeight: FontWeight.w900),
          bodyMedium: TextStyle(height: 1.35),
        ),
      ),
    );
  }
}
