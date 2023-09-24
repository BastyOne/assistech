import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;
  http.Client client;

  ApiService(this.baseUrl, this.client);

  Future<Map<String, dynamic>> login(String rut, String password) async {
    final response = await http.post(
      Uri.parse('http://192.168.100.81:3000/login'),
      body: jsonEncode({'rut': rut, 'password': password}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al iniciar sesión');
    }
  }

  Future<Map<String, dynamic>> register(String rut, String password, String roleId) async {
    final response = await http.post(
      Uri.parse('http://192.168.100.81:3000/register'), // Asegúrate de que esta es la ruta correcta para tu endpoint de registro
      body: jsonEncode({'rut': rut, 'password': password, 'roleId': roleId}),
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

  Future<List<Sala>> getSalas() async {
  final response = await client.get(
    Uri.parse('http://192.168.100.81:3000/get-salas'),
  );

  if (response.statusCode == 200) {
    var salas = jsonDecode(response.body);
    return salas.map<Sala>((sala) => Sala.fromJson(sala)).toList();
  } else {
    throw Exception('Failed to load salas');
  }
}



Future<List<String>> getMaterias() async {
  final response = await client.get(
    Uri.parse('http://192.168.100.81:3000/get-materias'),
  );

  if (response.statusCode == 200) {
    var materias = jsonDecode(response.body);
    return materias.map<String>((materia) => materia['nombre'].toString()).toList();
  } else {
    throw Exception('Failed to load materias');
  }
}

Future<SalaDetails> getSalaDetails(String salaId) async {
    final response = await client.get(
      Uri.parse('http://192.168.100.81:3000/salaDetails/$salaId'),
    );

    if (response.statusCode == 200) {
      return SalaDetails.fromJson(json.decode(response.body));
    } else {
        print("Error status code: ${response.statusCode}");
        print("Error body: ${response.body}");
      throw Exception('Failed to load Sala Details');
    }
  }
}

class SalaDetails {
  final double latitud;
  final double longitud;
  final double radio;

  SalaDetails({required this.latitud, required this.longitud, required this.radio});

  factory SalaDetails.fromJson(Map<String, dynamic> json) {
    return SalaDetails(
      latitud: json['latitude'],
      longitud: json['longitude'],
      radio: (json['radius'] as num).toDouble(),
    );
  }

}

class Sala {
  final String nombre;
  final int id;

  Sala({required this.nombre, required this.id});

  factory Sala.fromJson(Map<String, dynamic> json) {
    return Sala(
      nombre: json['nombre'],
      id: json['id'],
    );
  }
}

