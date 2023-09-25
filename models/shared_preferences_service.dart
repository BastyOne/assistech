import 'package:assistech/models/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  
  Future<void> setUserDetails(UserModel user, RoleModel role) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Guardar detalles del usuario y role en SharedPreferences
      await prefs.setInt('userId', user.id);
      await prefs.setString('rut', user.rut);
      await prefs.setInt('roleId', user.roleId);
      await prefs.setString('roleName', role.nombre);
      
      print('User ID guardado: ${user.id}');
      print('Role ID guardado: ${role.id}');
      
    } catch (e) {
      print('Error al guardar los detalles del usuario en SharedPreferences: $e');
    }
  }

  Future<Map<String, dynamic>> getUserDetails() async {
    final prefs = await SharedPreferences.getInstance();

    int? userId = prefs.getInt('userId');
    String? rut = prefs.getString('rut');
    int? roleId = prefs.getInt('roleId');
    String? roleName = prefs.getString('roleName');

    print('User ID recuperado: $userId');
    print('Role ID recuperado: $roleId');

    return {
      'userId': userId,
      'rut': rut,
      'roleId': roleId,
      'roleName': roleName,
    };
  }

  Future<void> clearUserDetails() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('userId');
    await prefs.remove('rut');
    await prefs.remove('roleId');
    await prefs.remove('roleName');
    
    print('Detalles del usuario eliminados de SharedPreferences');
  }
}
