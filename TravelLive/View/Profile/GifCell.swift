//
//  GifCell.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/22.
//

import UIKit

class GifCell: UICollectionViewCell {

    @IBOutlet weak var gifImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        gifImageView.backgroundColor = UIColor.primary
    }

}
