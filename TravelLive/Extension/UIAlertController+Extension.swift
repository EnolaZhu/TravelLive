//
//  UIAlertController+Extension.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/5/11.
//

import UIKit

public extension UIAlertController {

    func setMessageAlignment(_ alignment: NSTextAlignment) {
        guard let paragraphStyle = NSParagraphStyle.default.mutableCopy() as? NSMutableParagraphStyle else { return }
        paragraphStyle.alignment = alignment

        let messageText = NSMutableAttributedString(
            string: self.message ?? "",
            attributes: [
                NSAttributedString.Key.paragraphStyle: paragraphStyle,
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14),
                NSAttributedString.Key.foregroundColor: UIColor.black
            ]
        )

        self.setValue(messageText, forKey: "attributedMessage")
    }
}
