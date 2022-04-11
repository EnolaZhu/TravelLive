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
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        makeCustomMarker(latitude: 25.038806, longitude: 121.5573862)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func makeCustomMarker(latitude: Float, longitude: Float) {
        let camera = GMSCameraPosition(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude), zoom: 15.81)
        mapView.camera = camera
        mapView.selectedMarker = marker
        marker.position = CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
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

extension MapViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        let pullStreamingVC = UIStoryboard.pullStreaming.instantiateViewController(withIdentifier: String(describing: PullStreamingViewController.self)
        )
        guard let pullVC = pullStreamingVC as? PullStreamingViewController else { return false }
        show(pullVC, sender: nil)
        return true
    }
}
