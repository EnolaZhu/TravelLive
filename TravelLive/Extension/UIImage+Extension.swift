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
    // live animation
    case heart
    case theheart
    // post button
    case plus
    case stop
    case play
}

extension UIImage {
    static func asset(_ asset: ImageAsset) -> UIImage? {
        return UIImage(named: asset.rawValue)
    }
}

extension UIImage {
    func circularImage(_ radius: CGFloat) -> UIImage? {
            var imageView = UIImageView()
            if self.size.width > self.size.height {
                imageView.frame =  CGRect(x: 0, y: 0, width: self.size.width, height: self.size.width)
                imageView.image = self
                imageView.contentMode = .scaleAspectFit
            } else { imageView = UIImageView(image: self) }
            var layer: CALayer = CALayer()

            layer = imageView.layer
            layer.masksToBounds = true
            layer.cornerRadius = radius
            UIGraphicsBeginImageContext(imageView.bounds.size)
            layer.render(in: UIGraphicsGetCurrentContext()!)
            let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            return roundedImage
    }
}
