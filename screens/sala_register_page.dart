import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final buttonStyle = ElevatedButton.styleFrom(
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
);

class SalaRegisterPage extends StatefulWidget {
  @override
  _SalaRegisterPageState createState() => _SalaRegisterPageState();
}

class _SalaRegisterPageState extends State<SalaRegisterPage> {
  final TextEditingController _codigoController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _radiusController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  Future<bool> _registerSala() async {
    if (_formKey.currentState!.validate()) {
      final String url = 'http://192.168.1.110:3000/registersala';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "codigo": _codigoController.text,
          "nombre": _nombreController.text,
          "latitude": double.parse(_latitudeController.text),
          "longitude": double.parse(_longitudeController.text),
          "radius": double.parse(_radiusController.text),
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sala registrada con éxito')),
        );
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al registrar sala')),
        );
        return false;
      }
    }
    return false;
  }

  bool isNumeric(String s) {
    if (s.isEmpty) return false;
    final n = num.tryParse(s);
    return (n == null) ? false : true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(0.0),
            child: Column(
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
                SizedBox(height: 20),
                _buildTextField(
                    controller: _codigoController,
                    labelText: 'Código de la Sala',
                    isNumericField: false),
                SizedBox(height: 10),
                _buildTextField(
                    controller: _nombreController,
                    labelText: 'Nombre de la Sala',
                    isNumericField: false),
                SizedBox(height: 10),
                _buildTextField(
                    controller: _latitudeController,
                    labelText: 'Latitud',
                    isNumericField: true),
                SizedBox(height: 10),
                _buildTextField(
                    controller: _longitudeController,
                    labelText: 'Longitud',
                    isNumericField: true),
                SizedBox(height: 10),
                _buildTextField(
                    controller: _radiusController,
                    labelText: 'Radio (metros)',
                    isNumericField: true),
                SizedBox(height: 20),
                ElevatedButton(
                  style: buttonStyle,
                  child: Text('Registrar Sala'),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _registerSala().then((success) {
                        if (success) {
                          Navigator.of(context).pop();
                        }
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required bool isNumericField,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumericField
            ? TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        decoration: InputDecoration(
          labelText: labelText,
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
            borderSide: BorderSide(color: Colors.black),
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
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
        validator: (value) {
          if (value!.isEmpty) {
            return 'Este campo no puede estar vacío';
          } else if (isNumericField && !isNumeric(value)) {
            return 'Ingrese un número válido';
          }
          return null;
        },
      ),
    );
  }
}
