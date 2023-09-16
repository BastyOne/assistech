import 'package:flutter/material.dart';
import 'qr_scan_screen.dart'; // Importa la clase QRScanScreen


class GeoFencingScreen extends StatefulWidget {
  @override
  _GeoFencingScreenState createState() => _GeoFencingScreenState();
}

class _GeoFencingScreenState extends State<GeoFencingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Geofencing Screen'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Bienvenido a la Pantalla de Geofencing',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => QRScanScreen()),
                );
              },
              child: Text('Iniciar Escaneo QR'),
            ),
            SizedBox(height: 20.0),
          
          ],
        ),
      ),
    );
  }
}
