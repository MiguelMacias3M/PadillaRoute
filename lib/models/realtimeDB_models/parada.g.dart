// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parada.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Parada _$ParadaFromJson(Map<String, dynamic> json) => Parada(
      idParada: (json['idParada'] as num).toInt(),
      nombre: json['nombre'] as String,
      horaLlegada: json['horaLlegada'] as String,
      horaSalida: json['horaSalida'] as String,
      coordenadas: json['coordenadas'] as String,
    );

Map<String, dynamic> _$ParadaToJson(Parada instance) => <String, dynamic>{
      'idParada': instance.idParada,
      'nombre': instance.nombre,
      'horaLlegada': instance.horaLlegada,
      'horaSalida': instance.horaSalida,
      'coordenadas': instance.coordenadas,
    };
