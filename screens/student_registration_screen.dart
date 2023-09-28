import 'dart:async';
import 'package:assistech/models/shared_preferences_service.dart';
import 'package:assistech/screens/api_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'geo_fencing_request.dart';
import 'geofencing_status.dart';

class GeoFenceArea {
  final double latitude;
  final double longitude;
  final double radius;

  GeoFenceArea(
      {required this.latitude, required this.longitude, required this.radius});
}

class StudentRegistrationScreen extends StatefulWidget {
  final Map<String, dynamic> qrData;
  const StudentRegistrationScreen({super.key, required this.qrData});

  @override
  // ignore: library_private_types_in_public_api
  _StudentRegistrationScreenState createState() =>
      _StudentRegistrationScreenState();
}

class _StudentRegistrationScreenState extends State<StudentRegistrationScreen> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _rutController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final ApiService apiService =
      ApiService("http://192.168.100.81:3000", http.Client());

  StreamController<bool> geofenceStreamController = StreamController<bool>();

  String _storedRut = '';

  @override
  void initState() {
    super.initState();
    _loadStoredRut();
  }

  _loadStoredRut() async {
    SharedPreferencesService sharedPreferencesService =
        SharedPreferencesService();
    Map<String, dynamic> userDetails =
        await sharedPreferencesService.getUserDetails();

    setState(() {
      _storedRut = userDetails['rut'] as String;
    });
  }

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

      double latitude = widget.qrData['latitude']?.toDouble() ?? 0.0;
      double longitude = widget.qrData['longitude']?.toDouble() ?? 0.0;
      double radius = widget.qrData['radius']?.toDouble() ?? 0.0;
      int claseProgramadaId = widget.qrData['claseProgramadaId'] ?? 0;
      print('QR Data: ${widget.qrData}');
      print('Contenido de widget.qrData: ${widget.qrData}');

      String materia = widget.qrData['materia'] ?? "";

      GeoFenceArea qrGeoFenceArea = GeoFenceArea(
          latitude: latitude, longitude: longitude, radius: radius);

      bool isInside = await isInsideGeoFenceArea(position, qrGeoFenceArea);

      if (!isInside) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Error"),
            content: Text(
                "No estás en la ubicación correcta para registrar tu asistencia."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Entendido"),
              )
            ],
          ),
        );
        return;
      }

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

        if (responseData.containsKey('estudianteId')) {
          final int estudianteId = responseData['estudianteId'];
          final GeoFence newGeoFence = GeoFence(
            name: materia,
            latitude: position.latitude,
            longitude: position.longitude,
            radius: 20.0,
            estudianteId: estudianteId,
          );

          await newGeoFence.registrarEnBaseDeDatos();
          await apiService.registrarAsistencia(estudianteId, claseProgramadaId);

          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Éxito"),
              content: Text("Tu asistencia ha sido registrada con éxito."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Cierra el AlertDialog
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GeofencingStatusScreen(
                          geofenceStream: geofenceStreamController.stream,
                        ),
                      ),
                    );
                  },
                  child: Text("Entendido"),
                )
              ],
            ),
          );
        } else {
          print('estudianteId no encontrado en la respuesta');
        }
      } else {
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
            Text(
              'Latitud: ${widget.qrData['latitude']}, Longitud: ${widget.qrData['longitude']}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: TextEditingController(text: _storedRut),
              decoration: const InputDecoration(labelText: 'RUT'),
              enabled: false,
            ),
            TextField(
              controller: _correoController,
              decoration: const InputDecoration(labelText: 'Correo'),
            ),
            const SizedBox(height: 16.0),
            Center(
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.black),
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
              },
            ),
          ],
        ),
      ),
    );
  }
}
