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

  GeoFenceArea({required this.latitude, required this.longitude, required this.radius});
}

class StudentRegistrationScreen extends StatefulWidget {
  const StudentRegistrationScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _StudentRegistrationScreenState createState() =>
      _StudentRegistrationScreenState();
}

class _StudentRegistrationScreenState extends State<StudentRegistrationScreen> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _rutController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();


  StreamController<bool> geofenceStreamController = StreamController<bool>();

  Future<bool> isInsideGeoFenceArea(Position position, GeoFenceArea geoFenceArea) async {   
  double distanceInMeters = Geolocator.distanceBetween(
    position.latitude, 
    position.longitude, 
    geoFenceArea.latitude, 
    geoFenceArea.longitude
  );
  
  return distanceInMeters <= geoFenceArea.radius;
}

  void monitorGeoFenceArea(GeoFenceArea geoFenceArea) async {
    Geolocator.getPositionStream().listen((Position position) async {
      bool isInside = await isInsideGeoFenceArea(position, geoFenceArea);
      geofenceStreamController.add(isInside);
    });
  }


 Future<void> _registrarEstudiante() async {
  String nombre = _nombreController.text;
  String rut = _rutController.text;
  String correo = _correoController.text;

  LocationPermission permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }

  if (permission == LocationPermission.denied) {
    // Manejar el caso en que el usuario haya denegado el acceso a la ubicación
  } else if (permission == LocationPermission.deniedForever) {
    // Manejar el caso en que el usuario haya denegado permanentemente el acceso a la ubicación
  } else {
    final Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 10),
    );

    GeoFenceArea ucmGeoFenceArea = GeoFenceArea(
      latitude: -35.8691222, // reemplaza con la latitud de tu geofence
      longitude: -71.5962363	, // reemplaza con la longitud de tu geofence
      radius: 20.0, // reemplaza con el radio de tu geofence en metros
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
      final responseData = jsonDecode(response.body);

      if(responseData.containsKey('estudianteId')) {
        final int estudianteId = responseData['estudianteId'];

        final GeoFence newGeoFence = GeoFence(
          name: 'UCM',
          latitude: position.latitude,
          longitude: position.longitude,
          radius: 20.0,
          estudianteId: estudianteId,  // Utilizando estudianteId aquí
        );

        await newGeoFence.registrarEnBaseDeDatos();

        // Navegar a la pantalla de estado de geofencing
        // ignore: use_build_context_synchronously
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GeofencingStatusScreen(
              geofenceStream: geofenceStreamController.stream,
            ),
          ),
        );
      } else {
        // Manejar el error de estudianteId no encontrado en la respuesta
        print('estudianteId no encontrado en la respuesta');
      }
    } else {
      // Manejar el error de registro de estudiante
      print('Error al registrar estudiante: ${response.statusCode}');
    }

    _nombreController.clear();
    _rutController.clear();
    _correoController.clear();
  }
}

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Registro de Estudiantes',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'Poppins',
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: _rutController,
              decoration: const InputDecoration(labelText: 'RUT'),
            ),
            TextField(
              controller: _correoController,
              decoration: const InputDecoration(labelText: 'Correo'),
            ),
            const SizedBox(height: 16.0),
            Center(
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
                ),
                onPressed: _registrarEstudiante,
                child: const Text(
                  'Registrar Estudiante',
                  style: TextStyle(color: Colors.white, fontFamily: 'Poppins'),
                ),
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
                Navigator.pushNamed(context, '/main_screen');
                // Añade tu acción aquí para el botón Home
              },
            ),
          ],
        ),
      ),
    );
  }
}