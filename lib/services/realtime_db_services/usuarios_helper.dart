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
}
