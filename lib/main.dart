import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:padillaroutea/firebase_options.dart';
import 'package:padillaroutea/objectbox.g.dart';
import 'package:padillaroutea/services/connectors/objectbox_connector.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:padillaroutea/services/fcm_service.dart'; 
import 'package:padillaroutea/screens/loginscreen.dart'; 
import 'package:padillaroutea/screens/user/IncidentsScreenRegister.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';


late ObjectBox objectBox;
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Mensaje en segundo plano: ${message.notification?.title}");
  _showNotification(message.notification?.title, message.notification?.body);
}
  void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializando ObjectBox
  try {
    objectBox = await ObjectBox.create();
  } on ObjectBoxException catch (e) {
    throw Exception("Error al inicializar ObjectBox: $e");
  }

  // Inicializando Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on FirebaseException catch (e) {
    throw Exception("Error al inicializar Firebase: $e");
  }

  // Solicitar permisos para notificaciones
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }

  // Obtener token FCM
  obtenerTokenFCM();

  // Inicializar notificaciones locales
  await _initializeNotifications();

  // Escuchar mensajes en primer plano
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    print("Mensaje en primer plano: ${message.notification?.title}");
    _showNotification(message.notification?.title, message.notification?.body);
  });

  // Escuchar mensajes en segundo plano
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

// Inicializa las notificaciones locales
Future<void> _initializeNotifications() async {
  const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  final InitializationSettings settings = InitializationSettings(android: androidSettings);
  await flutterLocalNotificationsPlugin.initialize(settings);
}

// Muestra una notificación en la aplicación
Future<void> _showNotification(String? title, String? body) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'canal_id',
    'Canal de notificaciones',
    channelDescription: 'Descripción del canal',
    importance: Importance.high,
    priority: Priority.high,
  );

  const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

  await flutterLocalNotificationsPlugin.show(
    0,
    title,
    body,
    platformDetails,
  );
}

// Obtiene y muestra el token de FCM en la consola
void obtenerTokenFCM() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  String? token = await messaging.getToken();
  print("Token FCM: $token");
}

// Muestra un diálogo indicando que la conexión con la base de datos se realizó con éxito
void showSuccessDialog() {
  showDialog(
    context: navigatorKey.currentContext!,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('¡Éxito!'),
        content: const Text('Conexión con la base de datos establecida correctamente.'),
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
      title: 'Padilla Route',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/', // Definimos una ruta inicial
      routes: {
        '/': (context) => LoginScreen(), // Ruta principal
        '/incidentsScreenRegister': (context) => IncidentsScreenRegister(), // Agregamos la ruta de incidencias
      },
    );
  }
}
