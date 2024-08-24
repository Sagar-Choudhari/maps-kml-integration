import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:xml/xml.dart' as xml;

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
  GoogleMapController? mapController;
  Set<Polygon> polygons = {}; // Set of polygons
  Set<Marker> markers = {}; // Set of markers

  @override
  void initState() {
    super.initState();
    loadKmlData();
  }

  Future<void> loadKmlData() async {
    try {
      // Load the KML file content from assets
      String kmlString = await rootBundle.loadString('assets/VIPLBuilding.kml');
      parseKmlData(kmlString);
    } catch (e) {
      print("Error loading KML file: $e");
    }
  }

  void parseKmlData(String kmlString) {
    final document = xml.XmlDocument.parse(kmlString);

    // Extract Placemark elements
    final placemarks = document.findAllElements('Placemark');

    for (var placemark in placemarks) {
      // Extract name and description for markers
      String name = placemark.findElements('name').first.text;
      String description = placemark.findElements('description').first.text;

      // Extract LookAt element for position data
      var lookAt = placemark.findElements('LookAt').first;
      double latitude = double.parse(lookAt.findElements('latitude').first.text);
      double longitude = double.parse(lookAt.findElements('longitude').first.text);

      // Add a marker
      markers.add(
        Marker(
          markerId: MarkerId(name),
          position: LatLng(latitude, longitude),
          infoWindow: InfoWindow(title: name, snippet: description),
        ),
      );

      // Extract Polygon coordinates
      var polygonElements = placemark.findElements('Polygon');
      for (var polygon in polygonElements) {
        var coordinatesString = polygon.findAllElements('coordinates').first.text.trim();
        var coordinatesList = coordinatesString.split(' ');

        List<LatLng> points = coordinatesList.map((coord) {
          var latLng = coord.split(',');
          double lon = double.parse(latLng[0]);
          double lat = double.parse(latLng[1]);
          return LatLng(lat, lon);
        }).toList();
        
        polygons.add(
          Polygon(
            polygonId: PolygonId(name),
            points: points,
            strokeWidth: 2,
            fillColor: Colors.blue.withOpacity(0.2),
            strokeColor: Colors.blue,
          ),
        );
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KML Data on Google Map'),
      ),
      body: GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
        },
        initialCameraPosition: CameraPosition(
          target: LatLng(18.479358, 73.804152), // Center to your specific area
          zoom: 17,
        ),
        markers: markers,
        polygons: polygons,
      ),
    );
  }
}
