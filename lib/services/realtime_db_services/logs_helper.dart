import 'package:padillaroutea/services/realtime_db_services/realtime_db_helper.dart';
import 'package:padillaroutea/models/realtimeDB_models/log.dart';
import 'package:firebase_database/firebase_database.dart';
import 'db_collections.dart';

class LogsHelper {
  DatabaseReference database = RealtimeDbHelper.setCollection(DbCollections.logs);

  LogsHelper();

  Future<void> setNewLog(Log data) async {
    await RealtimeDbHelper.setNewEntry(database, data.toJson());
  }

  Future<Log?> getOneLog(int id) async {
    final data = await RealtimeDbHelper.getEntryById(database, id);

    if (data != null) {
      return Log.fromJson(data);
    }

    return null;
  }

  Future<void> updateLog(int id, Log data) async {
    
  }
}
