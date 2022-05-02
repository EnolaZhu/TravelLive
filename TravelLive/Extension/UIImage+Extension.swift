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
    // tab icon
    case Icons_live
    case Icons_map
    case Icons_profile
    case Icons_search
    case Icons_attractions
    // auth image
    case apple
    // live animation
    case heart
    case theheart
    case emptyHeart
    // post button
    case plus
    case stop
    case play
    
    case placeholder
    // map icon
    case event
    case place
    case mapIcon
    // profile
    case menu
    case right_segment_heart
    case left_segment_property
    case close
    case add
    case property
    // detail
    case send
    case share
    case option
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
    
    
    func outline() -> UIImage? {
        
        let size = CGSize(width: self.size.width, height: self.size.height)
        UIGraphicsBeginImageContext(size)
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        self.draw(in: rect, blendMode: .normal, alpha: 1.0)
        let context = UIGraphicsGetCurrentContext()
        context?.setStrokeColor(red: 1, green: 0, blue: 0, alpha: 1)
        context?.stroke(rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func maskWithColor(color: UIColor) -> UIImage? {
        let maskImage = cgImage!
        
        let width = size.width
        let height = size.height
        let bounds = CGRect(x: 0, y: 0, width: width, height: height)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!
        
        context.clip(to: bounds, mask: maskImage)
        context.setFillColor(color.cgColor)
        context.fill(bounds)
        
        if let cgImage = context.makeImage() {
            let coloredImage = UIImage(cgImage: cgImage)
            return coloredImage
        } else {
            return nil
        }
    }
}
