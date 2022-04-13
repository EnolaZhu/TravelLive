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
    var specificStreamer: [Streamer]?
    var url = String()
//    var longitude = CLLocationDegrees()
//    var latitude = CLLocationDegrees()
    
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
        let camera = GMSCameraPosition(latitude: 25.0552943, longitude: 121.6340554, zoom: 15.81)
                mapView.camera = camera
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//
//    }
    
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
        let markerLatitude = Float(marker.position.latitude)
        let markerLongitude = Float(marker.position.longitude)
        
        specificStreamer = self.streamerData?.data.filter({
            Float($0.longitude) == markerLongitude && Float($0.latitude) == markerLatitude
        })
        print("\(String(describing: specificStreamer?.first?.pullUrl))")
        
        guard let url = specificStreamer?.first?.pullUrl else { return false }
        self.url = url
        createLiveRoom(streamerUrl: url)
        //        25.055294
        return true
    }
    
    func createLiveRoom(streamerUrl: String) {
        let pullStreamingVC = UIStoryboard.pullStreaming.instantiateViewController(withIdentifier: String(describing: PullStreamingViewController.self)
        )
        guard let pullVC = pullStreamingVC as? PullStreamingViewController else { return }
        pullVC.streamingUrl = url
        print("\(pullVC.streamingUrl)")
        show(pullVC, sender: nil)
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
//                longitude = locValue.longitude
//                latitude = locValue.latitude
//
    }
    
}
