//
//  DetailViewCommentCell.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/19.
//

import UIKit

class DetailViewCommentCell: UITableViewCell {

    @IBOutlet weak var reviewerAvatarImage: UIImageView!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var reviewerName: UILabel!
    @IBOutlet weak var reviewTimeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setUpCell()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    private func setUpCell() {
        self.selectionStyle = .none
        reviewerAvatarImage.makeRounded()
        reviewerName.font = UIFont.boldSystemFont(ofSize: 14.0)
        commentLabel.font = commentLabel.font.withSize(14.0)
    }
    
    func layoutCell(name: String, comment: String, avatar: UIImage, time: String) {
        let date = Date(timeIntervalSince1970: Double(time) ?? 0)
        reviewerName.text = name
        commentLabel.text = comment
        reviewerAvatarImage.image = avatar
        reviewTimeLabel.text = "\(date.currentUTCTimeZoneDate)"
    }
}
