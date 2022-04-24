//
//  ProfileHeader.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/23.
//

import UIKit

class ProfileHeader: UICollectionReusableView {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var profilePropertyButton: UIButton!
    @IBOutlet weak var likedPropertyButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func layoutProfileHeader(avatar: UIImage) {
        avatarImageView.image = avatar.circularImage(avatarImageView.frame.width)
    }
}
