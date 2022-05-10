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
import RxSwift
import RxCocoa

class LoginViewController: UIViewController {
    // swiftlint:disable trailing_whitespace
    fileprivate var currentNonce: String?
    private var fullName: String?
    private let logoView = UIImageView()
    private let animationArray = ["splash_map", "splash_camera", "splash_airplane", "splash_compass"]
    private let lastAnimationDuration = 1500
    private let emitAnimationInterval = 300
    private let disposeBag = DisposeBag()
    private let authorizationButton = ASAuthorizationAppleIDButton(type: .signIn, style: .white)
    private let containerView = UIView()
    private let licenseLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.redirectNewPage(_:)), name: .redirectNewViewKey, object: nil)
        
        self.authorizationButton.addTarget(self, action: #selector(loginWithApple), for: .touchUpInside)
        view.backgroundColor = UIColor.backgroundColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        createAnimation()
        addLogoView()
    }
    
    private func createContainerView() {
        view.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = UIColor.clear
        
        NSLayoutConstraint.activate(
            [containerView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 40),
             containerView.heightAnchor.constraint(equalToConstant: 100),
             containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -155),
             containerView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -40)]
        )
        createLoginButton()
        createLisencelabel()
    }
    
    private func createLoginButton() {
        containerView.addSubview(authorizationButton)
        authorizationButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate(
            [authorizationButton.leftAnchor.constraint(equalTo: containerView.leftAnchor),
             authorizationButton.heightAnchor.constraint(equalToConstant: 60),
             authorizationButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -30),
             authorizationButton.rightAnchor.constraint(equalTo: containerView.rightAnchor)]
        )
    }
    
    private func createLisencelabel() {
        containerView.addSubview(licenseLabel)
        licenseLabel.translatesAutoresizingMaskIntoConstraints = false
        setUpTextLabel()
        licenseLabel.backgroundColor = UIColor.clear
        licenseLabel.font = licenseLabel.font.withSize(12)
        
        NSLayoutConstraint.activate(
            [licenseLabel.leftAnchor.constraint(equalTo: containerView.leftAnchor),
             licenseLabel.heightAnchor.constraint(equalToConstant: 30),
             licenseLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
             licenseLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor)]
        )
    }
    
    private func createAnimation() {
        Observable<Int>.interval(.milliseconds(emitAnimationInterval), scheduler: MainScheduler.instance)
            .delay(.milliseconds(600), scheduler: MainScheduler.instance)
            .take(animationArray.count + lastAnimationDuration / emitAnimationInterval)
            .subscribe(onNext: { element in
                if element < self.animationArray.count {
                    switch element {
                    case 0:
                        LottieAnimationManager.shared.createlottieAnimation(name: self.animationArray[element], view: self.view, animationSpeed: 2, isRemove: true, theX: 0, theY: 0, width: 200, height: 200)
                    case 1:
                        LottieAnimationManager.shared.createlottieAnimation(name: self.animationArray[element], view: self.view, animationSpeed: 2, isRemove: true, theX: Int(UIScreen.width) - 200, theY: Int(UIScreen.height) / 4, width: 200, height: 200)
                    case 2:
                        LottieAnimationManager.shared.createlottieAnimation(name: self.animationArray[element], view: self.view, animationSpeed: 2, isRemove: true, theX: 0, theY: Int(UIScreen.height) * 2 / 4, width: 200, height: 200)
                    case 3:
                        LottieAnimationManager.shared.createlottieAnimation(name: self.animationArray[element], view: self.view, animationSpeed: 2, isRemove: true, theX: Int(UIScreen.width) - 200, theY: Int(UIScreen.height) * 3 / 4, width: 200, height: 200)
                    default:
                        break
                    }
                }
            }, onError: { error in
                print(error)
            }, onCompleted: {
                if userID == "" {
                    self.createContainerView()
                    return
                } else {
                    self.showMainView()
                }
            }, onDisposed: {
                print("observableInterval onDisposed")
            })
            .disposed(by: disposeBag)
    }
    
    private func setUpTextLabel() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapLabel(_:)))
        licenseLabel.addGestureRecognizer(tap)
        licenseLabel.isUserInteractionEnabled = true
        
        let stringValue = "註冊等同於接受隱私權政策和 Apple 標準許可"
        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: stringValue)
        attributedString.setColor(color: UIColor.primary, forText: "隱私權政策")
        attributedString.setColor(color: UIColor.primary, forText: "Apple 標準許可")
        licenseLabel.attributedText = attributedString
    }
    
    @objc private func tapLabel(_ gesture: UITapGestureRecognizer) {
        guard let text = licenseLabel.text else { return }
        let privacyRange = (text as NSString).range(of: "隱私權政策")
        let standardRange = (text as NSString).range(of: " Apple 標準許可")
        let webVC = WebViewController()
        
        if gesture.didTapAttributedTextInLabel(label: licenseLabel, inRange: privacyRange) {
            webVC.url = LoginUrlString.privacyUrl.rawValue
        } else if gesture.didTapAttributedTextInLabel(label: licenseLabel, inRange: standardRange) {
            webVC.url = LoginUrlString.standardLicense.rawValue
        } else {
            return
        }
        self.present(webVC, animated: true, completion: nil)
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

enum LoginUrlString: String {
    case privacyUrl = "https://firebasestorage.googleapis.com/v0/b/travellive-webplayer/o/Privacy%20Policy.html?alt=media&token=f6de7d54-111d-4a5d-9aed-d54e7505c6b2"
    case standardLicense = "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/"
}
