//
//  UIImageView+Extension.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/19.
//

import UIKit

extension UIImageView {

    func makeRounded() {
        self.layer.borderWidth = 0
        self.layer.masksToBounds = false
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.cornerRadius = self.frame.height / 2
        self.clipsToBounds = true
    }
}
