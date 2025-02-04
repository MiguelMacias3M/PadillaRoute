// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ruta.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Ruta _$RutaFromJson(Map<String, dynamic> json) => Ruta(
      idRuta: (json['idRuta'] as num).toInt(),
      idChofer: (json['idChofer'] as num).toInt(),
      nombre: json['nombre'] as String,
      origen: json['origen'] as String,
      destino: json['destino'] as String,
      paradas:
          (json['paradas'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$RutaToJson(Ruta instance) => <String, dynamic>{
      'idRuta': instance.idRuta,
      'idChofer': instance.idChofer,
      'nombre': instance.nombre,
      'origen': instance.origen,
      'destino': instance.destino,
      'paradas': instance.paradas,
    };
