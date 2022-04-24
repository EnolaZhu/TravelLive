//
//  LoginViewController.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/6.
//

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var authView: AuthView!
    // swiftlint:disable trailing_whitespace
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.redirectNewPage(_:)), name: .redirectNewViewKey, object: nil)
        
        authView.loginWithAppleButton.addTarget(self, action: #selector(loginWithApple), for: .touchUpInside)
    }
    
    @objc func redirectNewPage(_ notification: NSNotification) {
        if ((notification.userInfo?.keys.contains("live")) != nil) {
            let pullStreamingVC = UIStoryboard.pullStreaming.instantiateViewController(withIdentifier: String(describing: PullStreamingViewController.self)
            )
            
            guard let pullVC = pullStreamingVC as? PullStreamingViewController else { return }
            pullVC.streamingUrl = "\(notification.userInfo?["live"] ?? "")"
            show(pullVC, sender: nil)
        }
    }
    
    @objc func loginWithApple() {
        let mainTabVC = UIStoryboard.main.instantiateViewController(withIdentifier:
        String(describing: TabBarViewController.self))
        guard let tabVc = mainTabVC as? TabBarViewController else { return }
        show(tabVc, sender: nil)
    }
}
