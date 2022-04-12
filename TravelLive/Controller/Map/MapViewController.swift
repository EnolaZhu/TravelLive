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
    
    let pullStreamingProvider = PullStreamingProvider()
    var avater = UIImage()
    var streamerData: StreamerDataObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        pullStreamingProvider.fetchStreamerInfo { [weak self] data in
        //            print("\(data)")
        //        }
        pullStreamingProvider.request { [weak self] result in
            self?.streamerData = result
            print("\(String(describing: self?.streamerData))")
            guard let streamerData = self?.streamerData else { return }
            for index in 0...streamerData.data.count - 1 {
                self?.getImage(index: index, latitude: Float(streamerData.data[index].latitude), longitude: Float(streamerData.data[index].longitude), data: streamerData.data[index])
            }
        }
        // Hard code
        let camera = GMSCameraPosition(latitude: CLLocationDegrees(25.038806), longitude: CLLocationDegrees(121.5573862), zoom: 15.81)
        mapView.camera = camera
        mapView.delegate = self
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getImage(index: Int, latitude: Float, longitude: Float, data: Streamer) {
        MarkerManager.shared.fetchStreamerImage(imageUrl: data.storageBucket, avater: data.avatar) { image in
            self.makeCustomMarker(latitude: latitude, longitude: longitude, pinImage: image)
        }
    }
    
    func makeCustomMarker(latitude: Float, longitude: Float, pinImage: UIImage) {
        let marker = GMSMarker()
        mapView.selectedMarker = marker
        marker.position = CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
        marker.map = mapView
        let size = CGSize(width: 88, height: 88)
        UIGraphicsBeginImageContext(size)
        pinImage.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
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
