//
//  IpadAlertManager.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/5/20.
//

import UIKit

class IpadAlertManager {
    static let ipadAlertManager = IpadAlertManager()
    func makeAlertSuitIpad(_ alertController: UIAlertController, view: UIView) {
        alertController.popoverPresentationController?.sourceView = view
        let xOrigin = view.bounds.width / 2
        let popoverRect = CGRect(x: xOrigin, y: 0, width: 1, height: 1)
        alertController.popoverPresentationController?.sourceRect = popoverRect
        alertController.popoverPresentationController?.permittedArrowDirections = .up
    }
}
