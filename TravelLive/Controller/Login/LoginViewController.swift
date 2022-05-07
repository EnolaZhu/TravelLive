//
//  LoginViewController.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/6.
//

import UIKit
import AuthenticationServices
import FirebaseAuth // 用來與 Firebase Auth 進行串接用的
import CryptoKit // 用來產生隨機字串 (Nonce) 的
import Toast_Swift

class LoginViewController: UIViewController {
    @IBOutlet weak var authView: AuthView!
    // swiftlint:disable trailing_whitespace
    fileprivate var currentNonce: String?
    private var fullName: String?
    private let logoView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.redirectNewPage(_:)), name: .redirectNewViewKey, object: nil)
        
        authView.authorizationButton.addTarget(self, action: #selector(loginWithApple), for: .touchUpInside)
        view.backgroundColor = UIColor.backgroundColor
        
        if userID == "" {
            return
        } else {
            showMainView()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        addLogoView()
    }
    
    private func login() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    @objc func redirectNewPage(_ notification: NSNotification) {
        if notification.userInfo?.keys.contains("live") != nil {
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
        let mainTabVC = UIStoryboard.main.instantiateViewController(
            withIdentifier: String(describing: TabBarViewController.self)
        )
        guard let tabVc = mainTabVC as? TabBarViewController else { return }
        tabVc.modalPresentationStyle = .fullScreen
        show(tabVc, sender: nil)
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return result
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        return hashString
    }
    
    private func addLogoView() {
        
        view.addSubview(logoView)
        logoView.translatesAutoresizingMaskIntoConstraints = false
        logoView.backgroundColor = .red
        logoView.image = UIImage.asset(.Logo)
        NSLayoutConstraint.activate(
            [logoView.widthAnchor.constraint(equalToConstant: 240),
             logoView.heightAnchor.constraint(equalToConstant: 36),
             logoView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
             logoView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ]
        )
    }
}

extension LoginViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            
            
            guard let appleIDToken = appleIDCredential.identityToken else {
                self.view.makeToast("無法找到識別令牌", duration: 0.5, position: .center)
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                self.view.makeToast("無法序列化識別令牌", duration: 0.5, position: .center)
                return
            }
            
            let givenName = appleIDCredential.fullName?.givenName ?? ""
            let familyName = appleIDCredential.fullName?.familyName ?? ""
            fullName = givenName + " " + familyName
            
            // 取得使用者的 id、name
            // 產生 Apple ID 登入的 Credential
            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
            
            // 與 Firebase Auth 進行串接
            firebaseSignInWithApple(credential: credential)
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // 登入失敗，處理 Error
        switch error {
        case ASAuthorizationError.canceled:
            self.view.makeToast("取消登入", duration: 0.5, position: .center)
        case ASAuthorizationError.failed:
            self.view.makeToast("授權請求失敗", duration: 0.5, position: .center)
        case ASAuthorizationError.invalidResponse:
            self.view.makeToast("授權請求無回應", duration: 0.5, position: .center)
        case ASAuthorizationError.notHandled:
            self.view.makeToast("授權請求未處理", duration: 0.5, position: .center)
        case ASAuthorizationError.unknown:
            self.view.makeToast("授權失敗，原因不知", duration: 0.5, position: .center)
        default:
            break
        }
    }
}

extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
}

extension LoginViewController {
    // MARK: - 透過 Credential 與 Firebase Auth 串接
    func firebaseSignInWithApple(credential: AuthCredential) {
        Auth.auth().signIn(with: credential) { authResult, error in
            guard error == nil else {
                self.view.makeToast("授權失敗", duration: 0.5, position: .center)
                return
            }
            userID = (authResult?.user.uid)!
            self.getFirebaseUserInfo()
            self.showMainView()
        }
    }
    
    // MARK: - Firebase 取得登入使用者的資訊
    func getFirebaseUserInfo() {
        let currentUser = Auth.auth().currentUser
        let userid = currentUser?.uid ?? userID
        userID = userid
        ProfileProvider.shared.postUserInfo(userID: userid, name: fullName ?? userID)
    }
}
