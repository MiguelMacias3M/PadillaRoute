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
    print("Clave encontrada para actualización: $keyValue");
    if (keyValue != null) {
      await database.updateEntry(ref, keyValue, data);
    } else {
      throw Exception("No entry found with the id: $id");
    }
  }

  Future<void> delete(int id) async {
    final keyValue = await getKey(id, "idUsuario");
    if (keyValue != null) {
      await database.deleteEntry(ref, keyValue);
    } else {
      throw Exception("No entry found with the id: $id");
    }
  }

  Future<Usuario?> get(int id) async {
    final keyValue = await getKey(id, "idUsuario");
    if (keyValue != null) {
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
        // print('Elemento de datos: $e');
        return Usuario.fromJson(Map<String, dynamic>.from(e));
      }).toList();
    } else {
      return [];
    }
  }

  Future<String?> getUserFCMToken(int idUsuario) async {
  try {
    final keyValue = await getKey(idUsuario, "idUsuario");
    if (keyValue != null) {
      final data = await database.getEntryById(ref, keyValue);
      print("1- Datos obtenidos del usuario desde el servicio: $data");

      print("2- FCM Token desde el servicio: ${data['fcmToken']}");
       return data['fcmToken'];  // Devuelve el token FCM
    } else {
      return null;  // No se encontró el usuario
    }
  } catch (e) {
    print("3- Error al obtener el FCM Token: $e. desde el servicio");
    return null;  // En caso de error
  }
}


// Actualizar el token FCM en la base de datos
  Future<void> updateFCMToken(int userId, String token) async {
    try {
      final keyValue = await getKey(userId, "idUsuario");
      if (keyValue != null) {
        await database.updateEntry(ref, keyValue, {'fcmToken': token});
        print("4- Token FCM actualizado correctamente.");
      } else {
        print("5- Usuario no encontrado para actualizar el token.");
      }
    } catch (e) {
      print("6- Error al actualizar el token FCM: $e");
    }
  }

  Future<String?> getKey(dynamic id, String field) async {
    return database.getKeyByField(ref, field, id);
  }
}
