import 'package:padillaroutea/services/realtime_db_services/realtime_db_helper.dart';
import 'package:padillaroutea/models/realtimeDB_models/usuario.dart';
import 'package:firebase_database/firebase_database.dart';
import 'db_collections.dart';

class UsuariosHelper {
  RealtimeDbHelper database;
  late DatabaseReference ref;

  UsuariosHelper(this.database) {
    ref = database.setCollection(DbCollections.usuarios);
  }

  Future<void> setNew(Usuario usuario) async {
    await database.setNewEntry(ref, usuario.toJson());
  }

  Future<void> update(int id, Map<String, dynamic> data) async {
    final keyValue = await getKey(id, "idUsuario");
    if (keyValue != null) {
      await database.updateEntry(ref, keyValue, data);
    } else {
      throw Exception("No entry found with the id: $id");
    }
  }

  Future<void> delete(int id) async {
    final keyValue = await getKey(id, "idUsuario");
    if(keyValue != null) {
      await database.deleteEntry(ref, keyValue);
    } else {
      throw Exception("No entry found with the id: $id");
    }
  }

  Future<Usuario?> get(int id) async {
    final keyValue = await getKey(id, "idUsuario");
    if(keyValue != null) {
      final data = await database.getEntryById(ref, keyValue);
      return Usuario.fromJson(data);
    } else {
      return null;
    }
  }

    Future<Usuario?> getByEmail(String id) async {
    final keyValue = await getKey(id, "correo");
    if(keyValue != null) {
      final data = await database.getEntryById(ref, keyValue);
      return Usuario.fromJson(data);
    } else {
      return null;
    }
  }

  Future<List<Usuario>> getAll() async {
  final data = await database.getAllEntries(ref);

  // Imprimir los datos recibidos en la consola
  print('Datos recibidos desde la base de datos: $data');

  if (data.isNotEmpty) {
    return data.map((e) {
      // Verifica la estructura de cada elemento
      print('Elemento de datos: $e');
      return Usuario.fromJson(Map<String, dynamic>.from(e));
    }).toList();
  } else {
    return [];
  }
}

  Future<String?> getKey(dynamic id, String field) async {
    return database.getKeyByField(ref, field, id);
  }
}
