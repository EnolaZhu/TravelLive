//
//  NotificationManager.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/26.
//

import FirebaseMessaging

class NotificationManager {
    static let shared = NotificationManager()
    
    func subscribeTopic(topic: String) {
        // Make user subscribe topic
        Messaging.messaging().subscribe(toTopic: topic) { _ in}
    }
}
