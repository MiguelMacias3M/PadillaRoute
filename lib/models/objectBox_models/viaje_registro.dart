import 'dart:convert';

import 'package:objectbox/objectbox.dart';

@Entity()
class ViajeRegistro {
  @Id()
  int idRegistro = 0;
  int idRuta;
  int idVehiculo;
  int idUsuario;
  String paradasRegistro;
  DateTime horaInicio;
  DateTime hora;
  int tiempoTotal;
  int totalPasajeros;
  int distanciaRecorrida;
  int velocidadPromedio;
  int litrosCombustibleConsumidoAprox;

  ViajeRegistro({
    required this.idRegistro,
    required this.idRuta,
    required this.idVehiculo,
    required this.idUsuario,
    required this.paradasRegistro,
    required this.horaInicio,
    required this.hora,
    required this.tiempoTotal,
    required this.totalPasajeros,
    required this.distanciaRecorrida,
    required this.velocidadPromedio,
    required this.litrosCombustibleConsumidoAprox
  });

  Map<String, dynamic> get paradasMap => jsonDecode(paradasRegistro);
  set paradasMap(Map<String, dynamic> map) => paradasRegistro = jsonEncode(map);

}
