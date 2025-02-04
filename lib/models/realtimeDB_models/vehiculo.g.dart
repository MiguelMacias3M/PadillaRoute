// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehiculo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Vehiculo _$VehiculoFromJson(Map<String, dynamic> json) => Vehiculo(
      idVehiculo: (json['idVehiculo'] as num).toInt(),
      placa: json['placa'] as String,
      marca: json['marca'] as String,
      modelo: json['modelo'] as String,
      capacidad: (json['capacidad'] as num).toInt(),
      numeroSerie: (json['numeroSerie'] as num).toInt(),
      estatus: $enumDecode(_$EstatusEnumMap, json['estatus']),
    );

Map<String, dynamic> _$VehiculoToJson(Vehiculo instance) => <String, dynamic>{
      'idVehiculo': instance.idVehiculo,
      'placa': instance.placa,
      'marca': instance.marca,
      'modelo': instance.modelo,
      'capacidad': instance.capacidad,
      'numeroSerie': instance.numeroSerie,
      'estatus': _$EstatusEnumMap[instance.estatus]!,
    };

const _$EstatusEnumMap = {
  Estatus.activo: 'activo',
  Estatus.inactivo: 'inactivo',
  Estatus.mantenimiento: 'mantenimiento',
};
