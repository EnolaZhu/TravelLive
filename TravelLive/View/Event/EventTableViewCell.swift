//
//  EventTableViewCell.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/26.
//

import UIKit

class EventTableViewCell: UITableViewCell {
    
    override var frame: CGRect {
        get {
            return super.frame
        }
        set {
            var frame = newValue

            frame.origin.x = 10

            frame.size.width -= 2 * frame.origin.x
            frame.size.height -= 2 * frame.origin.x

            self.layer.masksToBounds = true
            self.layer.cornerRadius = 8.0

            super.frame = frame
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
