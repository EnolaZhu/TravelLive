//
//  MapViewController.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/5.
//

import UIKit
import GoogleMaps
import CoreLocation

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: GMSMapView!
    let marker = GMSMarker()

    // I have taken a pin image which is a custom image
    let markerImage = UIImage(named: "Icons_map")!.withRenderingMode(.alwaysTemplate)
    override func viewDidLoad() {
        super.viewDidLoad()
        let camera = GMSCameraPosition(latitude: 25.038806, longitude: 121.5573862, zoom: 15.81)
        mapView.camera = camera
        makeCustomMarker()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func makeCustomMarker() {
        mapView.selectedMarker = marker
        marker.position = CLLocationCoordinate2D(latitude: 25.038806, longitude: 121.5573862)
        marker.map = mapView
        let pinImage = UIImage(named: "userImage")
        let size = CGSize(width: 88, height: 88)
        UIGraphicsBeginImageContext(size)
        pinImage!.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        marker.icon = resizedImage?.circularImage(44)

        marker.map = self.mapView
    }
}
