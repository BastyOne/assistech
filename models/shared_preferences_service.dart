import 'package:assistech/models/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  Future<void> setUserDetails(UserModel user, RoleModel role) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('userId', user.id);
    prefs.setString('rut', user.rut);
    prefs.setInt('roleId', user.roleId);
    prefs.setString('roleName', role.nombre);
  }

  Future<Map<String, dynamic>> getUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('userId');
    String? rut = prefs.getString('rut');
    int? roleId = prefs.getInt('roleId');
    String? roleName = prefs.getString('roleName');

    return {
      'userId': userId,
      'rut': rut,
      'roleId': roleId,
      'roleName': roleName,
    };
  }

  Future<void> clearUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('userId');
    prefs.remove('rut');
    prefs.remove('roleId');
    prefs.remove('roleName');
  }
}
