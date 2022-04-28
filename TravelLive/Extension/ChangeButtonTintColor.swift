//
//  ChangeButtonTintColor.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/28.
//

import Foundation
import UIKit


func changeButtonTintColor(_ button: UIButton, _ isButtonSelected: Bool, _ image: UIImage) {
    if isButtonSelected {
        let image = image.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = UIColor.primary
    } else {
        let image = image.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = UIColor.secondary
    }
}
