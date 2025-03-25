// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'viaje_registro.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ViajeRegistro _$ViajeRegistroFromJson(Map<String, dynamic> json) =>
    ViajeRegistro(
      idRegistro: (json['idRegistro'] as num).toInt(),
      idRuta: (json['idRuta'] as num).toInt(),
      idVehiculo: (json['idVehiculo'] as num).toInt(),
      idUsuario: (json['idUsuario'] as num).toInt(),
      paradasRegistro: json['paradasRegistro'] as Map<String, dynamic>,
      horaInicio: json['horaInicio'] as String,
      horaFinal: json['horaFinal'] as String,
      tiempoTotal: (json['tiempoTotal'] as num).toInt(),
      totalPasajeros: (json['totalPasajeros'] as num).toInt(),
      distanciaRecorrida: (json['distanciaRecorrida'] as num).toInt(),
      velocidadPromedio: (json['velocidadPromedio'] as num).toInt(),
      coordenadas: json['coordenadas'] as String,
    );

Map<String, dynamic> _$ViajeRegistroToJson(ViajeRegistro instance) =>
    <String, dynamic>{
      'idRegistro': instance.idRegistro,
      'idRuta': instance.idRuta,
      'idVehiculo': instance.idVehiculo,
      'idUsuario': instance.idUsuario,
      'paradasRegistro': instance.paradasRegistro,
      'horaInicio': instance.horaInicio,
      'horaFinal': instance.horaFinal,
      'tiempoTotal': instance.tiempoTotal,
      'totalPasajeros': instance.totalPasajeros,
      'distanciaRecorrida': instance.distanciaRecorrida,
      'velocidadPromedio': instance.velocidadPromedio,
      'coordenadas': instance.coordenadas,
    };
