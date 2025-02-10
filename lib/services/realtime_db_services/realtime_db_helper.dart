import 'package:padillaroutea/services/connectors/realtime_db_connector.dart';
import 'package:firebase_database/firebase_database.dart';

class RealtimeDbHelper {
  static final FirebaseDatabase connection = RealtimedbConnector.getConnection();

  RealtimeDbHelper();

  static DatabaseReference setCollection(String collection) {
    return connection.ref().child(collection);
  }

  static Future<void> setNewEntry(DatabaseReference ref, Map<String, dynamic> data) async {
    return ref.push().set(data);
  } // WORKS

  static Future<Map<String, dynamic>?> getEntryById(DatabaseReference ref, String id) async {
    final snapshot = await ref.child(id).get();

    if (snapshot.exists) {
      return Map<String, dynamic>.from(snapshot.value as Map);
    }

    return null;
  } // WORKS; MODIFIACTIONS MUST BE DONE

  static Future<void> updateEntry(DatabaseReference ref, int id, Map<String, dynamic> data) async {
    return ref.child(id.toString()).update(data);
  } // WORKS; MODIFICATIONS MUST BE DONE (GET THE UID OF EVERY ENTRY)

  static Future<void> deleteEntry(DatabaseReference ref, String id) async {
    return ref.child(id).remove();
  } // FUNCIONA
}