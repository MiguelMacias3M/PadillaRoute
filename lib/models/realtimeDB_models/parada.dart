import 'package:json_annotation/json_annotation.dart';

part 'parada.g.dart';

@JsonSerializable()
class Parada {
  final int idParada;
  final String nombre;
  final DateTime horaLlegada;
  final DateTime horaSalida;
  final String coordenadas;

  Parada({
    required this.idParada,
    required this.nombre,
    required this.horaLlegada,
    required this.horaSalida,
    required this.coordenadas
  });

  factory Parada.fromJson(Map<String, dynamic> json) => _$ParadaFromJson(json);
  Map<String, dynamic> toJson() => _$ParadaToJson(this);
}