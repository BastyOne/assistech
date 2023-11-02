import 'package:assistech/models/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  Future<void> setUserDetails(UserModel user, RoleModel role) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setInt('userId', user.id);
      await prefs.setString('rut', user.rut);
      await prefs.setString('roleName', role.nombre);

      print('User ID guardado: ${user.id}');
    } catch (e) {
      print(
          'Error al guardar los detalles del usuario en SharedPreferences: $e');
    }
  }

  Future<Map<String, dynamic>> getUserDetails() async {
    final prefs = await SharedPreferences.getInstance();

    int? userId = prefs.getInt('userId');
    String? rut = prefs.getString('rut');
    String? roleName = prefs.getString('roleName');

    print('User ID recuperado: $userId');

    return {
      'userId': userId,
      'rut': rut,
      'roleName': roleName,
    };
  }

  Future<void> clearUserDetails() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('userId');
    await prefs.remove('rut');
    await prefs.remove('roleName');

    print('Detalles del usuario eliminados de SharedPreferences');
  }

  Future<void> setGeoFenceDetails(
      double latitude, double longitude, double radius) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setDouble('geoFenceLatitude', latitude);
      await prefs.setDouble('geoFenceLongitude', longitude);
      await prefs.setDouble('geoFenceRadius', radius);

      print('Detalles de GeoFence guardados');
    } catch (e) {
      print(
          'Error al guardar los detalles de GeoFence en SharedPreferences: $e');
    }
  }

  Future<Map<String, dynamic>> getGeoFenceDetails() async {
    final prefs = await SharedPreferences.getInstance();

    double? latitude = prefs.getDouble('geoFenceLatitude');
    double? longitude = prefs.getDouble('geoFenceLongitude');
    double? radius = prefs.getDouble('geoFenceRadius');

    print('Detalles de GeoFence recuperados');

    return {
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
    };
  }

  Future<void> clearGeoFenceDetails() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('geoFenceLatitude');
    await prefs.remove('geoFenceLongitude');
    await prefs.remove('geoFenceRadius');

    print('Detalles de GeoFence eliminados de SharedPreferences');
  }
}
