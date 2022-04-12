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
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Location
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        mapView.delegate = self
        fetchData()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func fetchData() {
        pullStreamingProvider.fetchStreamerInfo(completion: { [weak self] result in
            
            switch result {
            case .success(let user):
                self?.streamerData = user
                print("\(String(describing: self?.streamerData))")
                guard let streamerData = self?.streamerData else { return }
                for index in 0...streamerData.data.count - 1 {
                    self?.getImage(index: index, latitude: Float(streamerData.data[index].latitude), longitude: Float(streamerData.data[index].longitude), data: streamerData.data[index])
                }
            case .failure:
                print("Failed")
            }
        })
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

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        //        longitude = locValue.longitude
        //        latitude = locValue.latitude
        let camera = GMSCameraPosition(latitude: locValue.latitude, longitude: locValue.longitude, zoom: 15.81)
        mapView.camera = camera
    }
}
