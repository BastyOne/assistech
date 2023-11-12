import 'package:assistech/screens/list.dart';
import 'package:assistech/screens/login_screen.dart';
import 'package:assistech/screens/user_register_page.dart';
import 'package:flutter/material.dart';
import 'screens/main_screen.dart'; // Importa la pantalla main_screen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);  // Modificado para aceptar key como un argumento opcional

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mi Aplicación',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Poppins'),
      home: const LoginPage(),
      routes: {
        '/main_screen': (context) => const GeoFencingScreen(),
        '/login':(context) => const LoginPage(),
        '/register':(context) => const RegisterPage(),
        '/filtrar_asistencia': (context) => FiltrarAsistenciaScreen(),
      },
    );
  }
}
