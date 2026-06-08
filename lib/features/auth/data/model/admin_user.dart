import 'package:equatable/equatable.dart';

class AdminUser extends Equatable {
  final String id;
  final String email;
  final String name;
  final bool isAdmin;

  const AdminUser({required this.id, required this.email, required this.name, required this.isAdmin});

  factory AdminUser.fromJson(Map<String, dynamic> j) => AdminUser(
        id: j['id'] as String,
        email: j['email'] as String? ?? '',
        name: j['name'] as String? ?? '',
        isAdmin: j['is_admin'] as bool? ?? false,
      );

  @override
  List<Object?> get props => [id, email, name, isAdmin];
}
