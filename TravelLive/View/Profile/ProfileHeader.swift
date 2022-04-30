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
    @IBOutlet weak var editAvatarButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Add observer at change page
        NotificationCenter.default.addObserver(self, selector: #selector(self.defaultSegmentIndex(_:)), name: .defaultSegmentIndexKey, object: nil)
        changePropertySegment.backgroundColor = UIColor.white
        changePropertySegment.selectedSegmentIndex = 0
        changePropertySegment.selectedSegmentTintColor = UIColor.primary
        
        editAvatarButton.addTarget(self, action: #selector(changeAvatar), for: .touchUpInside)
    }
    
    override func layoutSubviews() {
        avatarImageView.layer.cornerRadius = 60
        avatarImageView.clipsToBounds = true
    }
    
    @objc func defaultSegmentIndex(_ notification: NSNotification) {
        changePropertySegment.selectedSegmentIndex = 0
    }
    
    @objc func changeAvatar(_ sender: UIButton) {
            NotificationCenter.default.post(name: .showEditAvatarViewKey, object: nil)
        }
    
    func layoutProfileHeader(avatar: UIImage, displayName: String) {
        avatarImageView.image = avatar
        displayNameLabel.text = displayName
    }
    
    func layoutSegment(firstSegmentTitle: String, secondSegmentTitle: String) {
        changePropertySegment.setTitle(firstSegmentTitle, forSegmentAt: 0)
        changePropertySegment.setTitle(secondSegmentTitle, forSegmentAt: 1)
    }
    
    @IBAction func changeProfileProperty(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            NotificationCenter.default.post(name: .showUserPropertyKey, object: nil)
        } else {
            NotificationCenter.default.post(name: .showLikedPropertyKey, object: nil)
        }
    }
}
