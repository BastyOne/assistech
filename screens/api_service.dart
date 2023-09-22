import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;
  http.Client client;

  ApiService(this.baseUrl, this.client);

  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('http://192.168.100.81:3000/login'),
      body: jsonEncode({'username': username, 'password': password}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al iniciar sesión');
    }
  }

  Future<Map<String, dynamic>> register(String username, String password, String roleId) async {
    final response = await http.post(
      Uri.parse('http://192.168.100.81:3000/register'), // Asegúrate de que esta es la ruta correcta para tu endpoint de registro
      body: jsonEncode({'username': username, 'password': password, 'roleId': roleId}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al registrarse');
    }
  }

   Future<List<dynamic>> getRoles() async {
    final response = await client.get(
      Uri.parse('http://192.168.100.81:3000/get-roles'), // Usa la ruta correcta para tu endpoint de roles
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load roles');
    }
  }





}



