package my.kerjaflow.app

import android.util.Log
import com.huawei.hms.push.HmsMessageService
import com.huawei.hms.push.RemoteMessage
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel

/**
 * Huawei Push Kit Message Service
 * Handles push notifications for devices using Huawei Mobile Services
 */
class HmsPushService : HmsMessageService() {

    companion object {
        private const val TAG = "HmsPushService"
        private const val CHANNEL_NAME = "my.kerjaflow.app/hms_push"
    }

    /**
     * Called when a new HMS push token is generated
     */
    override fun onNewToken(token: String?) {
        Log.d(TAG, "HMS Push Token: $token")
        token?.let {
            // Send token to Flutter via MethodChannel
            sendTokenToFlutter(it)
        }
    }

    /**
     * Called when a data message is received
     */
    override fun onMessageReceived(message: RemoteMessage?) {
        Log.d(TAG, "HMS Message received")
        message?.let {
            // Extract notification data
            val data = it.dataOfMap
            val notification = it.notification

            Log.d(TAG, "Message data: $data")

            if (notification != null) {
                Log.d(TAG, "Notification title: ${notification.title}")
                Log.d(TAG, "Notification body: ${notification.body}")
            }

            // Forward to Flutter for handling
            sendMessageToFlutter(data, notification)
        }
    }

    /**
     * Called when message delivery status is updated
     */
    override fun onMessageSent(msgId: String?) {
        Log.d(TAG, "HMS Message sent: $msgId")
    }

    /**
     * Called when message sending fails
     */
    override fun onSendError(msgId: String?, exception: Exception?) {
        Log.e(TAG, "HMS Message send error: $msgId", exception)
    }

    /**
     * Called when the device token is deleted
     */
    override fun onTokenError(exception: Exception?) {
        Log.e(TAG, "HMS Token error", exception)
    }

    /**
     * Send the HMS token to Flutter layer
     */
    private fun sendTokenToFlutter(token: String) {
        try {
            // Use background isolate or shared preferences
            // to communicate with Flutter
            val prefs = applicationContext.getSharedPreferences(
                "hms_push_prefs",
                MODE_PRIVATE
            )
            prefs.edit().putString("hms_token", token).apply()
        } catch (e: Exception) {
            Log.e(TAG, "Failed to store HMS token", e)
        }
    }

    /**
     * Send the message to Flutter layer for processing
     */
    private fun sendMessageToFlutter(
        data: Map<String, String>,
        notification: RemoteMessage.Notification?
    ) {
        try {
            // Store notification data for Flutter to retrieve
            val prefs = applicationContext.getSharedPreferences(
                "hms_push_prefs",
                MODE_PRIVATE
            )

            val notificationJson = buildString {
                append("{")
                append("\"title\":\"${notification?.title ?: ""}\",")
                append("\"body\":\"${notification?.body ?: ""}\",")
                append("\"data\":{")
                data.entries.forEachIndexed { index, entry ->
                    if (index > 0) append(",")
                    append("\"${entry.key}\":\"${entry.value}\"")
                }
                append("}}")
            }

            prefs.edit()
                .putString("pending_notification", notificationJson)
                .putLong("notification_timestamp", System.currentTimeMillis())
                .apply()
        } catch (e: Exception) {
            Log.e(TAG, "Failed to store notification data", e)
        }
    }
}
