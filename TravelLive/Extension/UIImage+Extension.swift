//
//  UIImage+Extension.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/5.
//

import UIKit

enum ImageAsset: String {
    
    // push streming icon
    case Icons_camera_beauty
    case Icons_camera_beauty_close
    case Icons_close_preview
    case Icons_camera_preview
    case Icons_camera_beauty_1
    
    // tab icon
    case Icons_live_normal
    case Icons_map_normal
    case Icons_profile_normal
    case Icons_search_normal
    case Icons_shop_normal
    case Icons_live_focus
    case Icons_map_focus
    case Icons_profile_focus
    case Icons_search_focus
    case Icons_shop_focus
}
extension UIImage {
    static func asset(_ asset: ImageAsset) -> UIImage? {
        return UIImage(named: asset.rawValue)
    }
}
