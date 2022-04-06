//
//  AuthViewController.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/6.
//

import UIKit


class AuthView: UIView, NibOwnerLoadable {
    
    @IBOutlet weak var authTitleLabel: UILabel!
    @IBOutlet weak var loginWithAppleButton: UIButton!
    // 修改
    @IBOutlet weak var loginWithNativeButton: UIButton!
    @IBOutlet weak var textLabel: UILabel! {
        didSet {
            textLabel.text = "Already have an account? "
        }
    }
    @IBOutlet weak var loginButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
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
    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//    }
    
}
