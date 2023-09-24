class UserModel {
  final int id;
  final String rut;
  final int roleId;

  UserModel({required this.id, required this.rut, required this.roleId});
}

class RoleModel {
  final int id;
  final String nombre;

  RoleModel({required this.id, required this.nombre});
}
