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



Future<List<Materia>> getMaterias() async {
  final response = await client.get(
    Uri.parse('http://192.168.100.81:3000/get-materias'),
  );

  if (response.statusCode == 200) {
    var materiasJson = jsonDecode(response.body);
    return materiasJson.map<Materia>((materia) => Materia.fromJson(materia)).toList();
  } else {
    throw Exception('Failed to load materias');
  }
}


Future<int?> crearClaseProgramada(int salaId, int materiaId, int profesorId) async {
  final response = await client.post(
    Uri.parse('http://192.168.100.81:3000/crear-clase-programada'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode({
      'sala_id': salaId,
      'materia_id': materiaId,
      'profesor_id': profesorId,
    }),
  );
  print('Response status code: ${response.statusCode}');
  print('Response body: ${response.body}');

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    print(data['message']);
    return data['claseId'];
  } else {
    print('Error al crear la clase programada: ${response.statusCode}');
    return null;
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

  Future<void> registrarAsistencia(int estudianteId, int claseProgramadaId, int salaId) async {
  final response = await client.post(
    Uri.parse('http://192.168.100.81:3000/registrar-asistencia'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode({
      'estudiante_id': estudianteId,
      'clase_programada_id': claseProgramadaId,
      'sala_id': salaId,  // Añadir esta línea
    }),
  );

  if (response.statusCode != 200) {
    throw Exception('Error al registrar asistencia');
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

class Materia {
  final int id;
  final String nombre;

  Materia({required this.id, required this.nombre});

  factory Materia.fromJson(Map<String, dynamic> json) {
    return Materia(
      id: json['id'],
      nombre: json['nombre'],
    );
  }
}
