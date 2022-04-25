//
//  PlaceEventViewReuseCell.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/24.
//

import UIKit

class PlaceEventViewReuseCell: UITableViewCell {

    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func layoutCell(start: String, end: String) {
        titleLabel.text = "開始時間" + start
        contentLabel.text = "結束時間" + end
    }
}
