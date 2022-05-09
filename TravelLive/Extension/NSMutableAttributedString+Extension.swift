//
//  NSMutableAttributedString+Extension.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/5/8.
//

import UIKit

extension NSMutableAttributedString {
    
    func setColor(color: UIColor, forText stringValue: String) {
        let range: NSRange = self.mutableString.range(of: stringValue, options: .caseInsensitive)
        self.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
    }
}
