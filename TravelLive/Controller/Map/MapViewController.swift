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
    var specificEvent: [Event]?
    var specificPlace: [Place]?
    var url = String()
    var longitude: CLLocationDegrees?
    var latitude: CLLocationDegrees?
    var currentLocation: CLLocation!
    var containerView = UIView()
    let placeButton = UIButton()
    let eventButton = UIButton()
    let streamButton = UIButton()
    var showTypeOfMarker = String()
    var isButtonSelected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpButtons()
        
        // Location
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        
        locationManager.delegate = self
        longitude = locationManager.location?.coordinate.longitude
        latitude = locationManager.location?.coordinate.latitude
        
        if CLLocationManager.authorizationStatus() != .denied {
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            fetchStreamerData()
        } else {
            DispatchQueue.main.async {
                self.fetchStreamerData()
            }
        }
        mapView.delegate = self
        
        setUpContainerView()
        setUpStreamButton()
        setUpPlaceButton()
        setUpEventButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        // Hide the Navigation Bar
        mapView.clear()
        fetchStreamerData()
        tabBarController?.tabBar.isHidden = false
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        placeButton.addTarget(self, action: #selector(getPlaceData), for: .touchUpInside)
        eventButton.addTarget(self, action: #selector(getEventData), for: .touchUpInside)
        streamButton.addTarget(self, action: #selector(getStreamerData), for: .touchUpInside)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        mapView.clear()
        // Show the Navigation Bar
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        containerView.layoutMargins = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        containerView.roundCorners(cornerRadius: 10.0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func setUpContainerView() {
        view.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            [containerView.widthAnchor.constraint(equalToConstant: 200),
             containerView.heightAnchor.constraint(equalToConstant: 50),
             containerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 60),
             containerView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30)]
        )
        containerView.backgroundColor = UIColor.backgroundColor
    }
    
    private func setUpPlaceButton() {
        containerView.addSubview(placeButton)
        placeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            [placeButton.widthAnchor.constraint(equalToConstant: 55),
             placeButton.heightAnchor.constraint(equalToConstant: 55),
             placeButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 3),
             placeButton.leftAnchor.constraint(equalTo: streamButton.rightAnchor, constant: 15)]
        )
    }
    
    private func setUpStreamButton() {
        containerView.addSubview(streamButton)
        streamButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            [streamButton.widthAnchor.constraint(equalToConstant: 40),
             streamButton.heightAnchor.constraint(equalToConstant: 40),
             streamButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 5),
             streamButton.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 25)]
        )
    }
    
    private func setUpEventButton() {
        containerView.addSubview(eventButton)
        eventButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            [eventButton.widthAnchor.constraint(equalToConstant: 42),
             eventButton.heightAnchor.constraint(equalToConstant: 42),
             eventButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 3),
             eventButton.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -15)]
        )
    }
    
    private func setUpButtons() {
        setUpButtonBasicColor(placeButton, UIImage.asset(.Icons_attractions)!, color: UIColor.secondary)
        setUpButtonBasicColor(eventButton, UIImage.asset(.event)!, color: UIColor.secondary)
        setUpButtonBasicColor(streamButton, UIImage.asset(.Icons_live)!, color: UIColor.secondary)
    }
    
   
    
    @objc func getStreamerData(_ sender: UIButton) {
        fetchStreamerData()
        isButtonSelected.toggle()
        changeButtonTintColor(sender, isButtonSelected, UIImage.asset(.Icons_live)!)
        
        setUpButtonBasicColor(eventButton, UIImage.asset(.event)!, color: UIColor.secondary)
        setUpButtonBasicColor(placeButton, UIImage.asset(.Icons_attractions)!, color: UIColor.secondary)
    }
    
    private func fetchStreamerData() {
        mapView.clear()
        showTypeOfMarker = "streamer"
        
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
        isButtonSelected.toggle()
        changeButtonTintColor(sender, isButtonSelected, UIImage.asset(.event)!)
        
        setUpButtonBasicColor(placeButton, UIImage.asset(.Icons_attractions)!, color: UIColor.secondary)
        setUpButtonBasicColor(streamButton, UIImage.asset(.Icons_live)!, color: UIColor.secondary)
        
        mapView.clear()
        showTypeOfMarker = "event"
        mapDataProvider.fetchEventInfo(latitude: latitude ?? Double(), longitude: longitude ?? Double(), limit: 4) { [weak self] result in
            switch result {
            case .success(let places):
                self?.eventData = places
                guard let eventData = self?.placeData else { return }
                if eventData.data.count > 0 {
                    guard let eventData = self?.eventData else { return }
                    for index in 0...eventData.data.count - 1 {
                        ImageManager.shared.fetchImage(imageUrl: eventData.data[index].image) { [weak self] image in
                            self?.makeCustomMarker(latitude: Float(eventData.data[index].latitude), longitude: Float(eventData.data[index].longitude), pinImage: image, isStreamer: false)
                        }
                    }
                }
            case .failure:
                print("Failed")
            }
        }
    }
    
    @objc func getPlaceData(_ sender: UIButton) {
        isButtonSelected.toggle()
        changeButtonTintColor(sender, isButtonSelected, UIImage.asset(.Icons_attractions)!)
        
        setUpButtonBasicColor(eventButton, UIImage.asset(.event)!, color: UIColor.secondary)
        setUpButtonBasicColor(streamButton, UIImage.asset(.Icons_live)!, color: UIColor.secondary)
        
        mapView.clear()
        showTypeOfMarker = "place"
        mapDataProvider.fetchPlaceInfo(latitude: latitude ?? Double(), longitude: longitude ?? Double(), limit: 4) { [weak self] result in
            switch result {
            case .success(let places):
                self?.placeData = places
                guard let placeData = self?.placeData else { return }
                if placeData.data.count > 0 {
                    for index in 0...placeData.data.count - 1 {
                        ImageManager.shared.fetchImage(imageUrl: placeData.data[index].image) { [weak self] image in
                            self?.makeCustomMarker(latitude: Float(placeData.data[index].latitude), longitude: Float(placeData.data[index].longitude), pinImage: image, isStreamer: false)
                        }
                    }
                }
            case .failure:
                print("Failed")
            }
        }
    }
    
    
    private func getImage(index: Int, latitude: Float, longitude: Float, data: Streamer) {
        ImageManager.shared.fetchImage(imageUrl: data.avatar) { [weak self] image in
            self?.makeCustomMarker(latitude: latitude, longitude: longitude, pinImage: image, isStreamer: true)
        }
    }
    
    private func makeCustomMarker(latitude: Float, longitude: Float, pinImage: UIImage, isStreamer: Bool) {
        let marker = GMSMarker()
        
        marker.position = CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
        var rect = CGRect()
        
        if isStreamer {
            rect = CGRect(x: 0, y: 0, width: 100, height: 100)
        } else {
            rect = CGRect(x: 0, y: 0, width: 100, height: 100)
        }
        
        let imageView = UIImageView(frame: rect)
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 4
        
        if isStreamer {
            imageView.layer.borderColor = UIColor.primary.cgColor
        } else {
            imageView.layer.borderColor = UIColor.backgroundColor.cgColor
        }
        
        imageView.image = pinImage
        marker.iconView = imageView
        marker.map = self.mapView
    }
}

