// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usuario.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Usuario _$UsuarioFromJson(Map<String, dynamic> json) => Usuario(
      idUsuario: (json['idUsuario'] as num).toInt(),
      nombre: json['nombre'] as String,
      apellidos: json['apellidos'] as String,
      telefono: (json['telefono'] as num).toInt(),
      correo: json['correo'] as String,
      contrasena: json['contrasena'] as String,
      rol: $enumDecode(_$RolEnumMap, json['rol']),
      activo: json['activo'] as bool,
    );

Map<String, dynamic> _$UsuarioToJson(Usuario instance) => <String, dynamic>{
      'idUsuario': instance.idUsuario,
      'nombre': instance.nombre,
      'apellidos': instance.apellidos,
      'telefono': instance.telefono,
      'correo': instance.correo,
      'contrasena': instance.contrasena,
      'rol': _$RolEnumMap[instance.rol]!,
      'activo': instance.activo,
    };

const _$RolEnumMap = {
  Rol.chofer: 'chofer',
  Rol.administrativo: 'administrativo',
  Rol.gerente: 'gerente',
};
