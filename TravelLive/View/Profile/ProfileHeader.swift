//
//  ProfileHeader.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/23.
//

import UIKit

class ProfileHeader: UICollectionReusableView {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var changePropertySegment: UISegmentedControl!
    @IBOutlet weak var displayNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        avatarImageView.layer.borderWidth = 1.0
        avatarImageView.layer.cornerRadius = 60
        avatarImageView.clipsToBounds = true
    }
    
    func layoutProfileHeader(avatar: UIImage, displayName: String) {
        
        avatarImageView.image = avatar
        displayNameLabel.text = displayName
    }
    
    @IBAction func changeProfileProperty(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            NotificationCenter.default.post(name: .showUserPropertyKey, object: nil)
        } else {
            NotificationCenter.default.post(name: .showLikedPropertyKey, object: nil)
        }
    }
}
