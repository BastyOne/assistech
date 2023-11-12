import 'dart:convert';
import 'package:assistech/models/models.dart';
import 'package:assistech/models/shared_preferences_service.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;
  http.Client client;
  SharedPreferencesService _sharedPreferencesService = SharedPreferencesService();

  ApiService(this.baseUrl, this.client);

  Future<Map<String, dynamic>> login(String rut, String password) async {
  final response = await http.post(
    Uri.parse('$baseUrl/login'),
    body: jsonEncode({'rut': rut, 'password': password}),
    headers: {'Content-Type': 'application/json'},
  );

  print(response.body); // Para ver qué te devuelve la API


  if (response.statusCode == 200) {
    final responseData = jsonDecode(response.body);

    UserModel user = UserModel(
      id: responseData['user']['id'],
      rut: responseData['user']['rut'],
    );

    // No necesitas convertir 'role' a int ya que es una cadena (string)
    String roleName = responseData['role'];

    RoleModel role = RoleModel(
      nombre: roleName,
    );

    // Guardar en SharedPreferences
    final sharedPreferencesService = SharedPreferencesService();
    await sharedPreferencesService.setUserDetails(user, role);

    return responseData;
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

  Future<void> registrarAsistencia(int estudianteId, int claseProgramadaId) async {
  final response = await client.post(
    Uri.parse('http://192.168.100.81:3000/registrar-asistencia'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode({
      'estudiante_id': estudianteId,
      'clase_programada_id': claseProgramadaId,
    }),
  );

  if (response.statusCode != 200) {
    throw Exception('Error al registrar asistencia');
  }
}


Future<Map<String, dynamic>> registersala(String codigo, String nombre,
    double latitude, double longitude, double radius) async {
  final response = await http.post(
    Uri.parse('http://192.168.100.81:3000/register-sala'),
    body: jsonEncode({
      'codigo': codigo,
      'nombre': nombre,
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius
    }),
    headers: {'Content-Type': 'application/json'},
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Error al registrar sala');
  }
}

Future<Map<String, dynamic>> registermateria(String nombre) async {
  final url = Uri.parse('http://192.168.100.81:3000/register-materia');
  final headers = {'Content-Type': 'application/json'};
  final body = jsonEncode({'nombre': nombre});

  final response = await http.post(url, headers: headers, body: body);

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    print('Error: ${response.statusCode}');
    throw Exception('Error al registrar la materia');
  }
}


Future<int?> crearChequeo(int estudianteId, int claseProgramadaId) async {
  final response = await client.post(
    Uri.parse('http://192.168.100.81:3000/crear-chequeo'), // Usa tu dirección IP y puerto correctos
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode({
      'estudiante_id': estudianteId,
      'clase_programada_id': claseProgramadaId,
    }),
  );
  
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data['chequeoId'];
  } else {
    print('Error al crear el chequeo: ${response.statusCode}');
    return null;
  }
}

Future<void> actualizarChequeo(int chequeoId) async {
  final response = await client.put(
    Uri.parse('http://192.168.100.81:3000/actualizar-chequeo'), // Asegúrate de que esta es la ruta correcta para tu endpoint de actualizar chequeo
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode({
      'chequeo_id': chequeoId,
    }),
  );

  if (response.statusCode != 200) {
    throw Exception('Error al actualizar chequeo');
  }
}

Future<List<Asistencia>> filtrarAsistenciaPorFecha(String fecha) async {
    int profesorId = await _sharedPreferencesService.getProfesorId();
    final response = await client.get(
      Uri.parse('http://192.168.100.81:3000/filtrar-asistencia/fecha?fecha=$fecha&profesor_id=$profesorId'),
      headers: {'Content-Type': 'application/json'},
    );

  if (response.statusCode == 200) {
    List<dynamic> asistenciasJson = jsonDecode(response.body);
    return asistenciasJson.map((json) => Asistencia.fromJson(json)).toList();
  } else {
    throw Exception('Error al filtrar asistencias por fecha');
  }
}

 Future<List<Asistencia>> filtrarAsistenciaPorMateria(String nombreMateria) async {
    int profesorId = await _sharedPreferencesService.getProfesorId();
    final response = await client.get(
      Uri.parse('http://192.168.100.81:3000/filtrar-asistencia/materia?nombre_materia=$nombreMateria&profesor_id=$profesorId'),
      headers: {'Content-Type': 'application/json'},
    );

  if (response.statusCode == 200) {
    List<dynamic> asistenciasJson = jsonDecode(response.body);
    return asistenciasJson.map((json) => Asistencia.fromJson(json)).toList();
  } else {
    throw Exception('Error al filtrar asistencias por materia');
  }
}


Future<List<Asistencia>> filtrarAsistenciaPorSala(String codigoSala) async {
    int profesorId = await _sharedPreferencesService.getProfesorId();
    final response = await client.get(
      Uri.parse('http://192.168.100.81:3000/filtrar-asistencia/sala?codigo_sala=$codigoSala&profesor_id=$profesorId'),
      headers: {'Content-Type': 'application/json'},
    );

  if (response.statusCode == 200) {
    List<dynamic> asistenciasJson = jsonDecode(response.body);
    return asistenciasJson.map((json) => Asistencia.fromJson(json)).toList();
  } else {
    throw Exception('Error al filtrar asistencias por sala');
  }
}

Future<List<Asistencia>> filtrarAsistenciaCombinada({
  String? materia,
  String? fecha,
  String? sala,
}) async {
  int profesorId = await _sharedPreferencesService.getProfesorId();
  var queryParams = {
    if (materia != null && materia.isNotEmpty) 'materia': materia,
    if (fecha != null && fecha.isNotEmpty) 'fecha': fecha,
    if (sala != null && sala.isNotEmpty) 'sala': sala,
    'profesor_id': profesorId.toString(),
  };
  var uri = Uri.parse('http://192.168.100.81:3000/filtrar-asistencia').replace(queryParameters: queryParams);
  final response = await client.get(uri, headers: {'Content-Type': 'application/json'});

  if (response.statusCode == 200) {
    List<dynamic> responseData = jsonDecode(response.body);
    return responseData.map((data) => Asistencia.fromJson(data)).toList();
  } else {
    throw Exception('Error al filtrar asistencias: ${response.body}');
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

class Asistencia {
  final int id;
  final int estudianteId;
  final String nombreEstudiante;
  final DateTime fechaHora;
  final String nombreSala;
  final String nombreMateria;

  Asistencia({
    required this.id,
    required this.estudianteId,
    required this.nombreEstudiante,
    required this.fechaHora,
    required this.nombreSala,
    required this.nombreMateria,
  });

  factory Asistencia.fromJson(Map<String, dynamic> json) {
    return Asistencia(
      id: json['id'],
      estudianteId: json['estudiante_id'],
      nombreEstudiante: json['nombre_estudiante'],
      fechaHora: DateTime.parse(json['fecha_hora']),
      nombreSala: json['nombre_sala'],
      nombreMateria: json['nombre_materia'],
    );
  }
}
