import 'package:padillaroutea/services/realtime_db_services/realtime_db_helper.dart';
import 'package:padillaroutea/models/realtimeDB_models/incidente_registro.dart';
import 'package:firebase_database/firebase_database.dart';
import 'db_collections.dart';

/// This class contains the necessary methods to interact with the Incidentes collection.
class IncidentesHelper {
  RealtimeDbHelper database;
  late DatabaseReference ref;

  IncidentesHelper(this.database) {
    ref = database.setCollection(DbCollections.incidentes);
  }

  /// Creates a new entry in the collection.
  ///
  /// [incidente] is the record to be set in the collection
  Future<void> setNew(IncidenteRegistro incidente) async {
    await database.setNewEntry(ref, incidente.toJson());
  } // WORKS!!!

  /// Updates an entry in the collection.
  ///
  /// [id] is the ID of the incident record to be updated.
  /// [data] is a map containing the fields to be updated.
  Future<void> update(int id, Map<String, dynamic> data) async {
    final keyValue = await getKey(id, "idRegistro");
    if (keyValue != null) {
      await database.updateEntry(ref, keyValue, data);
    } else {
      throw Exception("No entry found with the id: $id");
    }
  } // WORKS!!!

  /// Removes an entry from the collection.
  ///
  /// [id] is the ID of the incident record to be removed.
  Future<void> delete(int id) async {
    final keyValue = await getKey(id, "idRegistro");
    if (keyValue != null) {
      await database.deleteEntry(ref, keyValue);
    } else {
      throw Exception("No entry found with the id: $id");
    }
  } // WORKS!!!

  /// Retrieves an incident record by its ID.
  ///
  /// [id] is the ID of the incident record to be retrieved.
  /// Returns an [IncidenteRegistro] object if found, otherwise returns null.
  Future<IncidenteRegistro?> get(int id) async {
    final keyValue = await getKey(id, "idRegistro");
    if (keyValue != null) {
      final data = await database.getEntryById(ref, keyValue);
      return IncidenteRegistro.fromJson(data);
    } else {
      return null;
    }
  } // WORKS!!!

  /// Retrieves all incident records.
  ///
  /// Returns a list of [IncidenteRegistro] objects.
  Future<List> getAll() async {
    final data = await database.getAllEntries(ref);
    if (data.isNotEmpty) {
      return data.map((e) => IncidenteRegistro.fromJson(e)).toList();
    } else {
      return [];
    }
  }

  /// Retrieves the key of an incident record by a specific field.
  ///
  /// [id] is the ID of the incident record.
  /// [field] is the field to be used for the lookup.
  /// Returns the key as a string if found, otherwise returns null.
  Future<String?> getKey(int id, String field) async {
    return database.getKeyByField(ref, field, id);
  } // WORKS!!!
}
