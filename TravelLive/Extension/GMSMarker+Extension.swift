//
//  GMSMarker+Extension.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/11.
//

import GoogleMaps
import CoreLocation

extension GMSMarker {
    func setIconSize(scaledToSize newSize: CGSize) {
        UIGraphicsBeginImageContext(newSize)
        icon?.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        icon = newImage
    }
}
