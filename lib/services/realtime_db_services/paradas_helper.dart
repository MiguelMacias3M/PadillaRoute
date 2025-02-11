import 'package:padillaroutea/services/realtime_db_services/realtime_db_helper.dart';
import 'package:padillaroutea/models/realtimeDB_models/parada.dart';
import 'package:firebase_database/firebase_database.dart';
import 'db_collections.dart';

class ParadasHelper {
  RealtimeDbHelper database;
  late DatabaseReference ref;

  ParadasHelper(this.database) {
    ref = database.setCollection(DbCollections.paradas);
  }

  Future<void> setNew(Parada parada) async {
    await database.setNewEntry(ref, parada.toJson());
  } // WORKS!!!

  Future<void> update(int id, Map<String, dynamic> data) async {
    final keyValue = await getKey(id, "idParada");
    if (keyValue != null) {
      await database.updateEntry(ref, keyValue, data);
    } else {
      throw Exception("No entry found with the id: $id");
    }
  } // WORKS!!!

  Future<void> delete(int id) async {
    final keyValue = await getKey(id, "idParada");  
    if(keyValue != null) {
      await database.deleteEntry(ref, keyValue);
    } else {
      throw Exception("No entry found with the id: $id");
    }
  }

  Future<Parada?> get(int id) async {
    final keyValue = await getKey(id, "idParada");
    if(keyValue != null) {
      final data = await database.getEntryById(ref, keyValue);
      return Parada.fromJson(data);
    } else {
      return null;
    }
  }

  Future<String?> getKey(int id, String field) async {
    return database.getKeyByField(ref, field, id);
  }
}