import 'package:padillaroutea/services/realtime_db_services/realtime_db_helper.dart';
import 'package:padillaroutea/models/realtimeDB_models/incidente_registro.dart';
import 'package:firebase_database/firebase_database.dart';
import 'db_collections.dart';

class IncidentesHelper {

  DatabaseReference database = RealtimeDbHelper.setCollection(DbCollections.test);

  IncidentesHelper();

  Future<void> setNewIncidente(IncidenteRegistro data) async {
    await RealtimeDbHelper.setNewEntry(database, data.toJson());

  }

  Future<IncidenteRegistro?> getOneIncidente(int id) async {
    final data = await RealtimeDbHelper.getEntryById(database, id);
    
    if(data != null) {
      return IncidenteRegistro.fromJson(data);
    }

    return null;

  }

  Future<void> updateIncidente(int id, IncidenteRegistro data) async {
    await RealtimeDbHelper.updateEntry(database, id, data.toJson());
  }

  Future<void> deleteIncidente(int id) async {
    await RealtimeDbHelper.deleteEntry(database, id);
  }
}
