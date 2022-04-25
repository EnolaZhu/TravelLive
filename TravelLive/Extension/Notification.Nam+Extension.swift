//
//  Notification.Nam+Extension.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/13.
//

import Foundation

extension Notification.Name {
    public static let animationNotificationKey = Notification.Name(rawValue: "heart")
    public static let textNotificationKey = Notification.Name(rawValue: "text")
    public static let closePullingViewKey = Notification.Name(rawValue: "close")
    public static let changeLoveButtonKey = Notification.Name(rawValue: "love")
    public static let showUserPropertyKey = Notification.Name(rawValue: "user")
    public static let showLikedPropertyKey = Notification.Name(rawValue: "like")
    public static let redirectNewViewKey = Notification.Name(rawValue: "redirect")
}
