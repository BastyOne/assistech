import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'qr_scan_screen.dart';
import 'package:assistech/models/shared_preferences_service.dart';

class GeoFencingScreen extends StatefulWidget {
  const GeoFencingScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _GeoFencingScreenState createState() => _GeoFencingScreenState();
}

class _GeoFencingScreenState extends State<GeoFencingScreen> {
  int _selectedIndex = 1;
  final SharedPreferencesService _sharedPreferencesService = SharedPreferencesService();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 2) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const QRScanScreen()),
        );
      }
    });
  }

  void _showLogoutDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text(
          'Cerrar Sesión',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Poppins',
          ),
        ),
        content: const Text(
          '¿Estás seguro de que deseas cerrar sesión?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Poppins',
          ),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                child: const Text(
                  'Cancelar',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              const Spacer(),
              TextButton(
                child: const Text(
                  'Cerrar Sesión',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                  ),
                ),
                onPressed: () async {
                  await _sharedPreferencesService.clearUserDetails();                 // Aquí puede añadir su lógica para cerrar sesión
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacementNamed('/login');
                },
              ),
            ],
          ),
        ],
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Bienvenido a la Pantalla de Geofencing',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'Geofencing',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code),
            label: 'Escaneo QR',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }

  AppBar appBar() {
    return AppBar(
      title: const Text(
        'Bienvenido a Assistech',
        style: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 0.0,
      centerTitle: true,
      leading: Container(
        margin: const EdgeInsets.all(10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 255, 255),
          borderRadius: BorderRadius.circular(10),
        ),
        child: SvgPicture.asset(
          'assest/icons/Arrow - Left 2.svg',
          width: 20,
          height: 20,
        ),
      ),
      actions: [
        GestureDetector(
          onTap: _showLogoutDialog,
          child: Container(
            margin: const EdgeInsets.all(10),
            alignment: Alignment.center,
            width: 37,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 255, 255, 255),
              borderRadius: BorderRadius.circular(10),
            ),
            child: SvgPicture.asset(
              'assest/icons/dots.svg',
              width: 5,
              height: 5,
            ),
          ),
        ),
      ],
    );
  }
}
