import UIKit
import Flutter
import UserNotifications

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {

    private var deepLinkChannel: FlutterMethodChannel?
    private var deviceSecurityChannel: FlutterMethodChannel?
    private var secureScreenChannel: FlutterMethodChannel?
    private var isSecureScreenEnabled = false

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Configure Flutter engine
        let controller = window?.rootViewController as! FlutterViewController

        // Set up deep link channel
        deepLinkChannel = FlutterMethodChannel(
            name: "my.kerjaflow.app/deep_link",
            binaryMessenger: controller.binaryMessenger
        )

        deepLinkChannel?.setMethodCallHandler { [weak self] call, result in
            switch call.method {
            case "getInitialLink":
                if let url = launchOptions?[.url] as? URL {
                    result(url.absoluteString)
                } else {
                    result(nil)
                }
            default:
                result(FlutterMethodNotImplemented)
            }
        }

        // Set up device security channel
        deviceSecurityChannel = FlutterMethodChannel(
            name: "kerjaflow/device_security",
            binaryMessenger: controller.binaryMessenger
        )

        deviceSecurityChannel?.setMethodCallHandler { [weak self] call, result in
            switch call.method {
            case "assessDevice":
                let assessment = self?.assessDeviceSecurity() ?? [:]
                result(assessment)
            default:
                result(FlutterMethodNotImplemented)
            }
        }

        // Set up secure screen channel
        secureScreenChannel = FlutterMethodChannel(
            name: "kerjaflow/secure_screen",
            binaryMessenger: controller.binaryMessenger
        )

        secureScreenChannel?.setMethodCallHandler { [weak self] call, result in
            switch call.method {
            case "enableSecure":
                self?.enableSecureScreen()
                result(true)
            case "disableSecure":
                self?.disableSecureScreen()
                result(true)
            default:
                result(FlutterMethodNotImplemented)
            }
        }

        // Request notification permissions
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: { _, _ in }
            )
        }

        application.registerForRemoteNotifications()

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // MARK: - Deep Linking

    override func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        // Handle custom scheme deep links (kerjaflow://)
        deepLinkChannel?.invokeMethod("onDeepLink", arguments: url.absoluteString)
        return super.application(app, open: url, options: options)
    }

    override func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        // Handle universal links (https://kerjaflow.my/...)
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb,
           let url = userActivity.webpageURL {
            deepLinkChannel?.invokeMethod("onDeepLink", arguments: url.absoluteString)
        }
        return super.application(
            application,
            continue: userActivity,
            restorationHandler: restorationHandler
        )
    }

    // MARK: - Push Notifications

    override func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        // APNs token is handled by firebase_messaging plugin
        super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }

    override func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("Failed to register for remote notifications: \(error.localizedDescription)")
    }

    // MARK: - UNUserNotificationCenterDelegate

    @available(iOS 10.0, *)
    override func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is in foreground
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .badge, .sound])
        } else {
            completionHandler([.alert, .badge, .sound])
        }
    }

    @available(iOS 10.0, *)
    override func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        // Handle notification tap - handled by firebase_messaging plugin
        super.userNotificationCenter(center, didReceive: response, withCompletionHandler: completionHandler)
    }

    // MARK: - Device Security (Jailbreak Detection)

    /// Comprehensive device security assessment
    /// Per CLAUDE.md: Block rooted/jailbroken devices
    private func assessDeviceSecurity() -> [String: Any] {
        var securityIssues: [String] = []

        let isJailbroken = checkJailbreakIndicators()
        let isSimulator = checkSimulatorIndicators()

        if isJailbroken {
            securityIssues.append("Device is jailbroken")
        }
        if isSimulator {
            securityIssues.append("Running on simulator")
        }

        let riskLevel: String
        if isJailbroken {
            riskLevel = "critical"
        } else if isSimulator {
            riskLevel = "high"
        } else {
            riskLevel = "none"
        }

        return [
            "isSecure": !isJailbroken && !isSimulator,
            "isRooted": false, // Android only
            "isJailbroken": isJailbroken,
            "isEmulator": isSimulator,
            "isDeveloperMode": false, // Not applicable on iOS
            "securityIssues": securityIssues,
            "riskLevel": riskLevel
        ]
    }

    /// Check for jailbreak indicators
    private func checkJailbreakIndicators() -> Bool {
        // Check for common jailbreak files
        let jailbreakPaths = [
            "/Applications/Cydia.app",
            "/Library/MobileSubstrate/MobileSubstrate.dylib",
            "/bin/bash",
            "/usr/sbin/sshd",
            "/etc/apt",
            "/private/var/lib/apt/",
            "/usr/bin/ssh",
            "/var/cache/apt",
            "/var/lib/cydia",
            "/var/log/syslog",
            "/bin/sh",
            "/private/var/stash",
            "/private/var/lib/apt",
            "/private/var/tmp/cydia.log",
            "/Applications/Sileo.app",
            "/var/jb",
            "/private/var/jb",
            "/usr/libexec/sftp-server",
            "/Applications/blackra1n.app",
            "/Applications/FakeCarrier.app",
            "/Applications/Icy.app",
            "/Applications/IntelliScreen.app",
            "/Applications/MxTube.app",
            "/Applications/RockApp.app",
            "/Applications/SBSettings.app",
            "/Applications/WinterBoard.app"
        ]

        for path in jailbreakPaths {
            if FileManager.default.fileExists(atPath: path) {
                return true
            }
        }

        // Check if we can write to restricted paths
        let testPath = "/private/jailbreak_test.txt"
        do {
            try "test".write(toFile: testPath, atomically: true, encoding: .utf8)
            try FileManager.default.removeItem(atPath: testPath)
            return true // If we can write here, device is jailbroken
        } catch {
            // Expected on non-jailbroken devices
        }

        // Check for suspicious URL schemes
        if let url = URL(string: "cydia://package/com.example.package") {
            if UIApplication.shared.canOpenURL(url) {
                return true
            }
        }

        // Check for dylib injection
        let suspiciousDylibs = [
            "SubstrateLoader.dylib",
            "SSLKillSwitch2.dylib",
            "SSLKillSwitch.dylib",
            "MobileSubstrate.dylib",
            "TweakInject.dylib",
            "CydiaSubstrate"
        ]

        for dylib in suspiciousDylibs {
            if let handle = dlopen(dylib, RTLD_NOW) {
                dlclose(handle)
                return true
            }
        }

        // Check if fork is possible (blocked on non-jailbroken devices)
        let forkResult = fork()
        if forkResult >= 0 {
            if forkResult > 0 {
                kill(forkResult, SIGTERM)
            }
            return true
        }

        return false
    }

    /// Check if running on simulator
    private func checkSimulatorIndicators() -> Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        // Additional runtime check
        if ProcessInfo.processInfo.environment["SIMULATOR_DEVICE_NAME"] != nil {
            return true
        }
        return false
        #endif
    }

    // MARK: - Secure Screen (Screenshot Prevention)

    /// Enable secure screen to prevent screenshots
    /// Per CLAUDE.md: Screenshot prevention on sensitive screens
    private func enableSecureScreen() {
        isSecureScreenEnabled = true

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            // Add secure text field overlay technique
            if let window = self.window {
                let secureField = UITextField()
                secureField.isSecureTextEntry = true
                secureField.isUserInteractionEnabled = false
                secureField.tag = 999 // Tag for identification
                window.addSubview(secureField)
                window.layer.superlayer?.addSublayer(secureField.layer)
                secureField.layer.sublayers?.first?.addSublayer(window.layer)
            }

            // Register for screenshot notification
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(self.screenshotDetected),
                name: UIApplication.userDidTakeScreenshotNotification,
                object: nil
            )

            // Register for screen recording notification (iOS 11+)
            if #available(iOS 11.0, *) {
                NotificationCenter.default.addObserver(
                    self,
                    selector: #selector(self.screenRecordingChanged),
                    name: UIScreen.capturedDidChangeNotification,
                    object: nil
                )
            }
        }
    }

    /// Disable secure screen
    private func disableSecureScreen() {
        isSecureScreenEnabled = false

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            // Remove secure overlay
            if let window = self.window {
                window.viewWithTag(999)?.removeFromSuperview()
            }

            // Remove observers
            NotificationCenter.default.removeObserver(
                self,
                name: UIApplication.userDidTakeScreenshotNotification,
                object: nil
            )

            if #available(iOS 11.0, *) {
                NotificationCenter.default.removeObserver(
                    self,
                    name: UIScreen.capturedDidChangeNotification,
                    object: nil
                )
            }
        }
    }

    @objc private func screenshotDetected() {
        if isSecureScreenEnabled {
            // Log screenshot attempt - could send to analytics
            print("[Security] Screenshot attempt detected on secure screen")

            // Optionally notify Flutter
            secureScreenChannel?.invokeMethod("onScreenshotAttempt", arguments: nil)
        }
    }

    @objc private func screenRecordingChanged() {
        if #available(iOS 11.0, *) {
            if UIScreen.main.isCaptured && isSecureScreenEnabled {
                // Screen recording is active on a secure screen
                print("[Security] Screen recording detected on secure screen")

                // Optionally notify Flutter
                secureScreenChannel?.invokeMethod("onScreenRecordingDetected", arguments: nil)
            }
        }
    }
}
