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
        // Add observer at change page
        NotificationCenter.default.addObserver(self, selector: #selector(self.defaultSegmentIndex(_:)), name: .defaultSegmentIndexKey, object: nil)
        layoutSegment()
        addGestureOnAvatar()
    }
    
    override func layoutSubviews() {
        avatarImageView.layer.cornerRadius = 60
        avatarImageView.clipsToBounds = true
    }
    
    @objc func defaultSegmentIndex(_ notification: NSNotification) {
        changePropertySegment.selectedSegmentIndex = 0
    }
    
    func layoutProfileHeader(avatar: UIImage, displayName: String) {
        avatarImageView.image = avatar
        displayNameLabel.text = displayName
    }
    private func addGestureOnAvatar() {
        // Avatar gesture
        let tapAvatarGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(avatarTapped(tapGestureRecognizer:)))
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView
            .addGestureRecognizer(tapAvatarGestureRecognizer)
    }
    
    private func layoutSegment() {
        changePropertySegment.setImage(UIImage.asset(.left_segment_property), forSegmentAt: 0)
        changePropertySegment.setImage(UIImage.asset(.right_segment_heart), forSegmentAt: 1)
        changePropertySegment.backgroundColor = UIColor.backgroundColor
        changePropertySegment.selectedSegmentIndex = 0
        changePropertySegment.selectedSegmentTintColor = UIColor.primary
        
        changePropertySegment.subviews.flatMap{ $0.subviews }.forEach { subview in
            if let imageView = subview as? UIImageView, imageView.frame.width > 5 {
                imageView.contentMode = .scaleAspectFill
                imageView.clipsToBounds = true
            }
        }
    }
    
    @objc private func avatarTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        NotificationCenter.default.post(name: .showEditAvatarViewKey, object: nil)
    }
    
    @IBAction func changeProfileProperty(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            NotificationCenter.default.post(name: .showUserPropertyKey, object: nil)
        } else {
            NotificationCenter.default.post(name: .showLikedPropertyKey, object: nil)
        }
    }
}
