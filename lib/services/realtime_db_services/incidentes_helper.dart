import 'package:padillaroutea/services/realtime_db_services/realtime_db_helper.dart';
import 'package:padillaroutea/models/realtimeDB_models/incidente_registro.dart';
import 'package:firebase_database/firebase_database.dart';
import 'db_collections.dart';

class IncidentesHelper {
  RealtimeDbHelper database;
  late DatabaseReference ref;

  IncidentesHelper(this.database) {
    ref = database.setCollection(DbCollections.incidentes);
  }

  Future<void> setNew(IncidenteRegistro incidente) async {
    await database.setNewEntry(ref, incidente.toJson());
  } // WORKS!!!

  Future<void> update(int id, Map<String, dynamic> data) async {
    final keyValue = await getKey(id, "idRegistro");
    if (keyValue != null) {
      await database.updateEntry(ref, keyValue, data);
    } else {
      throw Exception("No entry found with the id: $id");
    }
  } // WORKS!!!

  Future<void> delete(int id) async {
    final keyValue = await getKey(id, "idRegistro");
    if (keyValue != null) {
      await database.deleteEntry(ref, keyValue);
    } else {
      throw Exception("No entry found with the id: $id");
    }
  } // WORKS!!!

  Future<IncidenteRegistro?> get(int id) async {
    final keyValue = await getKey(id, "idRegistro");
    if (keyValue != null) {
      final data = await database.getEntryById(ref, keyValue);
      return IncidenteRegistro.fromJson(data);
    } else {
      return null;
    }
  } // WORKS!!!

  Future<List<IncidenteRegistro>> getAll() async {
    final data = await database.getAllEntries(ref);
    if (data.isNotEmpty) {
      return data
          .map((e) => IncidenteRegistro.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } else {
      return [];
    }
  }

  Future<List<IncidenteRegistro>> fetchByMonth(int year, int month) async {
    final data = await database.fetchEntriesByMonth(ref, year, month);
    if (data.isNotEmpty) {
      return data
          .map((e) => IncidenteRegistro.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } else {
      return [];
    }
  }

  Future<List<IncidenteRegistro>> fetchByDate(DateTime date) async {
    final data = await database.fetchEntriesByDate(ref, date);
    if (data.isNotEmpty) {
      return data
          .map((e) => IncidenteRegistro.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } else {
      return [];
    }
  }

  Future<List<IncidenteRegistro>> fetchByDateRange(DateTime startDate, DateTime endDate) async {
    final data = await database.fetchEntriesByDateRange(ref, startDate, endDate);
    if (data.isNotEmpty) {
      return data
          .map((e) => IncidenteRegistro.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } else {
      return [];
    }
  }

  Future<String?> getKey(int id, String field) async {
    return database.getKeyByField(ref, field, id);
  } // WORKS!!!
}
