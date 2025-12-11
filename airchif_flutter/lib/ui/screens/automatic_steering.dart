import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import 'home_screen.dart';
import 'profile_screen.dart';
import 'journey_workshop.dart';
import 'drone_settings.dart';

class AutomaticSteeringScreen extends StatefulWidget {
  static const routePath = '/automatic';

  const AutomaticSteeringScreen({super.key});

  @override
  State<AutomaticSteeringScreen> createState() =>
      _AutomaticSteeringScreenState();
}

class _AutomaticSteeringScreenState extends State<AutomaticSteeringScreen> {
  // Standard-Karten-Mitte (Wien)
  static const LatLng _initialCenter = LatLng(48.2082, 16.3738);

  final MapController _mapController = MapController();

  Journey? _selectedJourney;

  @override
  void initState() {
    super.initState();
    final journeys = JourneyStore.instance.journeys;
    if (journeys.isNotEmpty) {
      _selectedJourney = journeys.first;
    }
  }

  /// Start Journey – hier würdest du später die Punkte an dein
  /// Drohnen-Steuerungs-Backend schicken.
  void _startJourney() {
    final journey = _selectedJourney;

    if (journey == null || journey.points.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bitte zuerst einen Journey mit Punkten auswählen.'),
        ),
      );
      return;
    }

    // Punkte in JSON wandeln – das kann dein Kollege 1:1 ans Backend schicken
    final payload = {
      'journey_name': journey.name,
      'points': journey.points
          .map((p) => {'lat': p.latitude, 'lng': p.longitude})
          .toList(),
    };
    final jsonString = jsonEncode(payload);

    debugPrint('AUTOMATIC STEERING PAYLOAD: $jsonString');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Journey "${journey.name}" gestartet (Demo).'),
      ),
    );

    // TODO: hier später HTTP-Request / WebSocket o.Ä. zum Backend einbauen
  }

  @override
  Widget build(BuildContext context) {
    const Color boxYellow = Color(0xFFF4DA7A);
    const Color darkGold = Color(0xFFC58B07);

    final pageBg = Theme.of(context).scaffoldBackgroundColor;
    final journeys = JourneyStore.instance.journeys;

    // Falls aktueller Journey Punkte hat, Karte darauf zentrieren
    LatLng center = _initialCenter;
    if (_selectedJourney != null && _selectedJourney!.points.isNotEmpty) {
      center = _selectedJourney!.points.first;
    }

    final markers = (_selectedJourney?.points ?? [])
        .map(
          (p) => Marker(
        point: p,
        width: 30,
        height: 30,
        child: const Icon(
          Icons.location_on,
          color: Colors.red,
          size: 28,
        ),
      ),
    )
        .toList();

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
                  // ===================== DRONE CARD =====================
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: boxYellow,
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
                        // "Connected" + Details-Button wie im Mockup
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
                            const SizedBox(height: 12),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.black,
                                side: const BorderSide(
                                  color: Colors.black,
                                  width: 1.1,
                                ),
                                backgroundColor: Colors.white,
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
                              onPressed: () =>
                                  context.go(DroneSettingsScreen.routePath),
                              child: const Text('Details'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ===================== JOURNEY DROPDOWN =====================
                  const Text(
                    'Select Journey',
                    style: TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                  const SizedBox(height: 6),

                  DropdownButtonFormField<Journey?>(
                    value: _selectedJourney,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                        const BorderSide(color: Colors.black, width: 1.1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                        const BorderSide(color: Colors.black, width: 1.1),
                      ),
                    ),
                    items: journeys
                        .map(
                          (j) => DropdownMenuItem<Journey?>(
                        value: j,
                        child: Text(j.name),
                      ),
                    )
                        .toList(),
                    onChanged: (Journey? j) {
                      setState(() {
                        _selectedJourney = j;
                      });
                    },
                    hint: const Text('No journeys saved yet'),
                  ),

                  const SizedBox(height: 18),

                  // ===================== MAP =====================
                  SizedBox(
                    height: 260,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: center,
                          initialZoom: 14,
                          // in Automatic Mode soll man nichts Neues setzen,
                          // deshalb KEIN onTap hier
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                            'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                            subdomains: const ['a', 'b', 'c'],
                            userAgentPackageName: 'com.example.airchif',
                          ),
                          MarkerLayer(markers: markers),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ===================== START JOURNEY BUTTON =====================
                  SizedBox(
                    height: 50,
                    child: FilledButton.icon(
                      onPressed: _startJourney,
                      style: FilledButton.styleFrom(
                        backgroundColor: darkGold,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        side: const BorderSide(color: Colors.black, width: 1.2),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      icon: const Icon(Icons.rocket_launch_outlined),
                      label: const Text('Start Journey'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      // ===================== BOTTOM NAVIGATION =====================
      bottomNavigationBar: Container(
        height: 70,
        decoration: const BoxDecoration(
          color: boxYellow,
          border: Border(
            top: BorderSide(color: Colors.black, width: 1.2),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.person, size: 30),
              onPressed: () => context.go(ProfileScreen.routePath),
            ),
            IconButton(
              icon: const Icon(Icons.home, size: 32),
              onPressed: () => context.go(HomeScreen.routePath),
            ),
            IconButton(
              icon: const Icon(Icons.pie_chart, size: 30),
              onPressed: () =>
                  context.go(JourneyWorkshopScreen.routePath),
            ),
          ],
        ),
      ),
    );
  }
}
