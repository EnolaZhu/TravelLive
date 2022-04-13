//
//  UIStoryboard+Extension.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/5.
//

import UIKit

private struct StoryboardCategory {
    static let main = "Main"
    static let map = "Map"
    static let search = "Search"
    static let pushStreaming = "PushStreaming"
    static let shop = "Shop"
    static let profile = "Profile"
    static let chat = "Chat"
    static let pullStreaming = "PullStreaming"
}

extension UIStoryboard {
    static var main: UIStoryboard { return stStoryboard(name: StoryboardCategory.main) }
    static var map: UIStoryboard { return stStoryboard(name: StoryboardCategory.map) }
    static var search: UIStoryboard { return stStoryboard(name: StoryboardCategory.search) }
    static var pushStreaming: UIStoryboard { return stStoryboard(name: StoryboardCategory.pushStreaming) }
    static var shop: UIStoryboard { return stStoryboard(name: StoryboardCategory.shop) }
    static var profile: UIStoryboard { return stStoryboard(name: StoryboardCategory.profile) }
    static var chat: UIStoryboard { return stStoryboard(name: StoryboardCategory.chat) }
    static var pullStreaming: UIStoryboard { return stStoryboard(name: StoryboardCategory.pullStreaming) }

    private static func stStoryboard(name: String) -> UIStoryboard {
        return UIStoryboard(name: name, bundle: nil)
    }
}
