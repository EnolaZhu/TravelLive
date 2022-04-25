//
//  SceneDelegate.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/4.
//

import UIKit
//import FirebaseDynamicLinks

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func dynamicLinkToUniversalLink(dynamicLink: URL) {
        UniversalLinkManager.manager.redirect(dynamicUrl: dynamicLink)
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        
        // custom
        if let url = connectionOptions.userActivities.first?.webpageURL {
            dynamicLinkToUniversalLink(dynamicLink: url)
        }
        
        // DynamicLinks
//        if let userActivity = connectionOptions.userActivities.first, let url = userActivity.webpageURL {
//                DynamicLinks.dynamicLinks().handleUniversalLink(url) { dynamicLink, error in
//                    guard let dynamicLink = dynamicLink, let url = dynamicLink.url else { return }
//                    self.parseDynamicLink(dynamicLink: url)
//                }
//            }
        
    }
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
//        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
//              let urlToOpen = userActivity.webpageURL else {
//                  return
//              }
//        print(urlToOpen)
        
        // custom
        guard let url = userActivity.webpageURL else { return }
        dynamicLinkToUniversalLink(dynamicLink: url)
        
        // DynamicLinks
//        guard let url = userActivity.webpageURL else { return }
//            DynamicLinks.dynamicLinks().handleUniversalLink(url) { dynamicLink, error in
//                guard let dynamicLink = dynamicLink, let url = dynamicLink.url else { return }
//                self.parseDynamicLink(dynamicLink: url)
//
//
//                // launch dynamic link code here...?
//            }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let urlContext = URLContexts.first else { return }

        // custom
        dynamicLinkToUniversalLink(dynamicLink: urlContext.url)
        
        // DynamicLinks
//        if let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: urlContext.url) {
//            guard let url = dynamicLink.url else { return }
//            self.parseDynamicLink(dynamicLink: url)
//        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}
