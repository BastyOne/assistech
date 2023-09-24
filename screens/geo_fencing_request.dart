import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void requestLocationPermission() async {
  // Verificar si el usuario ya otorgó permiso
  LocationPermission permission = await Geolocator.checkPermission();
  
  if (permission == LocationPermission.denied) {
    // Si no se han otorgado permisos, solicitarlos
    permission = await Geolocator.requestPermission();
  }
  
  if (permission == LocationPermission.denied) {
    // El usuario ha denegado el acceso a la ubicación, puedes mostrar un mensaje para informar.
  } else if (permission == LocationPermission.deniedForever) {
    // El usuario ha denegado el acceso a la ubicación de forma permanente, puedes mostrar un mensaje para guiar al usuario a la configuración de la aplicación.
  } else {
    // Permiso de ubicación concedido, puedes continuar con la obtención de la ubicación.
    final Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high, // Precisión alta
      timeLimit: const Duration(seconds: 10), // Opcional: límite de tiempo para la obtención de la ubicación
    );

    // La variable 'position' ahora contiene la ubicación actual del dispositivo
  }
}

class GeoFence {
  final String name;
  final double latitude;
  final double longitude;
  final double radius;
  final int estudianteId;  // Añade esto para almacenar el estudiante_id

  GeoFence({required this.name, required this.latitude, required this.longitude, required this.radius, required this.estudianteId});

  Future<void> registrarEnBaseDeDatos() async {
    Map<String, dynamic> geoFenceData = {
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
      'estudiante_id': estudianteId,  // Añade esto para enviar el estudiante_id
    };

    final response = await http.post(
      Uri.parse('http://192.168.100.81:3000/registrar-geofence'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(geoFenceData),
    );

    if (response.statusCode == 200) {
      print('Geofence registrado con éxito');
    } else {
      print('Error al registrar geofence: ${response.statusCode}');
    }
  }
}
