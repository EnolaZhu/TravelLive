//
//  UIImage+Extension.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/5.
//

import UIKit

enum ImageAsset: String {
    // push streming icon
    // swiftlint:disable identifier_name
    case Icons_camera_beauty
    case Icons_camera_beauty_close
    case Icons_close_preview
    case Icons_camera_preview
    case Icons_camera_beauty_1
    // tab icon
    case Icons_live
    case Icons_map
    case Icons_profile
    case Icons_search
    case Icons_shop
    // auth image
    case apple
}
extension UIImage {
    static func asset(_ asset: ImageAsset) -> UIImage? {
        return UIImage(named: asset.rawValue)
    }
}
