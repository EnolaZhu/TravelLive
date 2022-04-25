//
//  TitleView.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/23.
//

import UIKit

class TitleView: UICollectionReusableView {
    @IBOutlet weak var eventTitleLbl: UILabel!
    static let reuseIdentifier = "EventTitleView"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
