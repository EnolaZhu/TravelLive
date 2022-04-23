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
    
    let mapDataProvider = MapDataProvider()
    var avater = UIImage()
    var streamerData: StreamerDataObject?
    var placeData: PlaceDataObject?
    var eventData: EventDataObject?
    let locationManager = CLLocationManager()
    var specificStreamer: [Streamer]?
    var url = String()
    var longitude: CLLocationDegrees?
    var latitude: CLLocationDegrees?
    var currentLocation: CLLocation!
    override func viewDidLoad() {
        super.viewDidLoad()
        // fake button
        let placeButton = UIButton(frame: CGRect(x: UIScreen.width - 120, y: UIScreen.height - 430, width: 88, height: 88))
        placeButton.tintColor = UIColor.primary
        placeButton.setImage(UIImage.asset(.plus), for: UIControl.State())
        
        let eventButton = UIButton(frame: CGRect(x: UIScreen.width - 120, y: UIScreen.height - 230, width: 88, height: 88))
        eventButton.setTitle("Event", for: .normal)
        
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
        mapView.delegate = self
        
        placeButton.addTarget(self, action: #selector(getPlaceData), for: .touchUpInside)
        eventButton.addTarget(self, action: #selector(getEventData), for: .touchUpInside)
        view.addSubview(placeButton)
        view.addSubview(eventButton)
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
        mapDataProvider.fetchStreamerInfo(latitude: latitude ?? Double(), longitude: longitude ?? Double()) { [weak self] result in
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
    
    @objc func getEventData(_ sender: UIButton) {
        mapDataProvider.fetchEventInfo(latitude: latitude ?? Double(), longitude: longitude ?? Double()) { [weak self] result in
            switch result {
            case .success(let places):
                self?.eventData = places
                guard let eventData = self?.eventData else { return }
                for index in 0...eventData.data.count - 1 {
                    ImageManager.shared.fetchImage(imageUrl: eventData.data[index].image) { image in
                        self?.makeCustomMarker(latitude: Float(eventData.data[index].latitude), longitude: Float(eventData.data[index].longitude), pinImage: image, isStreamer: false)
                    }
                }
            case .failure:
                print("Failed")
            }
        }
    }
    
    @objc func getPlaceData(_ sender: UIButton) {
        mapDataProvider.fetchPlaceInfo(latitude: latitude ?? Double(), longitude: longitude ?? Double()) { [weak self] result in
            switch result {
            case .success(let places):
                self?.placeData = places
                guard let placeData = self?.placeData else { return }
                for index in 0...placeData.data.count - 1 {
                    ImageManager.shared.fetchImage(imageUrl: placeData.data[index].image) { image in
                        self?.makeCustomMarker(latitude: Float(placeData.data[index].latitude), longitude: Float(placeData.data[index].longitude), pinImage: image, isStreamer: false)
                    }
                }
            case .failure:
                print("Failed")
            }
        }
    }
    
    
    func getImage(index: Int, latitude: Float, longitude: Float, data: Streamer) {
        ImageManager.shared.fetchImage(imageUrl: data.avatar) { image in
            self.makeCustomMarker(latitude: latitude, longitude: longitude, pinImage: image, isStreamer: true)
        }
    }
    
    func makeCustomMarker(latitude: Float, longitude: Float, pinImage: UIImage, isStreamer: Bool) {
        let marker = GMSMarker()
        
        marker.position = CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
        
        var size = CGSize()
        if isStreamer {
            size = CGSize(width: 88, height: 88)
        } else {
            size = CGSize(width: 77, height: 77)
        }
        
        UIGraphicsBeginImageContext(size)
        pinImage.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        
        if isStreamer {
            marker.icon = resizedImage?.circularImage(44)
        } else {
            marker.icon = resizedImage
        }
        marker.map = self.mapView
        mapView.selectedMarker = marker
    }
}

extension MapViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        let markerLatitude = Float(marker.position.latitude)
        let markerLongitude = Float(marker.position.longitude)
        
        specificStreamer = self.streamerData?.data.filter({
            Float($0.longitude) == markerLongitude && Float($0.latitude) == markerLatitude
        })
        
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
