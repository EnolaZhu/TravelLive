//
//  AppDelegate.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/4.
//

import UIKit
import GoogleMaps
import Firebase
import UserNotifications
import GoogleMobileAds
import TXLiteAVSDK_Professional

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
        
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        GMSServices.provideAPIKey(Secret.googleMapApiKey.title)
        
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in
        }
        UIApplication.shared.registerForRemoteNotifications()
        
        // Navigationbar color
        if #available(iOS 15, *) {
            let navigationBarAppearance = UINavigationBarAppearance()
            navigationBarAppearance.configureWithOpaqueBackground()
            navigationBarAppearance.titleTextAttributes = [
                NSAttributedString.Key.foregroundColor: UIColor.primary
            ]
            navigationBarAppearance.backgroundColor = UIColor.backgroundColor
            UINavigationBar.appearance().standardAppearance = navigationBarAppearance
            UINavigationBar.appearance().compactAppearance = navigationBarAppearance
        }
        
        if let user = Auth.auth().currentUser {
            UserManager.shared.userID = "\(user.uid)"
        }
        
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        V2TXLivePremier.setLicence(Secret.liveLicenceUrl.title, key: Secret.liveLicenceKey.title)
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Make all people subscribe topic "all"
        NotificationManager.shared.subscribeTopic(topic: "all")
        // ???????????????????????? test topic
        NotificationManager.shared.subscribeTopic(topic: "test")
        
        let deviceTokenString = deviceToken.reduce("") {
            $0 + String(format: "%02x", $1)
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    // ??????????????????????????????
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let content = response.notification.request.content
        completionHandler()
    }
    
    // ??? App ???????????????????????????
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if #available(iOS 14.0, *) {
            completionHandler([.banner])
        } else {
            // Fallback on earlier versions
        }
    }
}
