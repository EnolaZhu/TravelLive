//
//  PlaceEventViewMapCell.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/5/4.
//

import UIKit
import GoogleMaps

class PlaceEventViewMapCell: UITableViewCell {
    @IBOutlet weak var mapView: GMSMapView!
    let longitude = CLLocationDegrees()
    let latitude = CLLocationDegrees()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
