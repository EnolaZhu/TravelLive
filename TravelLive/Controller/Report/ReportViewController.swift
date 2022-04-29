//
//  ReportViewController.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/20.
//

import UIKit

protocol CloseMaskView: AnyObject {
    func pressCloseButton()
}

class ReportViewController: UIViewController {

    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var reportButton: UIButton!
    var clickCloseButton: CloseMaskView?
    var propertyOwnerId = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cancelButton.setTitle(ButtonTittle.cancel.rawValue, for: .normal)
        reportButton.setTitle(ButtonTittle.report.rawValue, for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelReport(_:)), for: .touchUpInside)
        reportButton.addTarget(self, action: #selector(report(_:)), for: .touchUpInside)
        
        self.view.backgroundColor = UIColor.white
        cancelButton.backgroundColor = UIColor.white
        reportButton.backgroundColor = UIColor.white
        
        self.view.roundCorners(cornerRadius: 25)
    }
    
    @objc func cancelReport(_ sender: UIButton) {
        closeReportView()
    }
    
    @objc func report(_ sender: UIButton) {
        DetailDataProvider.shared.postBanData(reason: "內容違規", userId: propertyOwnerId, whistleblowerId: userID)
        closeReportView()
    }
    
    func closeReportView() {
        clickCloseButton?.pressCloseButton()
        UIView.animate(withDuration: 0.3, delay: 0.01, options: .curveEaseInOut, animations: { [self] in
            self.view.frame = CGRect(x: 0, y: 1000, width: UIScreen.width, height: 500)
        }, completion: { _ in print("close login page")})
    }
}

enum ButtonTittle: String {
    case report = "檢舉"
    case cancel = "取消"
}
