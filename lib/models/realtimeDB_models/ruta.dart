import 'package:json_annotation/json_annotation.dart';

part 'ruta.g.dart';

@JsonSerializable()
class Ruta {
  final int idRuta;
  final int idChofer;
  final String nombre;
  final String origen;
  final String destino;
  final List<String> paradas;    

  Ruta({
    required this.idRuta,
    required this.idChofer,
    required this.nombre,
    required this.origen,
    required this.destino,
    required this.paradas
  });

  factory Ruta.fromJson(Map<String, dynamic> json) => _$RutaFromJson(json);
  Map<String, dynamic> toJson() => _$RutaToJson(this);
}