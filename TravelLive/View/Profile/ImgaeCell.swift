//
//  ImgaeCell.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/22.
//

import UIKit

class ImgaeCell: UICollectionViewCell {

    @IBOutlet weak var propertyImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        propertyImageView.backgroundColor = UIColor.blue
    }

}
