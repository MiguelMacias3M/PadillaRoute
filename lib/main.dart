import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:padillaroutea/firebase_options.dart';
import 'package:padillaroutea/objectbox.g.dart';
import 'package:padillaroutea/services/connectors/objectbox_connector.dart';
import '../screens/loginscreen.dart'; // Importamos la pantalla de inicio de sesión


late ObjectBox objectBox;
  void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    objectBox = await ObjectBox.create();
  } on ObjectBoxException catch (e) {
    throw Exception("Someting went wrong when trying to run ObjectBox: $e");
  }

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on FirebaseException catch (e) {
    throw Exception("Something went wrong when trying to run Firebase: $e");
  }   

  runApp(const MyApp());
  // WidgetsBinding.instance.addPostFrameCallback((_) => showSuccessDialog());
}

void showSuccessDialog() {
  showDialog(
    context: navigatorKey.currentContext!,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('¡Exito!'),
        content: const Text('Conexión con la base de datos estableceida correctamente.'),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: LoginScreen(),
      navigatorKey: navigatorKey,
    );
  }
}
