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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
        userAvatarimage.makeRounded()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func layoutCell(mainImage: UIImage) {
        userUploadImageView.contentMode = .scaleAspectFill
        userUploadImageView.image = mainImage
        userAvatarimage.image = UIImage(named: "avatar")?.circularImage(22)
        userName.text = "Enola"
    }
}
