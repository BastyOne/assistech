import 'package:flutter/material.dart';

class GeofencingStatusScreen extends StatefulWidget {
  final Stream<bool> geofenceStream;

  GeofencingStatusScreen({required this.geofenceStream});

  @override
  _GeofencingStatusScreenState createState() => _GeofencingStatusScreenState();
}

class _GeofencingStatusScreenState extends State<GeofencingStatusScreen> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Estado de Geofencing',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'Poppins',
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<bool>(
        stream: widget.geofenceStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // Mostrar un indicador de carga mientras se espera por los datos
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error de Geofence: ${snapshot.error}', style: TextStyle(fontFamily: 'Poppins'))); // Mostrar el mensaje de error si ocurre uno
          }

          if (!snapshot.hasData) {
            return Center(child: Text('No se han recibido datos', style: TextStyle(fontFamily: 'Poppins'))); // Mensaje en caso de que no haya datos
          }

          bool isInsideGeofence = snapshot.data!;
          
          return Center(child: Text(isInsideGeofence ? 'Dentro de Geofence' : 'Fuera de Geofence', style: TextStyle(fontFamily: 'Poppins'))); // Mostrar el estado de geofence basado en los datos recibidos
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.home),
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
