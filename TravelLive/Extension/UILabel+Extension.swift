//
//  UILabel+Extension.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/9.
//

import UIKit

@IBDesignable
extension UILabel {
    @IBInspectable var characterSpacing: CGFloat {
        get {
            // swiftlint:disable force_cast
            return attributedText?.value(forKey: NSAttributedString.Key.kern.rawValue) as! CGFloat
            // swiftlint:enable force_cast
        }
        set {
            if let labelText = text, labelText.count > 0 {
                let attributedString = NSMutableAttributedString(attributedString: attributedText!)
                attributedString.addAttribute(
                    NSAttributedString.Key.kern,
                    value: newValue,
                    range: NSRange(location: 0, length: attributedString.length - 1)
                )
                attributedText = attributedString
            }
        }
    }
}
@IBDesignable
class EdgeInsetLabel: UILabel {
    var textInsets = UIEdgeInsets.zero {
        didSet { invalidateIntrinsicContentSize() }
    }
    
    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let insetRect = bounds.inset(by: textInsets)
        let textRect = super.textRect(forBounds: insetRect, limitedToNumberOfLines: numberOfLines)
        let invertedInsets = UIEdgeInsets(top: -textInsets.top,
                                          left: -textInsets.left,
                                          bottom: -textInsets.bottom,
                                          right: -textInsets.right)
        return textRect.inset(by: invertedInsets)
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }
}

extension EdgeInsetLabel {
    @IBInspectable
    var leftTextInset: CGFloat {
        get { return textInsets.left }
        set { textInsets.left = newValue }
    }
    @IBInspectable
    var rightTextInset: CGFloat {
        get { return textInsets.right }
        set { textInsets.right = newValue }
    }
    @IBInspectable
    var topTextInset: CGFloat {
        get { return textInsets.top }
        set { textInsets.top = newValue }
    }
    @IBInspectable
    var bottomTextInset: CGFloat {
        get { return textInsets.bottom }
        set { textInsets.bottom = newValue }
    }
}
