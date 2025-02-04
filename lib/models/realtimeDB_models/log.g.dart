// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Log _$LogFromJson(Map<String, dynamic> json) => Log(
      idLog: (json['idLog'] as num).toInt(),
      tipo: $enumDecode(_$TipoEnumMap, json['tipo']),
      usuario: json['usuario'] as String,
      accion: json['accion'] as String,
      fecha: DateTime.parse(json['fecha'] as String),
    );

Map<String, dynamic> _$LogToJson(Log instance) => <String, dynamic>{
      'idLog': instance.idLog,
      'tipo': _$TipoEnumMap[instance.tipo]!,
      'usuario': instance.usuario,
      'accion': instance.accion,
      'fecha': instance.fecha.toIso8601String(),
    };

const _$TipoEnumMap = {
  Tipo.alta: 'alta',
  Tipo.baja: 'baja',
  Tipo.modifiacion: 'modificacion',
};
