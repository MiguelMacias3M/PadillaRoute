// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'incidente_registro.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IncidenteRegistro _$IncidenteRegistroFromJson(Map<String, dynamic> json) =>
    IncidenteRegistro(
      idRegistro: (json['idRegistro'] as num).toInt(),
      idUsuario: (json['idUsuario'] as num).toInt(),
      idVehiculo: (json['idVehiculo'] as num).toInt(),
      descripcion: json['descripcion'] as String,
      fecha: DateTime.parse(json['fecha'] as String),
    );

Map<String, dynamic> _$IncidenteRegistroToJson(IncidenteRegistro instance) =>
    <String, dynamic>{
      'idRegistro': instance.idRegistro,
      'idUsuario': instance.idUsuario,
      'idVehiculo': instance.idVehiculo,
      'descripcion': instance.descripcion,
      'fecha': instance.fecha.toIso8601String(),
    };
