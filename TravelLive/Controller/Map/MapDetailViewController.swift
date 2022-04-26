//
//  EventViewController.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/24.
//

import UIKit

class MapDetailViewController: UIViewController {
    @IBOutlet weak var mapDetailTableView: UITableView!
    var detailEventData: Event?
    var detailPlaceData: Place?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCell()
        mapDetailTableView.separatorStyle = .none
        mapDetailTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        navigationController?.navigationBar.alpha = 0.3
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    private func registerCell() {
        mapDetailTableView.registerCellWithNib(identifier: String(describing: PlaceEventViewImageCell.self), bundle: nil)
        mapDetailTableView.registerCellWithNib(identifier: String(describing: PlaceEventViewTitleCell.self), bundle: nil)
        mapDetailTableView.registerCellWithNib(identifier: String(describing: PlaceEventViewLocationCell.self), bundle: nil)
        mapDetailTableView.registerCellWithNib(identifier: String(describing: PlaceEventViewContentCell.self), bundle: nil)
        mapDetailTableView.registerCellWithNib(identifier: String(describing: PlaceEventViewReuseCell.self), bundle: nil)
    }
}

extension MapDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PlaceEventViewImageCell.self), for: indexPath)
            guard let placeEventViewImageCell = cell as? PlaceEventViewImageCell else { return cell }
            
            if detailPlaceData == nil {
                ImageManager.shared.fetchImage(imageUrl: detailEventData?.image ?? "") { [weak self] image in
                    placeEventViewImageCell.layoutCell(image: image)
                }
            } else {
                ImageManager.shared.fetchImage(imageUrl: detailPlaceData?.image ?? "") { [weak self] image in
                    placeEventViewImageCell.layoutCell(image: image)
                }
            }
            
            return placeEventViewImageCell
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PlaceEventViewTitleCell.self), for: indexPath)
            guard let placeEventViewTitleCell = cell as? PlaceEventViewTitleCell else { return cell }
            
            if detailPlaceData == nil {
                placeEventViewTitleCell.layoutCell(title: detailEventData?.title ?? "暫無")
            } else {
                placeEventViewTitleCell.layoutCell(title: detailPlaceData?.title ?? "暫無")
            }
            return placeEventViewTitleCell
            
        } else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PlaceEventViewLocationCell.self), for: indexPath)
            guard let placeEventViewLocationCell = cell as? PlaceEventViewLocationCell else { return cell }
            
            if detailPlaceData == nil {
                placeEventViewLocationCell.layoutCell(title: detailEventData?.city ?? "暫無資料", detail: detailEventData?.address ?? "暫無資料")
            } else {
                placeEventViewLocationCell.layoutCell(title: detailPlaceData?.city ?? "暫無資料", detail: detailPlaceData?.distric ?? "暫無資料")
            }
            return placeEventViewLocationCell
        } else if indexPath.row == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PlaceEventViewContentCell.self), for: indexPath)
            guard let placeEventViewContentCell = cell as? PlaceEventViewContentCell else { return cell }
            
            if detailPlaceData == nil {
                placeEventViewContentCell.layoutCell(content: detailEventData?.content ?? "暫無資料")
            } else {
                placeEventViewContentCell.layoutCell(content: detailPlaceData?.content ?? "暫無資料")
            }
            return placeEventViewContentCell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PlaceEventViewReuseCell.self), for: indexPath)
            guard let placeEventViewReuseCell = cell as? PlaceEventViewReuseCell else { return cell }
            
            if detailPlaceData == nil {
                placeEventViewReuseCell.layoutCell(start: detailEventData?.start ?? " 暫無資料", end: detailEventData?.end ?? " 暫無資料")
            } else {
                placeEventViewReuseCell.layoutCell(start: detailPlaceData?.start ?? " 暫無資料", end: detailPlaceData?.end ?? " 暫無資料")
            }
            return placeEventViewReuseCell
        }
    }
}
