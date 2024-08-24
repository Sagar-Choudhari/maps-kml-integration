import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:xml/xml.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter KML',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHome(),
    );
  }
}

class MyHome extends StatefulWidget {
  const MyHome({super.key});

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  String kmlString = "";

  Future<String> loadKmlFile() async {
    return await rootBundle.loadString('assets/VIPLBuilding.kml');
  }

  Future<void> parseKml() async {
    String kmlString = await loadKmlFile();
    final document = XmlDocument.parse(kmlString);
    // Extract the necessary elements from the KML file
    // For example, to get all Placemark elements:
    final placemarks = document.findAllElements('Placemark');
    for (var placemark in placemarks) {
      // Handle each placemark data here
      this.kmlString = placemark.toXmlString(pretty: true);
    }
    setState(() {});
  }

  List<Marker> _buildMarkersFromKml(String kmlString) {
    final List<Marker> markers = [];
    final document = XmlDocument.parse(kmlString);
    final placemarks = document.findAllElements('Placemark');

    for (var placemark in placemarks) {
      final name = placemark.findElements('name').first.text;
      final coordinatesString = placemark.findAllElements('coordinates').first.text;
      final coordinates = coordinatesString.split(',');
      final lat = double.parse(coordinates[1]);
      final lng = double.parse(coordinates[0]);

      markers.add(
        Marker(
          width: 80.0,
          height: 80.0,
          point: LatLng(lat, lng),
          child: const Icon(Icons.location_on, color: Colors.red),
        ),
      );
    }
    return markers;
  }

  @override
  void initState() {
    parseKml();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('KML on OpenStreetMap')),
      body: FlutterMap(
        options: const MapOptions(
          initialCenter: LatLng(37.7749, -122.4194),
          initialZoom: 11.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(markers: _buildMarkersFromKml(kmlString)),
        ],
      ),
    );
  }
}
