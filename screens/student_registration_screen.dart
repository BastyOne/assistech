import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'geo_fencing_request.dart';
import 'geofencing_status.dart'; // Importa la pantalla de estado de geofencing

class GeoFenceArea {
  final double latitude;
  final double longitude;
  final double radius;

  GeoFenceArea(
      {required this.latitude, required this.longitude, required this.radius});
}

class StudentRegistrationScreen extends StatefulWidget {
  @override
  _StudentRegistrationScreenState createState() =>
      _StudentRegistrationScreenState();
}

class _StudentRegistrationScreenState extends State<StudentRegistrationScreen> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _rutController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();

  StreamController<bool> geofenceStreamController = StreamController<bool>();

  Future<bool> isInsideGeoFenceArea(
      Position position, GeoFenceArea geoFenceArea) async {
    double distanceInMeters = Geolocator.distanceBetween(position.latitude,
        position.longitude, geoFenceArea.latitude, geoFenceArea.longitude);

    return distanceInMeters <= geoFenceArea.radius;
  }

  void monitorGeoFenceArea(GeoFenceArea geoFenceArea) async {
    Geolocator.getPositionStream().listen((Position position) async {
      bool isInside = await isInsideGeoFenceArea(position, geoFenceArea);
      geofenceStreamController.add(isInside);
    });
  }

  Future<void> _registrarEstudiante(BuildContext context) async {
    String nombre = _nombreController.text;
    String rut = _rutController.text;
    String correo = _correoController.text;

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      // Manejar los casos de permisos denegados aquí
      return;
    }

    final Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: Duration(seconds: 10),
    );

    GeoFenceArea ucmGeoFenceArea = GeoFenceArea(
      latitude: -35.844992, // reemplaza con la latitud de tu geofence
      longitude: -71.597258, // reemplaza con la longitud de tu geofence
      radius: 60.0, // reemplaza con el radio de tu geofence en metros
    );

    
    monitorGeoFenceArea(ucmGeoFenceArea);

    Map<String, dynamic> studentData = {
      'nombre': nombre,
      'rut': rut,
      'correo': correo,
      'latitud': position.latitude,
      'longitud': position.longitude,
    };

    final response = await http.post(
      Uri.parse('http://192.168.100.81:3000/registrar-estudiante'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(studentData),
    );

    if (response.statusCode == 200) {
      // Añade lógica para obtener el estudianteId del cuerpo de la respuesta, si es necesario

      // Navegar a la pantalla de estado de geofencing
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GeofencingStatusScreen(
            geofenceStream: geofenceStreamController.stream,
          ),
        ),
      );
    } else {
      // Manejar el error de registro de estudiante
      print('Error al registrar estudiante: ${response.statusCode}');
    }

    _nombreController.clear();
    _rutController.clear();
    _correoController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registro de Estudiantes'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nombreController,
              decoration: InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: _rutController,
              decoration: InputDecoration(labelText: 'RUT'),
            ),
            TextField(
              controller: _correoController,
              decoration: InputDecoration(labelText: 'Correo'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _registrarEstudiante(context);
              },
              child: Text('Registrar Estudiante'),
            ),
          ],
        ),
      ),
    );
  }
}
