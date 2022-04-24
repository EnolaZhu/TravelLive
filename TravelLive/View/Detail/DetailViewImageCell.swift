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
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
        userAvatarimage.makeRounded()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Add heart button observer
        NotificationCenter.default.addObserver(self, selector: #selector(self.changeHeart(_:)), name: .changeLoveButtonKey, object: nil)
    }
    
    func layoutCell(mainImage: UIImage) {
        userUploadImageView.contentMode = .scaleAspectFill
        userUploadImageView.image = mainImage
        userAvatarimage.image = UIImage(named: "avatar")?.circularImage(22)
        userName.text = "Enola"
    }
    
    @objc func changeHeart(_ notification: NSNotification) {
        if loveButton.hasImage(named: "theheart", for: .normal) {
            return
            
        } else {
            DetailDataProvider.shared.postLike(propertyId: "Enola_1650378092481000_0", userId: "Enola", isLiked: true)
            loveButton.setImage(UIImage.asset(.theheart), for: .normal)
        }
    }
}
