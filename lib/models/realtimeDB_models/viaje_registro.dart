import 'package:json_annotation/json_annotation.dart';

part 'viaje_registro.g.dart';
@JsonSerializable()
class ViajeRegistro {
  final int idRegistro;
  final int idRuta;
  final int idVehiculo;
  final int idUsuario;
  final Map<String, dynamic> paradasRegistro;
  final DateTime horaInicio;
  final DateTime horaFinal;
  final int tiempoTotal;
  final int totalPasajeros;
  final int distanciaRecorrida;
  final int velocidadPromedio;
  final int litrosCombustibleConsumidoAprox;

  ViajeRegistro({
    required this.idRegistro,
    required this.idRuta,
    required this.idVehiculo,
    required this.idUsuario,
    required this.paradasRegistro,
    required this.horaInicio,
    required this.horaFinal,
    required this.tiempoTotal,
    required this.totalPasajeros,
    required this.distanciaRecorrida,
    required this.velocidadPromedio,
    required this.litrosCombustibleConsumidoAprox
  });

  factory ViajeRegistro.fromJson(Map<String, dynamic> json) => _$ViajeRegistroFromJson(json);
  Map<String, dynamic> toJson() => _$ViajeRegistroToJson(this);
}
