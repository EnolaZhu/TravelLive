//
//  UIColor+Extension.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/5.
//

import UIKit

private enum CustomColor: String {
    case primary = "#ED83A2"
    case secondary = "#909FA6"
    case backgroundColor = "#FBEBEF"
}

extension UIColor {
    static var primary: UIColor {
        return UIColor.hexStringToUIColor(hex: CustomColor.primary.rawValue)
    }
    
    static var secondary: UIColor {
        return UIColor.hexStringToUIColor(hex: CustomColor.secondary.rawValue)
    }
    
    static var backgroundColor: UIColor {
        return UIColor.hexStringToUIColor(hex: CustomColor.backgroundColor.rawValue)
    }

    static func hexStringToUIColor(hex: String) -> UIColor {
        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }
        if (cString.count) != 6 {
            return UIColor.gray
        }

        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
