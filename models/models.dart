class UserModel {
  final int id;
  final String username;
  final int roleId;

  UserModel({required this.id, required this.username, required this.roleId});
}

class RoleModel {
  final int id;
  final String nombre;

  RoleModel({required this.id, required this.nombre});
}
