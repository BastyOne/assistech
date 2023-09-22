import 'package:assistech/screens/admin_panel.dart';
import 'package:assistech/screens/api_service.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:snippet_coder_utils/FormHelper.dart';
import 'package:snippet_coder_utils/ProgressHUD.dart';
import 'package:assistech/screens/main_screen.dart'; // Ajusta esto con la ruta correcta a tu archivo main_screen.dart


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isAPIcallProcess = false;
  bool hidePassword = true;
  GlobalKey<FormState> globalFormKey = GlobalKey<FormState>();
  String? username;
  String? password;

  final ApiService apiService = ApiService('http://192.168.100.81:3000', http.Client());

  void loginButtonPressed() async {
  if (globalFormKey.currentState!.validate()) {
    globalFormKey.currentState!.save();

    try {
      setState(() {
        isAPIcallProcess = true;
      });

      final response = await apiService.login(username!, password!);
      if (response.containsKey('user') && response.containsKey('role')) {
        print('Inicio de sesión exitoso');
        if (response['role'] == 'estudiante') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const GeoFencingScreen()), // Asegúrate de importar MainScreen
          );
        } else {
          if (response['role'] == 'administrador'){
            Navigator.pushReplacement(
              context, 
              MaterialPageRoute(builder: (context) => const AdmidPanelPage(),));
          }// Aquí puedes agregar la navegación para otros roles si es necesario
        }
      } else {
        // Mostrando un snackbar en caso de un error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al iniciar sesión: ${response['error']}'),
          ),
        );
      }
    } catch (e) {
      // Mostrando un snackbar en caso de una excepción
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al iniciar sesión: $e'),
        ),
      );
    } finally {
      setState(() {
        isAPIcallProcess = false;
      });
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: ProgressHUD(
          inAsyncCall: isAPIcallProcess,
          opacity: 0.3,
          key: UniqueKey(),
          child: Form(
            key: globalFormKey,
            child: _loginUI(context),
          ),
        ),
      ),
    );
  }

  Widget _loginUI(BuildContext context) {
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
            child: Text('Iniciar Sesion',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                  color: Colors.black,
                  fontFamily: 'Poppins',
                )),
          ),
          FormHelper.inputFieldWidget(
            context,
            'username',
            'UserName',
            (onValidateVal) {
              if (onValidateVal.isEmpty) {
                return 'Username can\'t be empty';
              }
              return null;
            },
            (onSavedVal) {
              username = onSavedVal;
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
                  color: Colors.black.withOpacity(0.7),
                  hidePassword ? Icons.visibility_off : Icons.visibility,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 25, top: 10),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14.0,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Forget Password?',
                      style: const TextStyle(
                        color: Colors.black,
                        decoration: TextDecoration.underline,
                        fontFamily: 'Poppins'
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          print('Forget Password');
                        },
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          FormHelper.submitButton(
            'Login',
            loginButtonPressed, // Función presionable aquí
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
