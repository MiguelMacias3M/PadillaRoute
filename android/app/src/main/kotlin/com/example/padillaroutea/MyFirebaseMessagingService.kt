package com.ejemplo.padillaroute

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage

class MyFirebaseMessagingService : FirebaseMessagingService() {

    override fun onNewToken(token: String) {
        Log.d("FCM", "Nuevo token: $token")
        // Aquí puedes enviar el token a tu servidor si es necesario
    }

    override fun onMessageReceived(remoteMessage: RemoteMessage) {
    Log.d("FCM", "Mensaje recibido: ${remoteMessage.notification?.title}")

    remoteMessage.notification?.let {
        mostrarNotificacion(it.title ?: "Nueva Notificación", it.body ?: "Mensaje recibido")
    }
}

    private fun mostrarNotificacion(titulo: String, mensaje: String) {
    val channelId = "canal_padillaroute"
    val notificationId = 1001

    // Crear canal de notificación para Android 8+ si no existe
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
        val channel = NotificationChannel(
            channelId,
            "Canal de Notificaciones",
            NotificationManager.IMPORTANCE_HIGH
        ).apply {
            description = "Canal para notificaciones de PadillaRoute"
        }

        // Obtener NotificationManager y crear el canal
        val notificationManager = getSystemService(NotificationManager::class.java)
        notificationManager?.createNotificationChannel(channel)
    }

    // Crear la notificación
    val builder = NotificationCompat.Builder(this, channelId)
        .setSmallIcon(android.R.drawable.ic_dialog_info) // Cambia a un ícono válido
        .setContentTitle(titulo)
        .setContentText(mensaje)
        .setPriority(NotificationCompat.PRIORITY_HIGH)
        .setAutoCancel(true)

    // Lanza la notificación
    val notificationManagerCompat = NotificationManagerCompat.from(this)
    notificationManagerCompat.notify(notificationId, builder.build())
}


}
