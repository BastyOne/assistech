import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'student_registration_screen.dart'; // Importa la pantalla de registro de estudiantes

class QRScanScreen extends StatefulWidget {
  const QRScanScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _QRScanScreenState createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> {
  late QRViewController _qrViewController;
  final GlobalKey _qrKey = GlobalKey(debugLabel: 'QR');

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
          Expanded(
            flex: 1,
            child: Center(
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
                ),
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
                child: const Text(
                  'Registrar Asistencia Manual',
                  style: TextStyle(color: Colors.white),
                ),
              ),
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
