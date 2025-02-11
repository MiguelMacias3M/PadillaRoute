import '../realtime_db_services/incidentes_helper.dart';
import 'package:padillaroutea/models/realtimeDB_models/incidente_registro.dart';

void main() {
  IncidentesHelper helper = IncidentesHelper();
  IncidenteRegistro registro = IncidenteRegistro(
    idRegistro: 1,
    idUsuario: 1,
    idVehiculo: 1,
    descripcion: "Retraso debido a carretera en reparación",
    fecha: DateTime.now()
  );

  try {
      helper.setNewIncidente(registro);
      print("success");
  } catch (e) {
    print("error: $e");
  }
}
