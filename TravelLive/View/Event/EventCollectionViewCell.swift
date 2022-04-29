//
//  EventCollectionViewCell.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/26.
//

import UIKit

class EventCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var eventImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.layer.cornerRadius = 18
    }
    
//    override var isSelected: Bool {
//        didSet {
//            if self.isSelected {
//                self.layer.borderColor = UIColor.primary.cgColor
//                self.layer.borderWidth = 5
//            } else {
//                self.layer.borderColor = UIColor.white.cgColor
//                self.layer.borderWidth = 5
//            }
//        }
//    }
}
