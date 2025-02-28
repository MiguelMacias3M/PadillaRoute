import 'dart:convert';
import 'package:objectbox/objectbox.dart';

@Entity()
class ViajeRegistro {
  @Id()
  int id = 0;

  int idRuta;
  int idVehiculo;
  int idChofer;

  String paradasRegistro; // Store paradasRegistro as JSON

  String horaInicio;
  String horaFinal;

  int tiempoTotal;
  int totalPasajeros;

  double distanciaRecorrida;
  double velocidadPromedio;
  double combustibleConsumidoPromedio;

  bool finalizado;

  ViajeRegistro({
    this.id = 0,
    required this.idRuta,
    required this.idVehiculo,
    required this.idChofer,
    required this.paradasRegistro,
    required this.horaInicio,
    required this.horaFinal,
    required this.tiempoTotal,
    required this.totalPasajeros,
    required this.distanciaRecorrida,
    required this.velocidadPromedio,
    required this.combustibleConsumidoPromedio,
    required this.finalizado,
  });

  // Getter & Setter for paradasRegistro Map
  Map<String, dynamic> get paradasMap => jsonDecode(paradasRegistro);
  set paradasMap(Map<String, dynamic> map) => paradasRegistro = jsonEncode(map);

   /// Convert ObjectBox entity to a JSON-like Map
  Map<String, dynamic> toJson() {
    return {
      "id_registro": id,
      "id_ruta": idRuta,
      "id_vehiculo": idVehiculo,
      "id_usuario": idChofer,
      "paradas_registro": jsonDecode(paradasRegistro), // Decode stored JSON
      "hora_inicio": horaInicio,
      "tiempo_total": tiempoTotal,
      "total_personas": totalPasajeros,
      "distancia_recorrida": distanciaRecorrida,
      "velocidad_promedio": velocidadPromedio,
      "combustible_consumido_promedio": combustibleConsumidoPromedio
    };
  }
}
