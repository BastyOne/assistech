import 'dart:convert';
import 'package:assistech/screens/student_registration_screen.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
// Importa la pantalla de registro de estudiantes

class QRScanScreen extends StatefulWidget {
  const QRScanScreen({super.key});

  @override
  _QRScanScreenState createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> {
  final GlobalKey _qrKey = GlobalKey(debugLabel: 'QR');
  late QRViewController _qrViewController;
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Escaneo QR Screen',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black), // color de ícono de retroceso a negro
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: _qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () {
                // Navega de vuelta a la pantalla de inicio
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      _qrViewController = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      if (scanData.code != null) {
        final Map<String, dynamic> qrData = jsonDecode(scanData.code!);

        // Detener la cámara y liberar recursos
        _qrViewController.dispose();

        // Redirigir a la pantalla de registro de estudiantes con los datos del QR
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StudentRegistrationScreen(qrData: qrData),
          ),
        );
      }
    });
}

  @override
  void dispose() {
    _qrViewController.dispose();
      super.dispose();
  }
}
