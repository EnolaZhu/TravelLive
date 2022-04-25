//
//  UIView+Extension.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/24.
//

import UIKit

extension UIView {

    func roundCorners(cornerRadius: Double) {
        self.layer.cornerRadius = CGFloat(cornerRadius)
        self.clipsToBounds = true
    }
}
