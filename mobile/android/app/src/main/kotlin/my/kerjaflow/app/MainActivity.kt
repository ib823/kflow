package my.kerjaflow.app

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Main Activity for KerjaFlow
 * Handles Flutter engine initialization and platform channels
 */
class MainActivity : FlutterActivity() {

    companion object {
        private const val CHANNEL_HMS = "my.kerjaflow.app/hms"
        private const val CHANNEL_DEEP_LINK = "my.kerjaflow.app/deep_link"
    }

    private var pendingDeepLink: String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Handle deep link from intent
        handleIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleIntent(intent)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // HMS Push Channel
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL_HMS
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getHmsToken" -> {
                    val token = getHmsToken()
                    result.success(token)
                }
                "getPendingNotification" -> {
                    val notification = getPendingNotification()
                    result.success(notification)
                }
                "clearPendingNotification" -> {
                    clearPendingNotification()
                    result.success(null)
                }
                "isHmsAvailable" -> {
                    result.success(isHmsAvailable())
                }
                else -> result.notImplemented()
            }
        }

        // Deep Link Channel
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL_DEEP_LINK
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getInitialLink" -> {
                    result.success(pendingDeepLink)
                    pendingDeepLink = null
                }
                else -> result.notImplemented()
            }
        }
    }

    /**
     * Handle incoming intents for deep links
     */
    private fun handleIntent(intent: Intent?) {
        intent?.let {
            val action = it.action
            val data = it.data

            if (Intent.ACTION_VIEW == action && data != null) {
                pendingDeepLink = data.toString()

                // If Flutter is already running, send via method channel
                flutterEngine?.let { engine ->
                    MethodChannel(
                        engine.dartExecutor.binaryMessenger,
                        CHANNEL_DEEP_LINK
                    ).invokeMethod("onDeepLink", pendingDeepLink)
                }
            }
        }
    }

    /**
     * Get HMS push token from shared preferences
     */
    private fun getHmsToken(): String? {
        val prefs = getSharedPreferences("hms_push_prefs", MODE_PRIVATE)
        return prefs.getString("hms_token", null)
    }

    /**
     * Get pending notification from shared preferences
     */
    private fun getPendingNotification(): String? {
        val prefs = getSharedPreferences("hms_push_prefs", MODE_PRIVATE)
        val notification = prefs.getString("pending_notification", null)
        val timestamp = prefs.getLong("notification_timestamp", 0)

        // Only return if notification is recent (within 5 minutes)
        return if (notification != null &&
            System.currentTimeMillis() - timestamp < 5 * 60 * 1000
        ) {
            notification
        } else {
            null
        }
    }

    /**
     * Clear pending notification
     */
    private fun clearPendingNotification() {
        val prefs = getSharedPreferences("hms_push_prefs", MODE_PRIVATE)
        prefs.edit()
            .remove("pending_notification")
            .remove("notification_timestamp")
            .apply()
    }

    /**
     * Check if HMS Core is available on this device
     */
    private fun isHmsAvailable(): Boolean {
        return try {
            val hmsApiAvailability = Class.forName(
                "com.huawei.hms.api.HuaweiApiAvailability"
            )
            val getInstance = hmsApiAvailability.getMethod("getInstance")
            val instance = getInstance.invoke(null)
            val isHuaweiMobileServicesAvailable = hmsApiAvailability.getMethod(
                "isHuaweiMobileServicesAvailable",
                android.content.Context::class.java
            )
            val result = isHuaweiMobileServicesAvailable.invoke(
                instance,
                applicationContext
            ) as Int
            result == 0 // ConnectionResult.SUCCESS
        } catch (e: Exception) {
            false
        }
    }
}
