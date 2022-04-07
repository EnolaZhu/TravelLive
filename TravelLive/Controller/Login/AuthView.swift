//
//  AuthViewController.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/6.
//

import UIKit
import Firebase
import FirebaseAuth

class AuthView: UIView, NibOwnerLoadable {
    
    @IBOutlet weak var authTitleLabel: UILabel!
    @IBOutlet weak var loginWithAppleButton: UIButton!
    {
        didSet {
            loginWithAppleButton.configureButton(text: "Continue with Apple", imageName: "apple", imagePadding: 10, edgePadding: 10, button: loginWithAppleButton, backgroundColor: UIColor.white, textColor: UIColor.black)
        }
    }
    @IBOutlet weak var textLabel: UILabel! {
        didSet {
            textLabel.text = "Already have an account? "
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
    
    @IBAction func loginWithEmail(_ sender: UIButton) {
        
    }
}
