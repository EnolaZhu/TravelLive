//
//  EventViewController.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/24.
//

import UIKit
import GoogleMaps

class MapDetailViewController: UIViewController, UITableViewDelegate, UIScrollViewDelegate {
    @IBOutlet weak var mapDetailTableView: UITableView!
    var detailEventData: Event?
    var detailPlaceData: Place?
    lazy var header = StretchyTableHeaderView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.width))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCell()
        mapDetailTableView.delegate = self
        mapDetailTableView.dataSource = self
        setUpView()
        
        // Setting navigationbar back button color
        navigationController?.navigationBar.barStyle = UIBarStyle.black
        navigationController?.navigationBar.tintColor = UIColor.primary
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    private func setUpView() {
        mapDetailTableView.separatorStyle = .none
        mapDetailTableView.backgroundColor = UIColor.backgroundColor
        view.backgroundColor = UIColor.backgroundColor
        mapDetailTableView.tableHeaderView = header
        
        if detailPlaceData == nil {
            ImageManager.shared.fetchImage(imageUrl: detailEventData?.image ?? "") { [weak self] image in
                self?.header.imageView.image = image
            }
            createMapView(latitude: Float(detailEventData?.latitude ?? 0), longitude: Float(detailEventData?.longitude ?? 0))
            
        } else {
            ImageManager.shared.fetchImage(imageUrl: detailPlaceData?.image ?? "") { [weak self] image in
                self?.header.imageView.image = image
            }
            createMapView(latitude: Float(detailPlaceData?.latitude ?? 0), longitude: Float(detailPlaceData?.longitude ?? 0))
        }
    }
    
    private func registerCell() {
        mapDetailTableView.registerCellWithNib(identifier: String(describing: PlaceEventViewTitleCell.self), bundle: nil)
        mapDetailTableView.registerCellWithNib(identifier: String(describing: PlaceEventViewLocationCell.self), bundle: nil)
        mapDetailTableView.registerCellWithNib(identifier: String(describing: PlaceEventViewContentCell.self), bundle: nil)
        mapDetailTableView.registerCellWithNib(identifier: String(describing: PlaceEventViewReuseCell.self), bundle: nil)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let header = mapDetailTableView.tableHeaderView as? StretchyTableHeaderView else { return }
        header.scrollViewDidScroll(scrollView: mapDetailTableView)
    }
}

extension MapDetailViewController: UITableViewDataSource, GMSMapViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PlaceEventViewTitleCell.self), for: indexPath)
            guard let placeEventViewTitleCell = cell as? PlaceEventViewTitleCell else { return cell }
            placeEventViewTitleCell.selectionStyle = .none
            
            if detailPlaceData == nil {
                placeEventViewTitleCell.layoutCell(title: detailEventData?.title ?? "暫無")
            } else {
                placeEventViewTitleCell.layoutCell(title: detailPlaceData?.title ?? "暫無")
            }
            return placeEventViewTitleCell
            
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PlaceEventViewLocationCell.self), for: indexPath)
            guard let placeEventViewLocationCell = cell as? PlaceEventViewLocationCell else { return cell }
            placeEventViewLocationCell.selectionStyle = .none
            
            if detailPlaceData == nil {
                placeEventViewLocationCell.layoutCell(title: detailEventData?.city ?? "暫無資料", detail: detailEventData?.address ?? "暫無資料")
            } else {
                placeEventViewLocationCell.layoutCell(title: detailPlaceData?.city ?? "暫無資料", detail: detailPlaceData?.distric ?? "暫無資料")
            }
            return placeEventViewLocationCell
            
        } else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PlaceEventViewContentCell.self), for: indexPath)
            guard let placeEventViewContentCell = cell as? PlaceEventViewContentCell else { return cell }
            placeEventViewContentCell.selectionStyle = .none
            
            if detailPlaceData == nil {
                placeEventViewContentCell.layoutCell(content: detailEventData?.content ?? "暫無資料")
            } else {
                placeEventViewContentCell.layoutCell(content: detailPlaceData?.content ?? "暫無資料")
            }
            return placeEventViewContentCell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PlaceEventViewReuseCell.self), for: indexPath)
            guard let placeEventViewReuseCell = cell as? PlaceEventViewReuseCell else { return cell }
            placeEventViewReuseCell.selectionStyle = .none
            
            if detailPlaceData == nil {
                placeEventViewReuseCell.layoutCell(start: detailEventData?.start ?? " 暫無資料", end: detailEventData?.end ?? " 暫無資料")
            } else {
                placeEventViewReuseCell.layoutCell(start: detailPlaceData?.start ?? " 暫無資料", end: detailPlaceData?.end ?? " 暫無資料")
            }
            return placeEventViewReuseCell
        }
    }
    
    func createMapView(latitude: Float, longitude: Float) {
        let camera = GMSCameraPosition.camera(withLatitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude), zoom: 15.0)
        let mapView = GMSMapView.map(withFrame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 250), camera: camera)
        // Using map as footerview
        mapDetailTableView.tableFooterView = mapView
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
        marker.map = mapView
        
        mapView.selectedMarker = marker
    }
}
