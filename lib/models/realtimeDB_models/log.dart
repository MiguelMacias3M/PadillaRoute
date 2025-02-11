import 'package:json_annotation/json_annotation.dart';

part 'log.g.dart';

enum Tipo { 
  @JsonValue('alta')
  alta, 
  @JsonValue('baja')
  baja, 
  @JsonValue('modificacion')
  modifiacion, 
}

@JsonSerializable()
class Log {
  final int idLog;
  final Tipo tipo;
  final String usuario;
  final String accion;
  final String fecha;

  Log({
    required this.idLog,
    required this.tipo,
    required this.usuario,
    required this.accion,
    required this.fecha
  });

  factory Log.fromJson(Map<String, dynamic> json) => _$LogFromJson(json);
  Map<String, dynamic> toJson() => _$LogToJson(this);
}