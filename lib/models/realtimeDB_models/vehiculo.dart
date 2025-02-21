import 'package:json_annotation/json_annotation.dart';

part 'vehiculo.g.dart';

enum Estatus {
  @JsonValue('activo')
  activo,
  @JsonValue('inactivo')
  inactivo,
  @JsonValue('mantenimiento')
  mantenimiento,
}

@JsonSerializable()
class Vehiculo {
  final int idVehiculo;
  final String placa;
  final String marca;
  final String modelo;
  final int capacidad;
  final int numeroSerie;
  final Estatus estatus;

  Vehiculo({
    required this.idVehiculo,
    required this.placa,
    required this.marca,
    required this.modelo,
    required this.capacidad,
    required this.numeroSerie,
    required this.estatus,
  });

  factory Vehiculo.fromJson(Map<String, dynamic> json) =>
      _$VehiculoFromJson(json);
  Map<String, dynamic> toJson() => _$VehiculoToJson(this);
}
