//
//  AuthViewController.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/6.
//

import UIKit
import Firebase
import FirebaseAuth
import AuthenticationServices

class AuthView: UIView, NibOwnerLoadable {
    // swiftlint:disable opening_brace
    // swiftlint:disable line_length
    @IBOutlet weak var loginWithAppleView: UIView!
    @IBOutlet weak var textLabel: UILabel!
    
    let authorizationButton = ASAuthorizationAppleIDButton(type: .signIn, style: .white)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setUpLoginButton()
        loginWithAppleView.layer.cornerRadius = 40
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        customInit()
    }
    
    private func customInit() {
        loadNibContent()
    }
    
    private func setUpLoginButton() {
        loginWithAppleView.addSubview(authorizationButton)
        authorizationButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            authorizationButton.topAnchor.constraint(equalTo: loginWithAppleView.topAnchor),
            authorizationButton.trailingAnchor.constraint(equalTo: loginWithAppleView.trailingAnchor),
            authorizationButton.bottomAnchor.constraint(equalTo: loginWithAppleView.bottomAnchor),
            authorizationButton.leadingAnchor.constraint(equalTo: loginWithAppleView.leadingAnchor)
        ])
    }
}
