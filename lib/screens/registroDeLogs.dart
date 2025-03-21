import 'package:padillaroutea/models/realtimeDB_models/log.dart';
import 'package:padillaroutea/services/realtime_db_services/logs_helper.dart';
import 'package:logger/logger.dart';

Future<void> logAction(
  String correo,
  Tipo tipo,
  String accion,
  LogsHelper logsHelper,
  Logger logger,
) async {
  final logEntry = Log(
    idLog: DateTime.now().millisecondsSinceEpoch,
    tipo: tipo,
    usuario: correo,
    accion: accion,
    fecha: DateTime.now().toIso8601String(),
  );

  try {
    await logsHelper.setNew(logEntry);
    logger.i("Log registrado: $accion");
  } catch (e) {
    logger.e("Error al registrar log: $e");
  }
}
