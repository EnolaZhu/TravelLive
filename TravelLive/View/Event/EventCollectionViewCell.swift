//
//  EventCollectionViewCell.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/26.
//

import UIKit

class EventCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    let cornerRadius = 18.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        eventImageView.layer.addSublayer(getgradient())
        self.layer.cornerRadius = cornerRadius
    }
    
    func layoutCell(image: UIImage, title: String, location: String) {
        eventImageView.image = image
        titleLabel.text = location
        locationLabel.text = title
        titleLabel.textColor = UIColor.white
        locationLabel.textColor = UIColor.white
    }
    
    private func getgradient() -> CAGradientLayer {
        let gradient = CAGradientLayer()
        // gradient
        gradient.frame = CGRect(x: 0, y: 0, width: UIScreen.width, height: 300)
        gradient.colors = [
            UIColor.clear.cgColor,
            UIColor.clear.cgColor,
            CGColor(
                srgbRed: 0.2,
                green: 0.0,
                blue: 0.0,
                alpha: 1.0
            )
        ]
        gradient.locations = [0, 0.35, 1]
        return gradient
    }
}
