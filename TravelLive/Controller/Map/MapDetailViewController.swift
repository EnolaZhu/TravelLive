//
//  EventViewController.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/24.
//

import UIKit

class MapDetailViewController: UIViewController {
    @IBOutlet weak var mapDetailTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCell()
        mapDetailTableView.dataSource = self
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
            placeEventViewImageCell.showImageView.image = UIImage(named: "avatar")
            return placeEventViewImageCell
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PlaceEventViewTitleCell.self), for: indexPath)
            guard let placeEventViewTitleCell = cell as? PlaceEventViewTitleCell else { return cell }
            placeEventViewTitleCell.titleLabel.backgroundColor = UIColor.primary
            return placeEventViewTitleCell
        } else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PlaceEventViewLocationCell.self), for: indexPath)
            guard let placeEventViewLocationCell = cell as? PlaceEventViewLocationCell else { return cell }
            placeEventViewLocationCell.mapImageView.image = UIImage(named: "event")
            return placeEventViewLocationCell
        } else if indexPath.row == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PlaceEventViewContentCell.self), for: indexPath)
            guard let placeEventViewContentCell = cell as? PlaceEventViewContentCell else { return cell }
            placeEventViewContentCell.backgroundColor = UIColor.blue
            return placeEventViewContentCell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PlaceEventViewReuseCell.self), for: indexPath)
            guard let placeEventViewReuseCell = cell as? PlaceEventViewReuseCell else { return cell }
            placeEventViewReuseCell.backgroundColor = UIColor.yellow
            return placeEventViewReuseCell
        }
    }
}
