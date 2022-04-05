//
//  UIStoryboard+Extension.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/5.
//

import UIKit

private struct StoryboardCategory {
    static let main = "Main"
    static let pushStreaming = "PushStreaming"
}

extension UIStoryboard {
    static var main: UIStoryboard { return stStoryboard(name: StoryboardCategory.main) }
    static var lobby: UIStoryboard { return stStoryboard(name: StoryboardCategory.pushStreaming) }

    private static func stStoryboard(name: String) -> UIStoryboard {
        return UIStoryboard(name: name, bundle: nil)
    }
}

