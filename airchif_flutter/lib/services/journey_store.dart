// lib/services/journey_store.dart
import 'package:latlong2/latlong.dart';

class JourneyStore {
  JourneyStore._();
  static final JourneyStore instance = JourneyStore._();

  // Start mit einer Journey
  final Map<String, List<LatLng>> _journeys = {
    'Journey 1': <LatLng>[],
  };

  Map<String, List<LatLng>> get journeys => _journeys;

  List<LatLng> pointsFor(String journeyName) =>
      _journeys[journeyName] ?? <LatLng>[];

  void addPoint(String journeyName, LatLng point) {
    final list = List<LatLng>.from(pointsFor(journeyName));
    list.add(point);
    _journeys[journeyName] = list;
  }

  /// Erzeugt eine neue Journey "Journey 2", "Journey 3", ...
  /// und gibt den Namen zurück.
  String createNextJourney() {
    final nextName = 'Journey ${_journeys.length + 1}';
    _journeys[nextName] = <LatLng>[];
    return nextName;
  }
}
