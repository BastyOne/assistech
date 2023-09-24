import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:assistech/screens/api_service.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:qr_flutter/qr_flutter.dart' ;


class ProfesorSchedulePage extends StatefulWidget {
  const ProfesorSchedulePage({Key? key}) : super(key: key);

  @override
  _ProfesorSchedulePageState createState() => _ProfesorSchedulePageState();
}

class _ProfesorSchedulePageState extends State<ProfesorSchedulePage> {
  final ApiService apiService =
      ApiService('http://192.168.100.81:3000', http.Client());

  String? selectedSalaName;
  int? selectedSalaId;
  String? selectedMateria;
  String? qrData;
  List<Sala> salasList = [];
  List<String> materiasList = [];

  @override
  void initState() {
    super.initState();
    fetchSalasAndMaterias();
  }

  Future<void> fetchSalasAndMaterias() async {
    List<Sala> fetchedSalas = await apiService.getSalas();
    List<String> fetchedMaterias = await apiService.getMaterias();

    setState(() {
      salasList = fetchedSalas;
      materiasList = fetchedMaterias;
    });
  }

  Future<void> _selectSala(BuildContext context) async {
  var selected = await showDialog<Sala>(
    context: context,
    builder: (BuildContext context) {
      return SimpleDialog(
        title: const Text('Seleccione una Sala'),
        children: salasList.map<Widget>((sala) {
          return SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context, sala);
            },
            child: Text(sala.nombre),
          );
        }).toList(),
      );
    },
  );

  if (selected != null) {
    setState(() {
      selectedSalaName = selected.nombre;
      selectedSalaId = selected.id;
    });
  }
}


  Future<void> _selectMateria(BuildContext context) async {
    var selected = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Seleccione una Materia'),
          children: materiasList.map<Widget>((materia) {
            return SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, materia);
              },
              child: Text(materia),
            );
          }).toList(),
        );
      },
    );

    if (selected != null) {
      setState(() {
        selectedMateria = selected;
      });
    }
  }

  Future<void> generateQRData() async {
    if (selectedSalaId != null && selectedMateria != null) {
       final salaDetails = await apiService.getSalaDetails(selectedSalaId!.toString());

      final String data = jsonEncode({
        'latitude': salaDetails.latitud,
        'longitude': salaDetails.longitud,
        'radius': salaDetails.radio,
        'materia': selectedMateria,
      });

      setState(() {
        qrData = data;
      });
    }
  }

  

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Programación de Clases',
              style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
                child: TextFormField(
                  onTap: () {
                    _selectSala(context);
                  },
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Sala',
                    labelStyle: TextStyle(color: Colors.black),
                    hintText: selectedSalaId?.toString() ?? 'Seleccione una Sala',
                    hintStyle: TextStyle(color: Colors.black.withOpacity(0.7)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    prefixIcon: Icon(Icons.class_, color: Colors.black),
                    suffixIcon:
                        Icon(Icons.arrow_drop_down, color: Colors.black),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                child: TextFormField(
                  onTap: () {
                    _selectMateria(context);
                  },
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Materia',
                    labelStyle: TextStyle(color: Colors.black),
                    hintText: selectedMateria ?? 'Seleccione una Materia',
                    hintStyle: TextStyle(color: Colors.black.withOpacity(0.7)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    prefixIcon: Icon(Icons.book, color: Colors.black),
                    suffixIcon:
                        Icon(Icons.arrow_drop_down, color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  generateQRData();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  side: const BorderSide(color: Colors.black),
                ),
                child: const Text(
                  'Generar QR',
                  style: TextStyle(color: Colors.white, fontFamily: 'Poppins'),
                ),
              ),
              const SizedBox(height: 20),
              if (qrData != null)
                QrImageView(
                  data: qrData!,
                  version: QrVersions.auto,
                  size: 200.0,
                )
            ],
          ),
        ),
      ),
    );
  }
}
