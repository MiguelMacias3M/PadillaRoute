import 'package:padillaroutea/services/objectbox_services/viajes_registro_helper.dart';
import 'package:padillaroutea/services/realtime_db_services/viajes_helper.dart';
import 'package:padillaroutea/models/realtimeDB_models/viaje_registro.dart'
    as viajeRegistroRealTime;
import 'package:padillaroutea/models/objectBox_models/viaje_registro.dart';
import 'dart:async';

class DataSync {
  final ViajesHelper realTimeViajesHelper;
  final ViajesRegistroHelper objectBox;
  Timer? _timer;

  DataSync(this.objectBox, this.realTimeViajesHelper);

  void startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 300000), (timer) {
      if (checkForPendingSyncronization()) {
        syncDat("111133, 131133");
      }
    });
  }

  void stopTimer() {
    _timer?.cancel();
  }
  bool checkForPendingSyncronization() {
    final List<ViajeRegistro> registros = objectBox.getAllRegistros();
    return registros.isNotEmpty;
  }

  void syncDat(String coordenadas) {
    final List<ViajeRegistro> registros = objectBox.getAllRegistros();
    final objItem = registros[0];

    final castedItem = viajeRegistroRealTime.ViajeRegistro(
        idRegistro: objItem.id,
        idRuta: objItem.idRuta,
        idVehiculo: objItem.idVehiculo,
        idUsuario: objItem.idChofer,
        paradasRegistro: objItem.paradasMap,
        horaInicio: objItem.horaInicio,
        horaFinal: objItem.horaFinal,
        tiempoTotal: objItem.tiempoTotal,
        totalPasajeros: objItem.totalPasajeros,
        distanciaRecorrida: objItem.distanciaRecorrida.toInt(),
        velocidadPromedio: objItem.velocidadPromedio.toInt(),
        coordenadas: coordenadas);

    realTimeViajesHelper.setNew(castedItem).then((value) {
      objectBox.deleteRegistro();
    });
  }
}
