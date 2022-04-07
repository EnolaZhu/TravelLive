//
//  UIButton+Extension.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/7.
//

import UIKit

extension UIButton {
    
    func configurePadding(text: String, imageName: String, imagePadding: CGFloat, edgePadding: CGFloat) {
        var configuration = UIButton.Configuration.filled()
        configuration.title = text
        configuration.image = UIImage(systemName: imageName)
        configuration.imagePadding = imagePadding
        configuration.contentInsets = NSDirectionalEdgeInsets(top: edgePadding, leading: edgePadding, bottom: edgePadding, trailing: edgePadding)
    }
}

@IBDesignable extension UIButton {

    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }

    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }

    @IBInspectable var borderColor: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
}
