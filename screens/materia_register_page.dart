import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MateriaRegisterPage extends StatefulWidget {
  @override
  _MateriaRegisterPageState createState() => _MateriaRegisterPageState();
}

class _MateriaRegisterPageState extends State<MateriaRegisterPage> {
  final TextEditingController _nombreController = TextEditingController();
  String? _errorMessage;
  List<String> _materiasRegistradas = []; // Asumo que inicialmente está vacía

  Future<void> _registerMateria() async {
    final String nombre = _nombreController.text;

    if (nombre.isEmpty) {
      setState(() {
        _errorMessage = "El nombre de la materia no puede estar vacío.";
      });
      return;
    }

    if (_materiasRegistradas.contains(nombre)) {
      setState(() {
        _errorMessage = "Esta materia ya ha sido registrada.";
      });
      return;
    }

    final String url = 'http://192.168.1.110:3000/register-materia';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "nombre": nombre,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        _materiasRegistradas.add(nombre);
        _errorMessage = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Materia registrada con éxito')),
      );
    } else {
      setState(() {
        _errorMessage = "Error al registrar materia.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(0.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 4,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.grey,
                      Colors.grey,
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(100),
                    bottomRight: Radius.circular(100),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Image.asset(
                        'assest/icons/logotipo.png',
                        width: 250,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              Text(
                'Registro de Materia',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                  color: Colors.black,
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(height: 30),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nombreController,
                      decoration: InputDecoration(
                        labelText: 'Nombre de la Materia',
                        labelStyle: TextStyle(
                          color: Colors.black.withOpacity(0.7),
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: _errorMessage == null
                                  ? Colors.black
                                  : Colors.red),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 1),
                        errorText: _errorMessage,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.black,
                  onPrimary: Colors.white,
                  textStyle: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text('Registrar Materia'),
                onPressed: () {
                  _registerMateria();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
