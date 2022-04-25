//
//  MessageCell.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/7.
//

import UIKit

class MessageCell: UITableViewCell {
    @IBOutlet weak var userNameLabel: UILabel! {
        didSet {
            userNameLabel.backgroundColor = UIColor.white
            userNameLabel.layer.cornerRadius = 8
            userNameLabel.layer.masksToBounds = (YESSTR != 0)
            userNameLabel.textColor = UIColor.black
        }
    }
    @IBOutlet weak var messageLabel: UILabel! {
        didSet {
            messageLabel.backgroundColor = UIColor.white
            messageLabel.layer.cornerRadius = 8
            messageLabel.layer.masksToBounds = (YESSTR != 0)
            messageLabel.textColor = UIColor.black
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = UITableViewCell.SelectionStyle.none
        self.backgroundColor = UIColor.clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
