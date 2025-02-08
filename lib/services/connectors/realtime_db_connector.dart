import 'package:firebase_database/firebase_database.dart';

class RealtimedbConnector {
  static final instance = FirebaseDatabase.instance;

  RealtimedbConnector();

  static FirebaseDatabase getConnection() {
    return instance;
  }
  
}
