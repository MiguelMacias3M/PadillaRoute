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
  }

  static Future<Map<String, dynamic>?> getEntryById(DatabaseReference ref, int id) async {
    final snapshot = await ref.child(id.toString()).get();

    if (snapshot.exists) {
      return Map<String, dynamic>.from(snapshot.value as Map);
    }

    return null;
  }

  static Future<void> updateEntry(DatabaseReference ref, int id, Map<String, dynamic> data) async {
    return ref.child(id.toString()).update(data);
  }

  static Future<void> deleteEntry(DatabaseReference ref, int id) async {
    return ref.child(id.toString()).remove();
  }
}