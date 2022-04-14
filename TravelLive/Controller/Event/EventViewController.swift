//
//  EventViewController.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/14.
//

import UIKit

class EventViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    fileprivate let items: [Event] = Event.buildCities()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.collectionViewLayout = EventCollectionViewFlowLayout(itemSize: EventCollectionViewCell.cellSize)
        collectionView.decelerationRate = UIScrollView.DecelerationRate.fast
        collectionView.delegate = self
        collectionView.dataSource = self
    }
}
extension EventViewController {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        items.count
    }
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return 1
    }
    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EventCollectionViewCell.identifier, for: indexPath) as? EventCollectionViewCell
//        else { fatalError("Couldn't create cell") }
//        if indexPath.section == 0 {
//            cell.configure(with: items[0], collectionView: collectionView, index: 0)
//        } else if indexPath.section == 1 {
//            cell.configure(with: items[1], collectionView: collectionView, index: 1)
//        } else if indexPath.section == 2 {
//            cell.configure(with: items[2], collectionView: collectionView, index: 2)
//        }
//        return cell
//    }
//
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        guard let selectedCell = collectionView.cellForItem(at: indexPath)! as? EventCollectionViewCell
//        else { fatalError("Couldn't create cell") }
//        selectedCell.toggle()
//    }
    // swiftlint:disable force_cast
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EventCollectionViewCell.identifier, for: indexPath) as! EventCollectionViewCell
        if indexPath.section == 0 {
            cell.configure(with: items[0], collectionView: collectionView, index: 0)
        } else if indexPath.section == 1 {
            cell.configure(with: items[1], collectionView: collectionView, index: 1)
        } else if indexPath.section == 2 {
            cell.configure(with: items[2], collectionView: collectionView, index: 2)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCell = collectionView.cellForItem(at: indexPath)! as! EventCollectionViewCell
        selectedCell.toggle()
    }
}
