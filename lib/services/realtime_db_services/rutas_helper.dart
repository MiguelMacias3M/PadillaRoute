import 'package:padillaroutea/services/realtime_db_services/realtime_db_helper.dart';
import 'package:padillaroutea/models/realtimeDB_models/ruta.dart';
import 'package:firebase_database/firebase_database.dart';
import 'db_collections.dart';

class RutasHelper {
  RealtimeDbHelper database;
  late DatabaseReference ref;

  RutasHelper(this.database) {
    ref = database.setCollection(DbCollections.rutas);
  }

  Future<void> setNew(Ruta ruta) async {
    await database.setNewEntry(ref, ruta.toJson());
  } // WORKS!!!

  Future<void> update(int id, Map<String, dynamic> data) async {
    final keyValue = await getKey(id, "idRuta");
    if (keyValue != null) {
      await database.updateEntry(ref, keyValue, data);
    } else {
      throw Exception("No entry found with the id: $id");
    }
  } // WORKS!!!

  Future<void> delete(int id) async {
    final keyValue = await getKey(id, "idRuta");
    if (keyValue != null) {
      await database.deleteEntry(ref, keyValue);
    } else {
      throw Exception("No entry found with the id: $id");
    }
  }

  Future<Ruta?> get(int id) async {
    final keyValue = await getKey(id, "idRuta");
    if (keyValue != null) {
      final data = await database.getEntryById(ref, keyValue);
      return Ruta.fromJson(data);
    } else {
      throw Exception("No entry found with the id: $id");
    }
  }

  Future<List<Ruta>> getAll() async {
    final data = await database.getAllEntries(ref);

    // Imprimir los datos recibidos en la consola
    print('Datos recibidos desde la base de datos: $data');

    if (data.isNotEmpty) {
      return data.map((e) {
        // Verifica la estructura de cada elemento
        // print('Elemento de datos: $e');
        return Ruta.fromJson(Map<String, dynamic>.from(e));
      }).toList();
    } else {
      return [];
    }
  }

  Future<String?> getKey(int id, String field) async {
    return database.getKeyByField(ref, field, id);
  }
}