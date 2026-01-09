package my.kerjaflow.app

import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

/**
 * Main Activity for KerjaFlow
 * Handles Flutter engine initialization and platform channels
 */
class MainActivity : FlutterActivity() {

    companion object {
        private const val CHANNEL_HMS = "my.kerjaflow.app/hms"
        private const val CHANNEL_DEEP_LINK = "my.kerjaflow.app/deep_link"
        private const val CHANNEL_DEVICE_SECURITY = "kerjaflow/device_security"
        private const val CHANNEL_SECURE_SCREEN = "kerjaflow/secure_screen"
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

        // Device Security Channel - Root/Emulator Detection
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL_DEVICE_SECURITY
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "assessDevice" -> {
                    val assessment = assessDeviceSecurity()
                    result.success(assessment)
                }
                else -> result.notImplemented()
            }
        }

        // Secure Screen Channel - Screenshot Prevention
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL_SECURE_SCREEN
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "enableSecure" -> {
                    enableSecureScreen()
                    result.success(true)
                }
                "disableSecure" -> {
                    disableSecureScreen()
                    result.success(true)
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

    // ============================================================
    // DEVICE SECURITY - Root/Emulator Detection
    // ============================================================

    /**
     * Comprehensive device security assessment
     * Per CLAUDE.md: Block rooted/jailbroken devices
     */
    private fun assessDeviceSecurity(): Map<String, Any> {
        val securityIssues = mutableListOf<String>()

        val isRooted = checkRootIndicators()
        val isEmulator = checkEmulatorIndicators()
        val isDeveloperMode = checkDeveloperMode()

        if (isRooted) securityIssues.add("Device is rooted")
        if (isEmulator) securityIssues.add("Running on emulator")
        if (isDeveloperMode) securityIssues.add("Developer mode enabled")

        val riskLevel = when {
            isRooted -> "critical"
            isEmulator -> "high"
            isDeveloperMode -> "medium"
            else -> "none"
        }

        return mapOf(
            "isSecure" to (!isRooted && !isEmulator),
            "isRooted" to isRooted,
            "isJailbroken" to false, // iOS only
            "isEmulator" to isEmulator,
            "isDeveloperMode" to isDeveloperMode,
            "securityIssues" to securityIssues,
            "riskLevel" to riskLevel
        )
    }

    /**
     * Check for root indicators
     */
    private fun checkRootIndicators(): Boolean {
        // Check for su binary in common paths
        val suPaths = listOf(
            "/system/app/Superuser.apk",
            "/sbin/su",
            "/system/bin/su",
            "/system/xbin/su",
            "/data/local/xbin/su",
            "/data/local/bin/su",
            "/system/sd/xbin/su",
            "/system/bin/failsafe/su",
            "/data/local/su",
            "/su/bin/su",
            "/system/xbin/daemonsu",
            "/system/etc/init.d/99telekineto",
            "/system/app/Magisk.apk"
        )

        for (path in suPaths) {
            if (File(path).exists()) {
                return true
            }
        }

        // Check for root management apps
        val rootApps = listOf(
            "com.topjohnwu.magisk",
            "com.koushikdutta.superuser",
            "com.noshufou.android.su",
            "eu.chainfire.supersu",
            "com.thirdparty.superuser",
            "com.yellowes.su",
            "com.devadvance.rootcloak",
            "com.devadvance.rootcloakplus",
            "de.robv.android.xposed.installer",
            "com.saurik.substrate"
        )

        val pm = packageManager
        for (app in rootApps) {
            try {
                pm.getPackageInfo(app, PackageManager.GET_ACTIVITIES)
                return true
            } catch (e: PackageManager.NameNotFoundException) {
                // App not installed, continue checking
            }
        }

        // Check if we can execute su
        return try {
            val process = Runtime.getRuntime().exec(arrayOf("/system/xbin/which", "su"))
            val inputStream = process.inputStream
            val result = inputStream.bufferedReader().readText()
            inputStream.close()
            result.isNotEmpty()
        } catch (e: Exception) {
            false
        }
    }

    /**
     * Check for emulator indicators
     */
    private fun checkEmulatorIndicators(): Boolean {
        // Check Build properties
        val emulatorIndicators = listOf(
            Build.FINGERPRINT.startsWith("generic"),
            Build.FINGERPRINT.startsWith("unknown"),
            Build.MODEL.contains("google_sdk"),
            Build.MODEL.contains("Emulator"),
            Build.MODEL.contains("Android SDK built for x86"),
            Build.MANUFACTURER.contains("Genymotion"),
            Build.BRAND.startsWith("generic") && Build.DEVICE.startsWith("generic"),
            Build.PRODUCT == "sdk",
            Build.PRODUCT == "sdk_google",
            Build.PRODUCT == "google_sdk",
            Build.PRODUCT == "sdk_x86",
            Build.PRODUCT == "vbox86p",
            Build.PRODUCT == "emulator",
            Build.PRODUCT == "simulator",
            Build.HARDWARE.contains("goldfish"),
            Build.HARDWARE.contains("ranchu")
        )

        return emulatorIndicators.any { it }
    }

    /**
     * Check if developer mode is enabled
     */
    private fun checkDeveloperMode(): Boolean {
        return try {
            Settings.Secure.getInt(
                contentResolver,
                Settings.Global.DEVELOPMENT_SETTINGS_ENABLED,
                0
            ) != 0
        } catch (e: Exception) {
            false
        }
    }

    // ============================================================
    // SECURE SCREEN - Screenshot Prevention
    // ============================================================

    /**
     * Enable FLAG_SECURE to prevent screenshots and screen recording
     * Per CLAUDE.md: Screenshot prevention on sensitive screens
     */
    private fun enableSecureScreen() {
        runOnUiThread {
            window.setFlags(
                WindowManager.LayoutParams.FLAG_SECURE,
                WindowManager.LayoutParams.FLAG_SECURE
            )
        }
    }

    /**
     * Disable FLAG_SECURE to allow normal screen capture
     */
    private fun disableSecureScreen() {
        runOnUiThread {
            window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
        }
    }
}
