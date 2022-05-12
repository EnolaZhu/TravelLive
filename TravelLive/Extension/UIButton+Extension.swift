//
//  UIButton+Extension.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/7.
//

import UIKit

extension UIButton {
    // swiftlint:disable opening_brace line_length function_parameter_count
    @available(iOS 15.0, *)
    func configureButton(text: String, image: UIImage, imagePadding: CGFloat, edgePadding: CGFloat, button: UIButton, backgroundColor: UIColor, textColor: UIColor)  {
        if #available(iOS 15.0, *) {
            var configuration = UIButton.Configuration.filled()
        } else {
            // Fallback on earlier versions
        }
        configuration?.title = text
        configuration?.image = image
        configuration?.imagePadding = imagePadding
        if #available(iOS 15.0, *) {
            configuration?.contentInsets = NSDirectionalEdgeInsets(top: edgePadding, leading: edgePadding, bottom: edgePadding, trailing: edgePadding)
        } else {
            // Fallback on earlier versions
        }
        //        configuration.background.view.backgroundColor = backgroundColor
        configuration?.baseForegroundColor = textColor
        if #available(iOS 15.0, *) {
            button.configuration = configuration
        } else {
            // Fallback on earlier versions
        }
    }
    
    func hasImage(named imageName: String, for state: UIControl.State) -> Bool {
        guard let buttonImage = image(for: state), let namedImage = UIImage(named: imageName) else {
            return false
        }
        return buttonImage.pngData() == namedImage.pngData()
    }
    
    //MARK:- Animate check mark
    func checkboxAnimation(closure: @escaping () -> Void){
        guard let image = self.imageView else {return}
        
        UIView.animate(withDuration: 0.1, delay: 0.1, options: .curveLinear, animations: {
            image.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            
        }) { (success) in
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveLinear, animations: {
                self.isSelected = !self.isSelected
                //to-do
                closure()
                image.transform = .identity
            }, completion: nil)
        }
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
