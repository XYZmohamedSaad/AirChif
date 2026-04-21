  import 'package:flutter/material.dart';
  import 'package:flutter_map/flutter_map.dart';
  import 'package:go_router/go_router.dart';
  import 'package:latlong2/latlong.dart';

  import 'home_screen.dart';
  import 'profile_screen.dart';
  import 'drone_settings.dart';

  /// ====== Journey-Model + einfacher Speicher (bleibt im ganzen App-Lauf bestehen) ======

  class Journey {
    final String name;
    List<LatLng> points;

    Journey({required this.name, required this.points});
  }

  class JourneyStore {
    JourneyStore._();

    static final JourneyStore instance = JourneyStore._();

    final List<Journey> _journeys = [];

    List<Journey> get journeys => List.unmodifiable(_journeys);

    /// Neuen Journey anlegen
    Journey addJourney(List<LatLng> points) {
      final nr = _journeys.length + 1;
      final journey = Journey(
        name: 'Journey $nr',
        points: List<LatLng>.from(points),
      );
      _journeys.add(journey);
      return journey;
    }

    /// Punkte eines bestehenden Journeys aktualisieren
    void updateJourney(Journey journey, List<LatLng> points) {
      journey.points = List<LatLng>.from(points);
    }
  }

  /// ====== JourneyWorkshop Screen ======

  class JourneyWorkshopScreen extends StatefulWidget {
    const JourneyWorkshopScreen({super.key});

    static const routePath = '/journey-workshop';

    @override
    State<JourneyWorkshopScreen> createState() => _JourneyWorkshopScreenState();
  }

  class _JourneyWorkshopScreenState extends State<JourneyWorkshopScreen> {
    // Karten-Zentrum z.B. Wien
    static const LatLng _initialCenter = LatLng(48.2082, 16.3738);

    final MapController _mapController = MapController();

    // aktuell ausgewählte Journey (Dropdown), null = "New journey"
    Journey? _selectedJourney;

    // Punkte, die gerade bearbeitet werden
    final List<LatLng> _currentPoints = [];

    @override
    void initState() {
      super.initState();
      // Wenn schon Journeys existieren, erste auswählen
      if (JourneyStore.instance.journeys.isNotEmpty) {
        _selectedJourney = JourneyStore.instance.journeys.first;
        _currentPoints.addAll(_selectedJourney!.points);
      } else {
        // sonst starten wir direkt im "New journey"-Modus mit leeren Punkten
        _selectedJourney = null;
      }
    }

    void _onMapTap(TapPosition tapPos, LatLng point) {
      setState(() {
        _currentPoints.add(point);
      });
    }

    void _saveJourney() {
      if (_currentPoints.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Füge zuerst Punkte auf der Karte hinzu.')),
        );
        return;
      }

      // Neuer Journey
      if (_selectedJourney == null) {
        final journey = JourneyStore.instance.addJourney(_currentPoints);
        setState(() {
          _selectedJourney = journey;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Journey "${journey.name}" gespeichert.')),
        );
      } else {
        // Bestehenden Journey aktualisieren
        JourneyStore.instance.updateJourney(_selectedJourney!, _currentPoints);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Journey "${_selectedJourney!.name}" aktualisiert.')),
        );
      }
    }

    @override
    Widget build(BuildContext context) {
      const Color boxYellow = Color(0xFFF4DA7A);
      const Color darkGold = Color(0xFFC58B07);

      final journeys = JourneyStore.instance.journeys;
      final pageBg = Theme.of(context).scaffoldBackgroundColor;

      // Marker aus aktuellen Punkten
      final markers = _currentPoints
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
                    // ===== Drohnenkarte oben (ohne "Connected") =====
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
                    ),

                    const SizedBox(height: 24),

                    // ===== Journey Auswahl =====
                    const Text(
                      'Create Journey',
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
                      items: [
                        // vorhandene Journeys
                        ...journeys.map(
                              (j) => DropdownMenuItem<Journey?>(
                            value: j,
                            child: Text(j.name),
                          ),
                        ),
                        // "New journey" – immer ganz unten
                        const DropdownMenuItem<Journey?>(
                          value: null,
                          child: Text('New journey'),
                        ),
                      ],
                      onChanged: (Journey? j) {
                        setState(() {
                          _selectedJourney = j;
                          _currentPoints
                            ..clear()
                            ..addAll(j?.points ?? []);
                        });
                      },
                    ),

                    const SizedBox(height: 18),

                    // ===== Karte =====
                    SizedBox(
                      height: 260,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: _initialCenter,
                            initialZoom: 14,
                            onTap: _onMapTap,
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

                    const SizedBox(height: 16),

                    // ===== Journey speichern =====
                    SizedBox(
                      height: 44,
                      child: FilledButton.icon(
                        onPressed: _saveJourney,
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: const BorderSide(color: Colors.black, width: 1.1),
                        ),
                        icon: const Icon(Icons.save),
                        label: Text(
                          _selectedJourney == null
                              ? 'Neuen Journey speichern'
                              : 'Journey speichern',
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        ),

        // ===== Bottom Navigation (wie bei Home) =====
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
                onPressed: () => context.go(JourneyWorkshopScreen.routePath),
              ),
            ],
          ),
        ),
      );
    }
  }
