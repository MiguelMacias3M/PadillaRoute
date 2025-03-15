import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:padillaroutea/firebase_options.dart';
import 'package:padillaroutea/objectbox.g.dart';
import 'package:padillaroutea/services/connectors/objectbox_connector.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../screens/loginscreen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

late ObjectBox objectBox;
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Mensaje en segundo plano: ${message.notification?.title}");
  // Aquí también podrías mostrar la notificación en segundo plano si lo deseas.
  _showNotification(message.notification?.title, message.notification?.body);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializando ObjectBox
  try {
    objectBox = await ObjectBox.create();
  } on ObjectBoxException catch (e) {
    throw Exception("Something went wrong when trying to run ObjectBox: $e");
  }

  // Inicializando Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on FirebaseException catch (e) {
    throw Exception("Something went wrong when trying to run Firebase: $e");
  }

  // Solicitando permisos para notificaciones
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }

  // Obtener token FCM
  obtenerTokenFCM();

  // Inicializando las notificaciones locales
  await _initializeNotifications();

  // Escuchar los mensajes en primer plano
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    print("Mensaje en primer plano: ${message.notification?.title}");

    // Mostrar la notificación en primer plano
    if (message.notification != null) {
      _showNotification(message.notification?.title, message.notification?.body);
    }
  });

  // Escuchar los mensajes en segundo plano
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

// Función para inicializar las notificaciones
Future<void> _initializeNotifications() async {
  const AndroidInitializationSettings androidInitializationSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  final InitializationSettings initializationSettings = InitializationSettings(android: androidInitializationSettings);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

// Función para mostrar la notificación
Future<void> _showNotification(String? title, String? body) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'canal_id', // ID del canal
    'Canal de notificaciones',
    channelDescription: 'Descripción del canal',
    importance: Importance.high,
    priority: Priority.high,
  );

  const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

  await flutterLocalNotificationsPlugin.show(
    0, // ID de la notificación
    title, // Título de la notificación
    body, // Cuerpo de la notificación
    platformDetails, // Detalles de la notificación
  );
}

void obtenerTokenFCM() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  String? token = await messaging.getToken();
  print("Token FCM: $token");
}

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
      home: LoginScreen(),
    );
  }
}
