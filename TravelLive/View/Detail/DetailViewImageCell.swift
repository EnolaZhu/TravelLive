//
//  DetailViewImageCell.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/19.
//

import UIKit

class DetailViewImageCell: UITableViewCell {

    @IBOutlet weak var userUploadImageView: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var reportButton: UIButton!
    @IBOutlet weak var loveButton: UIButton!
    @IBOutlet weak var userAvatarimage: UIImageView!
    @IBOutlet weak var shareButton: UIButton!
    
    var propertyId: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
        userAvatarimage.makeRounded()
        setUpButtonBasicColor(shareButton, UIImage.asset(.share) ?? UIImage(), color: UIColor.primary)
        setUpButtonBasicColor(loveButton, UIImage.asset(.emptyHeart) ?? UIImage(), color: UIColor.primary)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Add heart button observer
        NotificationCenter.default.addObserver(self, selector: #selector(self.changeHeart(_:)), name: .changeLoveButtonKey, object: nil)
    }
    
    func layoutCell(mainImage: UIImage, propertyId: String, isLiked: Bool, imageOwnerName: String, avatar: UIImage) {
        userUploadImageView.contentMode = .scaleAspectFill
        userUploadImageView.image = mainImage
        userAvatarimage.image = avatar.circularImage(22)
        userName.text = imageOwnerName
        
        if isLiked {
            loveButton.setImage(UIImage.asset(.theheart), for: .normal)
        } 
        self.propertyId = propertyId
    }
    
    @objc func changeHeart(_ notification: NSNotification) {
        if loveButton.hasImage(named: "theheart", for: .normal) {
            return
            
        } else {
            DetailDataProvider.shared.postLike(propertyId: propertyId ?? "", userId: userID, isLiked: true)
            loveButton.setImage(UIImage.asset(.theheart), for: .normal)
        }
    }
}
