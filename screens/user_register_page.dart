import 'package:assistech/screens/api_service.dart';
import 'package:flutter/material.dart';
import 'package:snippet_coder_utils/FormHelper.dart';
import 'package:http/http.dart' as http;
import 'package:assistech/models/shared_preferences_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final SharedPreferencesService _sharedPreferencesService =
      SharedPreferencesService();
  bool isAPIcallProcess = false;
  bool hidePassword = true;
  GlobalKey<FormState> globalFormKey = GlobalKey<FormState>();
  String? rut;
  String? password;
  String? roleId;
  String? roleName;

  void registerButtonPressed() async {
    if (globalFormKey.currentState!.validate()) {
      globalFormKey.currentState!.save();

      if (rut != null && password != null && roleId != null) {
        print('roleId: $roleId');
        setState(() {
          isAPIcallProcess = true;
        });

        try {
          final apiService =
              ApiService('http://192.168.100.81:3000', http.Client());
          final response =
              await apiService.register(rut!, password!, roleId!);

          setState(() {
            isAPIcallProcess = false;
          });

          if (response['message'] == 'Usuario registrado con éxito') {
            // Ajustado para comprobar el mensaje exacto
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Usuario registrado con éxito'),
                backgroundColor: Colors.green, // Fondo verde para el éxito
              ),
            );
            _resetFields();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Registro no exitoso'), // Ajusta este mensaje según lo necesitas
                backgroundColor: Colors.red, // Fondo rojo para un error
              ),
            );
          }
        } catch (e) {
          setState(() {
            isAPIcallProcess = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al registrar: $e'),
              backgroundColor: Colors.red, // Fondo rojo para un error
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Por favor complete todos los campos'),
            backgroundColor:
                Colors.orange, // Fondo naranja para una advertencia
          ),
        );
      }
    }
  }

  void _resetFields() {
    setState(() {
      rut = null;
      password = null;
      roleId = null;
      roleName = null;
    });

    globalFormKey.currentState?.reset();
  }

  List<dynamic> roles = [];

  @override
  void initState() {
    super.initState();
    fetchRoles();
  }

  void fetchRoles() async {
    try {
      final apiService =
          ApiService('http://192.168.100.81:3000', http.Client());
      final response = await apiService.getRoles();

      setState(() {
        roles = response;
      });
    } catch (e) {
      // Gestionar el error según lo necesario
    }
  }

  Future<void> _selectRole(BuildContext context) async {
    String? selectedRoleId;
    String? selectedRoleName;

    var result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Seleccione un Rol'),
          children: roles.map<Widget>((role) {
            return SimpleDialogOption(
              onPressed: () {
                Navigator.pop(
                    context, {'id': role['id'], 'nombre': role['nombre']});
              },
              child: Text(role['nombre']),
            );
          }).toList(),
        );
      },
    );

    if (result != null) {
      selectedRoleId = result['id'].toString();
      selectedRoleName = result['nombre'];

      setState(() {
        roleId = selectedRoleId;
        roleName = selectedRoleName;
        print(
            'roleId selected: $roleId'); // roleName debe ser una variable de instancia definida en tu clase
      });
    }
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
                    await _sharedPreferencesService
                        .clearUserDetails(); // Aquí puede añadir su lógica para cerrar sesión
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
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(''),
          backgroundColor: Colors.grey,
          
        ),
        backgroundColor: Colors.white,
        body: Form(
          key: globalFormKey,
          child: _registerUI(context),
        ),
      ),
    );
  }

  Widget _registerUI(BuildContext context) {
    return SingleChildScrollView(
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
                  ]),
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
                    'assest/icons/logotipo.png', //cambiar imagen
                    width: 250,
                    fit: BoxFit.contain,
                  ),
                )
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(
              left: 20,
              bottom: 30,
              top: 50,
            ),
            child: Text('Registro de Usuarios',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                  color: Colors.black,
                  fontFamily: 'Poppins',
                )),
          ),
          FormHelper.inputFieldWidget(
            context,
            'rut',
            'Rut',
            (onValidateVal) {
              if (onValidateVal.isEmpty) {
                return 'Rut can\'t be empty';
              }
              return null;
            },
            (onSavedVal) {
              rut = onSavedVal;
            },
            borderFocusColor: Colors.black,
            prefixIconColor: Colors.black,
            borderColor: Colors.black,
            textColor: Colors.black,
            hintColor: Colors.black.withOpacity(0.7),
            borderRadius: 10,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: FormHelper.inputFieldWidget(
              context,
              'password',
              'Password',
              (onValidateVal) {
                if (onValidateVal.isEmpty) {
                  return 'Password can\'t be empty';
                }
                return null;
              },
              (onSavedVal) {
                password = onSavedVal;
              },
              borderFocusColor: Colors.black,
              prefixIconColor: Colors.black,
              borderColor: Colors.black,
              textColor: Colors.black,
              hintColor: Colors.black.withOpacity(0.7),
              borderRadius: 10,
              obscureText: hidePassword,
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    hidePassword = !hidePassword;
                  });
                },
                icon: Icon(
                  hidePassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.black.withOpacity(0.7),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
            child: TextFormField(
              onTap: () {
                _selectRole(context);
              },
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Rol',
                labelStyle: TextStyle(color: Colors.black),
                hintText: roleName ?? 'Seleccione un Rol',
                hintStyle: TextStyle(color: Colors.black.withOpacity(0.7)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.black),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.black),
                ),
                prefixIcon: Icon(Icons.person, color: Colors.black),
                suffixIcon: Icon(Icons.arrow_drop_down, color: Colors.black),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          FormHelper.submitButton(
            'Registrar',
            registerButtonPressed,
            btnColor: Colors.white,
            borderColor: Colors.black,
            txtColor: Colors.black,
            borderRadius: 10,
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}
