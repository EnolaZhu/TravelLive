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
    var longitude: CLLocationDegrees?
    var latitude: CLLocationDegrees?
    var currentLocation: CLLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Location
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        
        locationManager.delegate = self
        longitude = locationManager.location?.coordinate.longitude
        latitude = locationManager.location?.coordinate.latitude
        if CLLocationManager.authorizationStatus() != .denied {
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            fetchData()
        } else {
            DispatchQueue.main.async() {
                self.fetchData()
            }
        }
        
        if mapView == nil {
            return
        } else {
            mapView.delegate = self
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        // Hide the Navigation Bar
        mapView.clear()
        fetchData()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        mapView.clear()
        // Show the Navigation Bar
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func fetchData() {
        pullStreamingProvider.fetchStreamerInfo(latitude: latitude ?? Double(), longitude: longitude ?? Double()) { [weak self] result in
            switch result {
                
            case .success(let user):
                self?.streamerData = user
                guard let streamerData = self?.streamerData else { return }
                
                if self?.mapView.camera == nil {
                    let camera = GMSCameraPosition(latitude: streamerData.nearLiveLatitude ?? Double(), longitude: streamerData.nearLiveLongitude ?? Double(), zoom: 15.81)
                    self?.mapView.camera = camera
                    
                } else {
                    let location = GMSCameraPosition(latitude: streamerData.nearLiveLatitude ?? Double(), longitude: streamerData.nearLiveLongitude ?? Double(), zoom: 15.81)
                    self?.mapView.animate(to: location)
                }
                
                for index in 0...streamerData.data.count - 1 {
                    self?.getImage(index: index, latitude: Float(streamerData.data[index].latitude), longitude: Float(streamerData.data[index].longitude), data: streamerData.data[index])
                }
                
            case .failure:
                print("Failed")
            }
        }
    }
    
    func getImage(index: Int, latitude: Float, longitude: Float, data: Streamer) {
        ImageManager.shared.fetchStorageImage(imageUrl: data.avatar) { image in
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
        return true
    }
    
    func createLiveRoom(streamerUrl: String) {
        let pullStreamingVC = UIStoryboard.pullStreaming.instantiateViewController(withIdentifier: String(describing: PullStreamingViewController.self)
        )
        guard let pullVC = pullStreamingVC as? PullStreamingViewController else { return }
        pullVC.streamingUrl = url
        show(pullVC, sender: nil)
    }
}

extension MapViewController: CLLocationManagerDelegate {
    // 半秒一次
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        longitude = locValue.longitude
        latitude = locValue.latitude
    }
}
