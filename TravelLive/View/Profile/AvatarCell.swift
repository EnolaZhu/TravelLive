//
//  AvatarCell.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/22.
//

import UIKit

class AvatarCell: UICollectionViewCell {

    @IBOutlet weak var editAvatarButton: UIButton!
    @IBOutlet weak var avatarImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        avatarImageView.image?.circularImage(70)
    }
    
    func layoutCell() {
        avatarImageView.image = UIImage(named: "avatar")
    }

}
