//
//  ProfileCollectionCell.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/23.
//

import UIKit

class ProfileCollectionCell: UICollectionViewCell {
    @IBOutlet weak var profileImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        profileImageView.image?.circularImage(50)
        profileImageView.contentMode = .scaleAspectFit
    }
    
    func layoutCell(image: UIImage) {
        profileImageView.image = image
    }
}
