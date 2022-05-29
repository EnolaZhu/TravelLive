//
//  EventViewController.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/24.
//

import UIKit
import GoogleMaps

private enum PlaceEventCellType: CaseIterable {
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
    
    // MARK: - Property
    @IBOutlet weak var mapDetailTableView: UITableView! {
        didSet {
            mapDetailTableView.delegate = self
            mapDetailTableView.dataSource = self
        }
    }
    private let noData = "暫無資料"
    var detailEventData: Event?
    var detailPlaceData: Place?
    lazy var header = StretchyTableHeaderView()
    lazy var maskView = UIView()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCell()
        setUpView()
        setUpMaskView()
        setUpHeader()
        
        // setting navigationbar back button color
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
    
    // MARK: - Component
    private func setUpMaskView() {
        view.addSubview(maskView)
        maskView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            maskView.widthAnchor.constraint(equalToConstant: UIScreen.width),
            maskView.heightAnchor.constraint(equalToConstant: 250),
            maskView.leftAnchor.constraint(equalTo: view.leftAnchor),
            maskView.topAnchor.constraint(equalTo: view.topAnchor)
        ])
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
    
    private func setUpHeader() {
        view.addSubview(header)
        header.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            header.widthAnchor.constraint(equalToConstant: view.frame.width),
            header.heightAnchor.constraint(equalToConstant: view.frame.width),
            header.leftAnchor.constraint(equalTo: view.leftAnchor),
            header.topAnchor.constraint(equalTo: view.topAnchor)
        ])
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
            placeEventViewTitleCell.layoutCell(title: detailEventData?.title ?? noData)
        } else {
            placeEventViewTitleCell.layoutCell(title: detailPlaceData?.title ?? noData)
        }
    }
    
    private func updateLocationSelectionCell(_ cell: UITableViewCell) {
        guard let placeEventViewLocationCell = cell as? PlaceEventViewLocationCell else { return }
        
        if detailPlaceData == nil {
            placeEventViewLocationCell.layoutCell(title: detailEventData?.city ?? noData, detail: detailEventData?.address ?? noData)
        } else {
            placeEventViewLocationCell.layoutCell(title: detailPlaceData?.city ?? noData, detail: detailPlaceData?.distric ?? noData)
        }
    }
    
    private func updateDescriptionSelectionCell(_ cell: UITableViewCell) {
        guard let placeEventViewContentCell = cell as? PlaceEventViewContentCell else { return }
        
        if detailPlaceData == nil {
            placeEventViewContentCell.layoutCell(content: detailEventData?.content ?? noData)
        } else {
            placeEventViewContentCell.layoutCell(content: detailPlaceData?.content ?? noData)
        }
    }
    
    private func updateTimeSelectionCell(_ cell: UITableViewCell) {
        guard let placeEventViewReuseCell = cell as? PlaceEventViewReuseCell else { return }
        
        if detailPlaceData == nil {
            placeEventViewReuseCell.layoutCell(start: detailEventData?.start ?? noData, end: detailEventData?.end ?? noData)
        } else {
            placeEventViewReuseCell.layoutCell(start: detailPlaceData?.start ?? noData, end: detailPlaceData?.end ?? noData)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: PlaceEventCellType.allCases[indexPath.row].identifier, for: indexPath)
        manipulaterCell(cell, type: PlaceEventCellType.allCases[indexPath.row])
        return cell
    }
    
    func createMapView(latitude: Float, longitude: Float) {
        let camera = GMSCameraPosition.camera(withLatitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude), zoom: 16.0)
        let mapView = GMSMapView.map(withFrame: CGRect.init(x: 0, y: 0, width: UIScreen.width, height: 250), camera: camera)
        // using map as footerview
        mapDetailTableView.tableFooterView = mapView
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
        marker.map = mapView
        
        maskView.backgroundColor = UIColor.primary.withAlphaComponent(0.2)
        mapView.addSubview(maskView)
        mapView.selectedMarker = marker
    }
}
