import 'package:json_annotation/json_annotation.dart';
part 'usuario.g.dart';

enum Rol { 
  @JsonValue('chofer')
  chofer, 
  @JsonValue('administrativo')
  administrativo, 
  @JsonValue('gerente')
  gerente 
}
@JsonSerializable()
class Usuario {
  final int idUsuario;
  final String nombre;
  final String apellidos;
  final int? telefono;  // Cambiar a int? para aceptar null
  final String correo;
  final String contrasena;
  final Rol rol;
  final bool activo;
  final int? idVehiculo;  // Cambiar a int? para aceptar null
  final String? fcmToken;

  Usuario({
    required this.idUsuario,
    required this.nombre,
    required this.apellidos,
    this.telefono,  // Esto puede ser null ahora
    required this.correo,
    required this.contrasena,
    required this.rol,
    required this.activo,
    this.idVehiculo,  // Esto puede ser null ahora
    this.fcmToken,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) => _$UsuarioFromJson(json);
  Map<String, dynamic> toJson() => _$UsuarioToJson(this);
}
