//
//  AuthViewController.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/6.
//

import UIKit
import Firebase
import FirebaseAuth

enum AuthText: String {
    case appleButtonText = "Continue with Apple"
    case textLabel = "Already have an account? "
}

class AuthView: UIView, NibOwnerLoadable {
    // swiftlint:disable opening_brace
    // swiftlint:disable line_length
    @IBOutlet weak var authTitleLabel: UILabel!
    @IBOutlet weak var loginWithAppleButton: UIButton!
    {
        didSet {
        loginWithAppleButton.configureButton(text: AuthText.appleButtonText.rawValue, image: UIImage.asset(.apple) ?? UIImage(),
        imagePadding: 10, edgePadding: 10, button: loginWithAppleButton, backgroundColor: UIColor.white, textColor: UIColor.black)
        }
    }
    @IBOutlet weak var textLabel: UILabel! {
        didSet {
            textLabel.text = AuthText.textLabel.rawValue
        }
    }
    @IBOutlet weak var loginButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        loginWithAppleButton.clipsToBounds = true
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
}
