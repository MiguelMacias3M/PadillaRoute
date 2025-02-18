import 'package:padillaroutea/services/connectors/realtime_db_connector.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:logger/logger.dart';

class RealtimeDbHelper {
  static final FirebaseDatabase connection = RealtimedbConnector.getConnection();

  final Logger _logger = Logger();

  RealtimeDbHelper();

  DatabaseReference setCollection(String collection) {
    return connection.ref().child(collection);
  }

  Future<void> setNewEntry(
      DatabaseReference ref, Map<String, dynamic> data) async {
    try {
      await ref.push().set(data);
    } catch (e) {
      _logger.e("ERROR: $e");
    }
  } // WORKS

  Future<Map<String, dynamic>> getEntryById(DatabaseReference ref, String id) async {
    try {
      final snapshot = await ref.child(id).get();

      if (snapshot.exists) {
        return Map<String, dynamic>.from(snapshot.value as Map);
      } else {
        throw Exception("No entry found");
      }
      
    } catch (e) {
      _logger.e("ERROR: $e");
      throw Exception("Failed to get entry");
    }
  } // WORKS; MODIFIACTIONS MUST BE DONE

  Future<void> updateEntry(DatabaseReference ref, String id, Map<String, dynamic> data) async {
    try {
      
      await ref.child(id.toString()).update(data);
    } catch (e) {
      _logger.e("ERROR: $e");
      
    }
  } // WORKS; MODIFICATIONS MUST BE DONE (GET THE UID OF EVERY ENTRY)

  Future<void> deleteEntry(DatabaseReference ref, String id) async {
    try {
      await ref.child(id).remove();
    } catch (e) {
      _logger.e("ERROR: $e");
    }
  } // FUNCIONA

  Future<String?> getKeyByField(DatabaseReference ref, String field, dynamic value) async {
    try {
      final snapshot = await ref.orderByChild(field).equalTo(value).limitToFirst(1).get();

      if (snapshot.exists) {
        final data = snapshot.value as Map;
        return data.keys.first;
      }
      return null;

    } catch (e) {
      _logger.e("ERROR: $e");
    }
    return null;

  }

  Future<List> getAllEntries(DatabaseReference ref) async {
    try {
      final snapshot = await ref.get();

      if (snapshot.exists) {
        final data = snapshot.value as Map;
        return data.values.toList();
      }
      return [];
    } catch (e) {
      _logger.e("ERROR: $e");
      return [];
    }
  }
}
