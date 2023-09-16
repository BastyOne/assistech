import 'package:flutter/material.dart';
import 'screens/geo_fencing_screen.dart'; // Importa la pantalla GeoFencingScreen



void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mi Aplicación',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // Cambia la pantalla inicial de MyApp a GeoFencingScreen
      home: GeoFencingScreen(),
    );
  }
}
