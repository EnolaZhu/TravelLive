//
//  BaseViewController.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/8.
//

import UIKit
import IQKeyboardManagerSwift

class BaseViewController: UIViewController {
    static var identifier: String {
        return String(describing: self)
    }
    var isHideNavigationBar: Bool {
        return false
    }
    var isEnableResignOnTouchOutside: Bool {
        return true
    }
    var isEnableIQKeyboard: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isHideNavigationBar {
            navigationItem.hidesBackButton = true
        }
        navigationController?.navigationBar.barTintColor = UIColor.white.withAlphaComponent(0.9)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isHideNavigationBar {
            navigationController?.setNavigationBarHidden(true, animated: true)
        }
        if !isEnableIQKeyboard {
            IQKeyboardManager.shared.enable = false
        } else {
            IQKeyboardManager.shared.enable = true
        }
        if !isEnableResignOnTouchOutside {
            IQKeyboardManager.shared.shouldResignOnTouchOutside = false
        } else {
            IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        }
        
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isHideNavigationBar {
            navigationController?.setNavigationBarHidden(false, animated: true)
        }
        if !isEnableIQKeyboard {
            IQKeyboardManager.shared.enable = true
        } else {
            IQKeyboardManager.shared.enable = false
        }
        if !isEnableResignOnTouchOutside {
            IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        } else {
            IQKeyboardManager.shared.enable = false
        }
    }
}
