import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:assistech/models/shared_preferences_service.dart';
import 'package:assistech/screens/api_service.dart'; // Asegúrate de importar tu ApiService
import 'package:http/http.dart' as http;

class GeoFencingMonitorScreen extends StatefulWidget {
  final Stream<bool>? geofenceStream;
  final int? chequeoId;
  const GeoFencingMonitorScreen({Key? key, required this.geofenceStream, this.chequeoId})
      : super(key: key);

  @override
  _GeoFencingMonitorScreenState createState() => _GeoFencingMonitorScreenState();
}

class _GeoFencingMonitorScreenState extends State<GeoFencingMonitorScreen> {
  late final SharedPreferencesService _sharedPreferencesService;
  late StreamSubscription<Position> _positionStreamSubscription;
  late ApiService apiService; // Añade una instancia de ApiService
  double? currentLatitude;
  double? currentLongitude;
  double? geofenceLatitude;
  double? geofenceLongitude;
  double? geofenceRadius;
  bool isInsideGeofence = false;
  


  @override
  void initState() {
    super.initState();
    _sharedPreferencesService = SharedPreferencesService();
    apiService = ApiService("http://192.168.100.81:3000", http.Client()); // Inicializa el ApiService con la URL base
    _loadGeofenceDetails();
    _startPositionStream();
  }

  Future<void> _loadGeofenceDetails() async {
    final details = await _sharedPreferencesService.getGeoFenceDetails();
    setState(() {
      geofenceLatitude = details['latitude'] as double?;
      geofenceLongitude = details['longitude'] as double?;
      geofenceRadius = details['radius'] as double?;
    });
  }

  void _startPositionStream() {
    final stream = Geolocator.getPositionStream(
      desiredAccuracy: LocationAccuracy.high,
      distanceFilter: 10, // ajusta según tus necesidades
    );
    _positionStreamSubscription = stream.listen((position) {
      setState(() {
        currentLatitude = position.latitude;
        currentLongitude = position.longitude;
        _checkGeofenceStatus();
      });
    });
  }

  void _checkGeofenceStatus() {
    if (geofenceLatitude == null || geofenceLongitude == null || geofenceRadius == null) return;
    double distance = Geolocator.distanceBetween(
      currentLatitude!,
      currentLongitude!,
      geofenceLatitude!,
      geofenceLongitude!,
    );
    setState(() {
      isInsideGeofence = distance <= geofenceRadius!;
      if (!isInsideGeofence) {
        _handleGeofenceExit();
      }
    });
  }

  void _handleGeofenceExit() async {
    if(widget.chequeoId != null) {
      try {
        await apiService.actualizarChequeo(widget.chequeoId!); 
        print('Chequeo actualizado con éxito');
      } catch (e) {
        print('Error al actualizar chequeo: $e');
      }
    } else {
      print('chequeoId es null');
    }
  }

  @override
  void dispose() {
    _positionStreamSubscription.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'GeoFencing Monitor',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'Poppins',
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Current Latitude: $currentLatitude',
              style: TextStyle(fontFamily: 'Poppins'),
            ),
            Text(
              'Current Longitude: $currentLongitude',
              style: TextStyle(fontFamily: 'Poppins'),
            ),
            Text(
              'Geofence Latitude: $geofenceLatitude',
              style: TextStyle(fontFamily: 'Poppins'),
            ),
            Text(
              'Geofence Longitude: $geofenceLongitude',
              style: TextStyle(fontFamily: 'Poppins'),
            ),
            Text(
              'Geofence Radius: $geofenceRadius',
              style: TextStyle(fontFamily: 'Poppins'),
            ),
            Text(
              'Status: ${isInsideGeofence ? "Inside" : "Outside"} Geofence',
              style: TextStyle(
                color: isInsideGeofence ? Colors.green : Colors.red,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () {
                Navigator.pushNamed(context, '/main_screen'); // Cambia '/main_screen' a la ruta correcta
              },
            ),
          ],
        ),
      ),
    );
  }
}