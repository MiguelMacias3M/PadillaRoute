import 'package:padillaroutea/services/connectors/realtime_db_connector.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:logger/logger.dart';

class RealtimeDbHelper {
  static final FirebaseDatabase connection =
      RealtimedbConnector.getConnection();

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

  Future<Map<String, dynamic>> getEntryById(
      DatabaseReference ref, String id) async {
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

  Future<void> updateEntry(
      DatabaseReference ref, String id, Map<String, dynamic> data) async {
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

  Future<String?> getKeyByField(
      DatabaseReference ref, String field, dynamic value) async {
    try {
      final snapshot =
          await ref.orderByChild(field).equalTo(value).limitToFirst(1).get();

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

  Future<List> fetchEntriesByMonth(
      DatabaseReference ref, int year, int month) async {
    try {
      // Format the start and end dates for the month
      String startDate = "$year-${month.toString().padLeft(2, '0')}-01";
      String endDate = "$year-${month.toString().padLeft(2, '0')}-31";

      final snapshot = await ref
          .orderByChild('fecha')
          .startAt(startDate)
          .endAt(endDate)
          .get();

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

  Future<List> fetchEntriesByDate(DatabaseReference ref, DateTime date) async {
    try {
      // Format the start and end of the day
      String startOfDay =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} 00:00:00";
      String endOfDay =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} 23:59:59";
      final snapshot =
          await ref.orderByChild('fecha').startAt(startOfDay).endAt(endOfDay).get();
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

  Future<List> fetchEntriesByDateRange(
      DatabaseReference ref, DateTime startDate, DateTime endDate) async {
    try {
    // Format the start and end of the range
    String formattedStartDate =
        "${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')} 00:00:00";
    String formattedEndDate =
        "${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')} 23:59:59";

      final snapshot = await ref
          .orderByChild('fecha')
          .startAt(formattedStartDate)
          .endAt(formattedEndDate)
          .get();

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
