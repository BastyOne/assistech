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
    return StreamBuilder<bool>(
      stream: widget.geofenceStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData) {
          return Center(child: Text('Error de Geofence'));
        }

        bool isInsideGeofence = snapshot.data!;
        
        return Center(child: Text(isInsideGeofence ? 'Dentro de Geofence' : 'Fuera de Geofence'));
      },
    );
  }
}
