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
    }
    
    func layoutCell(image: UIImage) {
        profileImageView.image = image
    }
}
