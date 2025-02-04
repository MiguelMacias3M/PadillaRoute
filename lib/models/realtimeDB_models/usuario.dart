import 'package:json_annotation/json_annotation.dart';
part 'usuario.g.dart';

enum Rol { 
  @JsonValue('chofer')
  chofer, 
  @JsonValue('sacretaria')
  secretaria, 
  @JsonValue('gerente')
  gerente 
}

@JsonSerializable()
class Usuario {
  final int idUsuario;
  final String nombre;
  final String apellidos;
  final int telefono;
  final String correo;
  final String contrasena;
  final Rol rol;
  final bool activo;

  Usuario({
    required this.idUsuario,
    required this.nombre,
    required this.apellidos,
    required this.telefono,
    required this.correo,
    required this.contrasena,
    required this.rol,
    required this.activo
  });

  factory Usuario.fromJson(Map<String, dynamic> json) => _$UsuarioFromJson(json);
  Map<String, dynamic> toJson() => _$UsuarioToJson(this);
}