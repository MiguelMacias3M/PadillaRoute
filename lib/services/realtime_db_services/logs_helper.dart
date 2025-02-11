import 'package:padillaroutea/services/realtime_db_services/realtime_db_helper.dart';
import 'package:padillaroutea/models/realtimeDB_models/log.dart';
import 'package:firebase_database/firebase_database.dart';
import 'db_collections.dart';

class LogsHelper {
  RealtimeDbHelper database;
  late DatabaseReference ref;

  LogsHelper(this.database) {
    ref = database.setCollection(DbCollections.logs);
  }

  Future<void> setNew(Log data) async {
    await database.setNewEntry(ref, data.toJson());
  }

  Future<void> update(int id, Map<String, dynamic> data) async {
    final keyValue = await getKey(id, "idLog");
    if (keyValue != null) {
      await database.updateEntry(ref, keyValue, data);
    } else {
      throw Exception("No entry found with the id: $id");
    }
  }

  Future<void> delete(int id) async {
    final keyValue = await getKey(id, "idLog");
    if(keyValue != null) {
      await database.deleteEntry(ref, keyValue);
    } else {
      throw Exception("No entry found with the id: $id");
    }
  }

  Future<Log?> get(int id) async {
    final keyValue = await getKey(id, "idLog");
    if(keyValue != null) {
      final data = await database.getEntryById(ref, keyValue);
      return Log.fromJson(data);
    } else {
      return null;
    }
  }

  Future<String?> getKey(int id, String field) async {
    return database.getKeyByField(ref, field, id);
  }
}
