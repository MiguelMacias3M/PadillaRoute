package com.example.padillaroutea

import io.flutter.embedding.android.FlutterActivity
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage
import android.util.Log

class MainActivity: FlutterActivity()

class MyFirebaseMessagingService : FirebaseMessagingService() {
    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        Log.d("FCM", "Mensaje recibido: ${remoteMessage.notification?.title}")
    }

    override fun onNewToken(token: String) {
        Log.d("FCM", "Nuevo token generado: $token")
    }
}
