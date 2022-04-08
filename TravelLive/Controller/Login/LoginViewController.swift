//
//  LoginViewController.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/6.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var authView: AuthView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        authView.loginWithAppleButton.addTarget(self, action: #selector(loginWithApple), for: .touchUpInside)
    }
    
    @objc func loginWithApple() {
        let mainTabVC = UIStoryboard.main.instantiateViewController(withIdentifier:
        String(describing: TabBarViewController.self))
        guard let vc = mainTabVC as? TabBarViewController else { return }
        show(vc, sender: nil)
    }
}

