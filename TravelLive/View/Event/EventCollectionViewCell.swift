//
//  EventCollectionViewCell.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/26.
//

import UIKit

class EventCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var eventImageView: UIImageView!
    let cornerRadius = 18.0
    let titleLabel = UILabel()
    let locationLabel = UILabel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        eventImageView.layer.addSublayer(getgradient())
        self.layer.cornerRadius = cornerRadius
    }
    
    func layoutCell(image: UIImage, title: String, location: String) {
        eventImageView.image = image
        eventImageView.addSubview(getTitleLabel(title: title))
        eventImageView.addSubview(getLocationLabel(title: location))
//        layoutSubviews()
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
    
    private func getLocationLabel(title: String) -> UILabel {
        locationLabel.frame = CGRect(x: cornerRadius, y: Double(eventImageView.bounds.maxY - 90), width: 280 - cornerRadius * 2, height: 30)
        locationLabel.text = title
        locationLabel.textColor = UIColor.lightGray
        locationLabel.font = locationLabel.font.withSize(16)
        locationLabel.numberOfLines = 1
        return locationLabel
    }
    
    private func getTitleLabel(title: String) -> UILabel {
        titleLabel.frame = CGRect(x: cornerRadius, y: Double(eventImageView.bounds.maxY - 60), width: 280 - cornerRadius * 2, height: 60)
        titleLabel.text = title
        titleLabel.textColor = UIColor.white
        titleLabel.font = titleLabel.font.withSize(18)
        titleLabel.numberOfLines = 2
        return titleLabel
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
