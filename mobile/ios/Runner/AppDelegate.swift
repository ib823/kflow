import UIKit
import Flutter
import UserNotifications

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {

    private var deepLinkChannel: FlutterMethodChannel?

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
}
