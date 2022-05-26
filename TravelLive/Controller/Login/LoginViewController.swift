//
//  LoginViewController.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/6.
//

import UIKit
import AuthenticationServices
import FirebaseAuth
import CryptoKit
import Toast_Swift
import RxSwift
import RxCocoa

class LoginViewController: UIViewController {
    
    // MARK: - Property
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
    private var checkButton = UIButton()
    private var isChecked = false
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.redirectNewPage(_:)), name: .redirectNewViewKey, object: nil)
        
        authorizationButton.isEnabled = false
        authorizationButton.addTarget(self, action: #selector(loginWithApple), for: .touchUpInside)
        checkButton.addTarget(self, action: #selector(checkBox), for: .touchUpInside)
        view.backgroundColor = UIColor.backgroundColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        createAnimation()
        addLogoView()
    }
    
    // MARK: - Component
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
        createCheckButton()
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
            [licenseLabel.leftAnchor.constraint(equalTo: checkButton.rightAnchor),
             licenseLabel.heightAnchor.constraint(equalToConstant: 30),
             licenseLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
             licenseLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor)]
        )
    }
    
    private func createCheckButton() {
        containerView.addSubview(checkButton)
        checkButton.translatesAutoresizingMaskIntoConstraints = false
        checkButton.setImage(UIImage.asset(.check)?.maskWithColor(color: UIColor.primary), for: .normal)
        checkButton.setImage(UIImage.asset(.checkbox)?.maskWithColor(color: UIColor.primary), for: .selected)
        
        NSLayoutConstraint.activate(
            [checkButton.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 5),
             checkButton.heightAnchor.constraint(equalToConstant: 25),
             checkButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
             checkButton.widthAnchor.constraint(equalToConstant: 25)]
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
                        LottieAnimationManager.shared.createlottieAnimation(name: self.animationArray[element], view: self.view, animationSpeed: 2, isRemove: true, location: CGRect(x: 0, y: 0, width: 200, height: 200))
                    case 1:
                        LottieAnimationManager.shared.createlottieAnimation(name: self.animationArray[element], view: self.view, animationSpeed: 2, isRemove: true, location: CGRect(x: Int(UIScreen.width) - 200, y: Int(UIScreen.height) / 4, width: 200, height: 200))
                    case 2:
                        LottieAnimationManager.shared.createlottieAnimation(name: self.animationArray[element], view: self.view, animationSpeed: 2, isRemove: true, location: CGRect(x: 0, y: Int(UIScreen.height) * 2 / 4, width: 200, height: 200))
                    case 3:
                        LottieAnimationManager.shared.createlottieAnimation(name: self.animationArray[element], view: self.view, animationSpeed: 2, isRemove: true, location: CGRect(x: Int(UIScreen.width) - 200, y: Int(UIScreen.height) * 3 / 4, width: 200, height: 200))
                    default:
                        break
                    }
                }
            }, onError: { _ in
                
            }, onCompleted: {
                if UserManager.shared.userID == "" {
                    self.createContainerView()
                    return
                } else {
                    self.showMainView()
                }
            }, onDisposed: {
                
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
    
    // MARK: - Target / IBAction
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
    
    @objc private func checkBox(_ sender: UIButton) {
        isChecked.toggle()
        
        sender.checkboxAnimation {
            if self.isChecked {
                self.authorizationButton.isEnabled = true
            } else {
                self.authorizationButton.isEnabled = false
                self.view.makeToast("必須接受這些規則方能登錄哦", duration: 0.5, position: .center)
            }
        }
    }
    
    // MARK: - Method
    
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
            let pullStreamingVC = UIStoryboard.pullStreaming.instantiateViewController(withIdentifier: "\(PullStreamingViewController.self)"
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
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
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
            
            guard let nonce = currentNonce else { return }
            guard let appleIDToken = appleIDCredential.identityToken else {
                self.view.makeToast(AuthText.noFound.text, duration: 0.5, position: .center)
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                self.view.makeToast(AuthText.noSequence.text, duration: 0.5, position: .center)
                return
            }
            
            let givenName = appleIDCredential.fullName?.givenName ?? ""
            let familyName = appleIDCredential.fullName?.familyName ?? ""
            fullName = givenName + " " + familyName
            
            // get user id、name
            // create Credential
            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
            
            // chain with Firebase Auth
            firebaseSignInWithApple(credential: credential)
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // login fail handle Error
        switch error {
        case ASAuthorizationError.canceled:
            self.view.makeToast(AuthText.cancel.text, duration: 0.5, position: .center)
        case ASAuthorizationError.failed:
            self.view.makeToast(AuthText.fail.text, duration: 0.5, position: .center)
        case ASAuthorizationError.invalidResponse:
            self.view.makeToast(AuthText.noResponse.text, duration: 0.5, position: .center)
        case ASAuthorizationError.notHandled:
            self.view.makeToast(AuthText.noHandle.text, duration: 0.5, position: .center)
        case ASAuthorizationError.unknown:
            self.view.makeToast(AuthText.noReason.text, duration: 0.5, position: .center)
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
    // chain with Firebase Auth by Credential
    func firebaseSignInWithApple(credential: AuthCredential) {
        Auth.auth().signIn(with: credential) { authResult, error in
            guard error == nil else {
                self.view.makeToast(AuthText.fail.text, duration: 0.5, position: .center)
                return
            }
            UserManager.shared.userID = (authResult?.user.uid)!
            self.getFirebaseUserInfo()
            self.showMainView()
        }
    }
    
    // Firebase get user info
    func getFirebaseUserInfo() {
        let currentUser = Auth.auth().currentUser
        let userid = currentUser?.uid ?? UserManager.shared.userID
        UserManager.shared.userID = userid
        ProfileProvider.shared.postUserInfo(userID: userid, name: fullName ?? UserManager.shared.userID)
    }
}
