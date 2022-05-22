//
//  AnalyticsManager.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/5/17.
//

import Foundation
import FirebaseAnalytics

class AnalyticsManager {
    static let shared = AnalyticsManager()
    
    func postAnalitic(eventName: String, name: String, text: String) {
        Analytics.logEvent(eventName, parameters: [
          "name": name as NSObject,
          "full_text": text as NSObject
        ])
    }
}
