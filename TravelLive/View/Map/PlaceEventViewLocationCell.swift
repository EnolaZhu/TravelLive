//
//  PlaceEventViewLocationCell.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/24.
//

import UIKit

class PlaceEventViewLocationCell: UITableViewCell {

    @IBOutlet weak var locationTitleLabel: UILabel!
    @IBOutlet weak var detailLocationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = UIColor.backgroundColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func layoutCell(title: String, detail: String) {
        locationTitleLabel.text = title
        detailLocationLabel.text = detail
    }
}
