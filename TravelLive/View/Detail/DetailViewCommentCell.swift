//
//  DetailViewCommentCell.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/19.
//

import UIKit

class DetailViewCommentCell: UITableViewCell {

    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var reviewerName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func layoutCell(name: String, comment: String) {
        reviewerName.text = name
        commentLabel.text = comment
    }
}
