//
//  LoginViewController.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/6.
//

import UIKit
import AuthenticationServices

class LoginViewController: UIViewController {
    @IBOutlet weak var authView: AuthView!
    // swiftlint:disable trailing_whitespace
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.redirectNewPage(_:)), name: .redirectNewViewKey, object: nil)
        
        authView.loginWithAppleButton.addTarget(self, action: #selector(loginWithApple), for: .touchUpInside)
    }
    
    func login() {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.performRequests()
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
        login()
    }
    
    private func showMainView() {
    let mainTabVC = UIStoryboard.main.instantiateViewController(withIdentifier:
                                                                    String(describing: TabBarViewController.self))
    guard let tabVc = mainTabVC as? TabBarViewController else { return }
    show(tabVc, sender: nil)
    }
}

extension LoginViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let userId = credential.user
            let fullname = credential.fullName
            let email = credential.email
            let idToken = credential.identityToken
            print("\(userId)")
            print("\(fullname)")
            print("\(email)")
            print("\(idToken)")
            guard let idToken = credential.identityToken else { return }
            showMainView()
            //            print("\(data: idToken, encoding: .utf8)")
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    // Handle error.
    }
}