extension MapViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        let markerLatitude = Float(marker.position.latitude)
        let markerLongitude = Float(marker.position.longitude)
        
        if showTypeOfMarker == "event" {
            specificEvent = self.eventData?.data.filter({
                Float($0.longitude) == markerLongitude && Float($0.latitude) == markerLatitude
            })
            createDetailView(detailEventData: specificEvent?.first, detailPlaceData: nil)
            
        } else if showTypeOfMarker == "place" {
            specificPlace = self.placeData?.data.filter({
                Float($0.longitude) == markerLongitude && Float($0.latitude) == markerLatitude
            })
            createDetailView(detailEventData: nil, detailPlaceData: specificPlace?.first)
            
        } else {
            specificStreamer = self.streamerData?.data.filter({
                Float($0.longitude) == markerLongitude && Float($0.latitude) == markerLatitude
            })
            
            guard let url = specificStreamer?.first?.pullUrl else { return false }
            self.url = url
            createLiveRoom(streamerUrl: url)
        }
        return true
    }
    
    private func createDetailView(detailEventData: Event?, detailPlaceData: Place?) {
        let mapDetailVC = UIStoryboard.mapDetail.instantiateViewController(withIdentifier: String(describing: MapDetailViewController.self)
        )
        guard let detailVC = mapDetailVC as? MapDetailViewController else { return }
        if detailEventData == nil {
            detailVC.detailPlaceData = detailPlaceData
        } else {
            detailVC.detailEventData = detailEventData
        }
        show(detailVC, sender: nil)
    }
    
    private func createLiveRoom(streamerUrl: String) {
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
