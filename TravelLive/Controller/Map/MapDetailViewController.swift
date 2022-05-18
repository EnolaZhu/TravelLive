//
//  EventViewController.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/24.
//

import UIKit
import GoogleMaps

private enum PlaceEventCellType {
    case title
    case location
    case description
    case time

    var identifier: String {
        switch self {
        case .title: return String(describing: PlaceEventViewTitleCell.self)
        case .location: return String(describing: PlaceEventViewLocationCell.self)
        case .description: return String(describing: PlaceEventViewContentCell.self)
        case .time: return String(describing: PlaceEventViewReuseCell.self)
        }
    }
}

class MapDetailViewController: UIViewController, UITableViewDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate {
    @IBOutlet weak var mapDetailTableView: UITableView! {
        didSet {
            mapDetailTableView.delegate = self
            mapDetailTableView.dataSource = self
        }
    }
    var detailEventData: Event?
    var detailPlaceData: Place?
    lazy var header = StretchyTableHeaderView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.width))
    lazy var maskView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.width, height: 250))
    private let datas: [PlaceEventCellType] = [.title, .location, .description, .time]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCell()
        setUpView()
        addGestureOnMaskView()
        
        // Setting navigationbar back button color
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
    
    private func addGestureOnMaskView() {
        let tapMapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(mapTapped(tapGestureRecognizer:)))
        maskView.addGestureRecognizer(tapMapGestureRecognizer)
        maskView.isUserInteractionEnabled = true
    }
    
    @objc func mapTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        // handling code
        print("item")
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
    
    
    private func manipulaterCell(_ cell: UITableViewCell, type: PlaceEventCellType) {

        switch type {

        case .title:
            updateTitleSelectionCell(cell)
        case .location:
            updateLocationSelectionCell(cell)
        case .description:
            updateDescriptionSelectionCell(cell)
        case .time:
            updateTimeSelectionCell(cell)
        }
    }
    
    private func updateTitleSelectionCell(_ cell: UITableViewCell) {
        guard let placeEventViewTitleCell = cell as? PlaceEventViewTitleCell else { return }
        
        if detailPlaceData == nil {
            placeEventViewTitleCell.layoutCell(title: detailEventData?.title ?? "暫無")
        } else {
            placeEventViewTitleCell.layoutCell(title: detailPlaceData?.title ?? "暫無")
        }
    }
    
    private func updateLocationSelectionCell(_ cell: UITableViewCell) {
        guard let placeEventViewLocationCell = cell as? PlaceEventViewLocationCell else { return }
        
        if detailPlaceData == nil {
            placeEventViewLocationCell.layoutCell(title: detailEventData?.city ?? "暫無資料", detail: detailEventData?.address ?? "暫無資料")
        } else {
            placeEventViewLocationCell.layoutCell(title: detailPlaceData?.city ?? "暫無資料", detail: detailPlaceData?.distric ?? "暫無資料")
        }
    }
    
    private func updateDescriptionSelectionCell(_ cell: UITableViewCell) {
        guard let placeEventViewContentCell = cell as? PlaceEventViewContentCell else { return }
        
        if detailPlaceData == nil {
            placeEventViewContentCell.layoutCell(content: detailEventData?.content ?? "暫無資料")
        } else {
            placeEventViewContentCell.layoutCell(content: detailPlaceData?.content ?? "暫無資料")
        }
    }
    
    private func updateTimeSelectionCell(_ cell: UITableViewCell) {
        guard let placeEventViewReuseCell = cell as? PlaceEventViewReuseCell else { return }
        
        if detailPlaceData == nil {
            placeEventViewReuseCell.layoutCell(start: detailEventData?.start ?? " 暫無資料", end: detailEventData?.end ?? " 暫無資料")
        } else {
            placeEventViewReuseCell.layoutCell(start: detailPlaceData?.start ?? " 暫無資料", end: detailPlaceData?.end ?? " 暫無資料")
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let header = mapDetailTableView.tableHeaderView as? StretchyTableHeaderView else { return }
        header.scrollViewDidScroll(scrollView: mapDetailTableView)
    }
}

extension MapDetailViewController: UITableViewDataSource, GMSMapViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: datas[indexPath.row].identifier, for: indexPath)
        manipulaterCell(cell, type: datas[indexPath.row])
        return cell
    }
    
    func createMapView(latitude: Float, longitude: Float) {
        let camera = GMSCameraPosition.camera(withLatitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude), zoom: 16.0)
        let mapView = GMSMapView.map(withFrame: CGRect.init(x: 0, y: 0, width: UIScreen.width, height: 250), camera: camera)
        // Using map as footerview
        mapDetailTableView.tableFooterView = mapView
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
        marker.map = mapView
        
        maskView.backgroundColor = UIColor.primary.withAlphaComponent(0.2)
        mapView.addSubview(maskView)
        mapView.selectedMarker = marker
    }
}
