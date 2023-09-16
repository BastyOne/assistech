import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'student_registration_screen.dart'; // Importa la pantalla de registro de estudiantes

class QRScanScreen extends StatefulWidget {
  @override
  _QRScanScreenState createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> {
  late QRViewController _qrViewController;
  final GlobalKey _qrKey = GlobalKey(debugLabel: 'QR');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Escaneo QR Screen'),
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
          Expanded(
            flex: 1,
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  // Puedes agregar aquí la lógica para detener la cámara si es necesario
                  if (_qrViewController != null) {
                    _qrViewController.dispose();
                  }

                  // Navega a la pantalla de registro de estudiantes
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => StudentRegistrationScreen()),
                  );
                },
                child: Text('Registrar Asistencia Manual'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      _qrViewController = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      // Aquí puedes manejar la información escaneada
      print('Escaneado: $scanData');
      
      // Puedes agregar aquí la lógica para detener la cámara si es necesario
      if (_qrViewController != null) {
        _qrViewController.dispose();
      }
    });
  }

  @override
  void dispose() {
    if (_qrViewController != null) {
      _qrViewController.dispose();
    }
    super.dispose();
  }
}
