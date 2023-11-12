import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:assistech/models/shared_preferences_service.dart';
import 'package:assistech/screens/api_service.dart';
import 'package:http/http.dart' as http;

class FiltrarAsistenciaScreen extends StatefulWidget {
  @override
  _FiltrarAsistenciaScreenState createState() => _FiltrarAsistenciaScreenState();
}

class _FiltrarAsistenciaScreenState extends State<FiltrarAsistenciaScreen> {
  final ApiService _apiService = ApiService('http://192.168.100.81:3000', http.Client());
  final TextEditingController _materiaController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();
  final TextEditingController _salaController = TextEditingController();
  List<Asistencia> _asistencias = [];

  @override
  void dispose() {
    _materiaController.dispose();
    _fechaController.dispose();
    _salaController.dispose();
    super.dispose();
  }

  void _filtrarAsistencia() async {
    String materia = _materiaController.text;
    String fecha = _fechaController.text;
    String sala = _salaController.text;

    try {
      List<Asistencia> resultados = await _apiService.filtrarAsistenciaCombinada(
        materia: materia.isNotEmpty ? materia : null,
        fecha: fecha.isNotEmpty ? fecha : null,
        sala: sala.isNotEmpty ? sala : null,
      );
      setState(() {
        _asistencias = resultados;
      });
    } catch (e) {
      // Maneja el error aquí, por ejemplo mostrando un snackbar o un dialog
      print('Error al filtrar asistencias: $e');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        _fechaController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Filtrar Asistencia'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _materiaController,
                decoration: InputDecoration(
                  labelText: 'Materia',
                  suffixIcon: Icon(Icons.book),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: TextField(
                    controller: _fechaController,
                    decoration: InputDecoration(
                      labelText: 'Fecha',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _salaController,
                decoration: InputDecoration(
                  labelText: 'Sala',
                  suffixIcon: Icon(Icons.meeting_room),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _filtrarAsistencia,
              child: Text('Buscar'),
            ),
            _asistencias.isNotEmpty
                ? ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _asistencias.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(_asistencias[index].nombreEstudiante),
                        subtitle: Text(DateFormat('yyyy-MM-dd – kk:mm').format(_asistencias[index].fechaHora)),
                      );
                    },
                  )
                : Text('No hay resultados para mostrar', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
