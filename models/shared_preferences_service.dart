import 'package:assistech/models/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  Future<void> setUserDetails(UserModel user, RoleModel role) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('userId', user.id);
    prefs.setString('username', user.username);
    prefs.setInt('roleId', user.roleId);
    prefs.setString('roleName', role.nombre);
  }

  Future<Map<String, dynamic>> getUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('userId');
    String? username = prefs.getString('username');
    int? roleId = prefs.getInt('roleId');
    String? roleName = prefs.getString('roleName');

    return {
      'userId': userId,
      'username': username,
      'roleId': roleId,
      'roleName': roleName,
    };
  }

  Future<void> clearUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('userId');
    prefs.remove('username');
    prefs.remove('roleId');
    prefs.remove('roleName');
  }
}
