import 'package:json_annotation/json_annotation.dart';

part 'incidente_registro.g.dart';

@JsonSerializable()
class IncidenteRegistro {
  final int idRegistro;
  final int idUsuario;
  final int idVehiculo;
  final String descripcion;
  final String fecha;

  IncidenteRegistro({
    required this.idRegistro,
    required this.idUsuario,
    required this.idVehiculo,
    required this.descripcion,
    required this.fecha
  });

  factory IncidenteRegistro.fromJson(Map<String, dynamic> json) => _$IncidenteRegistroFromJson(json);
  Map<String, dynamic> toJson() => _$IncidenteRegistroToJson(this);
}