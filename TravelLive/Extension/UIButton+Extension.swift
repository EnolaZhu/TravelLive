//
//  UIButton+Extension.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/7.
//

import UIKit

extension UIButton {
    // swiftlint:disable opening_brace line_length function_parameter_count
    func configureButton(text: String, image: UIImage, imagePadding: CGFloat, edgePadding: CGFloat, button: UIButton, backgroundColor: UIColor, textColor: UIColor)  {
        var configuration = UIButton.Configuration.filled()
        configuration.title = text
        configuration.image = image
        configuration.imagePadding = imagePadding
        configuration.contentInsets = NSDirectionalEdgeInsets(top: edgePadding, leading: edgePadding, bottom: edgePadding, trailing: edgePadding)
        configuration.background.backgroundColor = backgroundColor
        configuration.baseForegroundColor = textColor
        button.configuration = configuration
    }
}

@IBDesignable extension UIButton {

    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }

    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }

    @IBInspectable var borderColor: UIColor? {
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
    }
}
