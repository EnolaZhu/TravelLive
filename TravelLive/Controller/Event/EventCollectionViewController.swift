//
//  EventCollectionViewController.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/26.
//

import UIKit

class EventCollectionViewController: UIViewController {
    private let collectionView: UICollectionView

    private let layout: UICollectionViewFlowLayout
    
    var specificPlaceData: PlaceDataObject?
    var specificEventData: EventDataObject?
    var images: [UIImage] = [] {
        didSet {
            collectionView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.backgroundColor
        setupCollectionView()
        collectionView.showsHorizontalScrollIndicator = false
    }

    init() {
        self.layout = UICollectionViewFlowLayout()

        self.layout.scrollDirection = .horizontal

        self.collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupCollectionView() {

        collectionView.delegate = self
        collectionView.dataSource = self

        collectionView.backgroundColor = UIColor.backgroundColor

        let nib = UINib(nibName: "\(EventCollectionViewCell.self)", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "\(EventCollectionViewCell.self)")

        view.addSubview(collectionView)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            [collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
             collectionView.topAnchor.constraint(equalTo: view.topAnchor),
             collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
             collectionView.rightAnchor.constraint(equalTo: view.rightAnchor)]
        )
    }
}

extension EventCollectionViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        images.count

    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(EventCollectionViewCell.self)", for: indexPath) as? EventCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        if specificPlaceData == nil {
            
        } else {
            cell.layoutCell(image: images[indexPath.item], title: specificPlaceData?.data[indexPath.row].title ?? "", location: specificPlaceData?.data[indexPath.row].city ?? "")
        }
        return cell
    }
}

extension EventCollectionViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let itemSize = CGSize(width: self.collectionView.frame.height, height: self.collectionView.frame.height)

        return itemSize
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {

        return 10
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {

        return 10
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
          createDetailView(detailEventData: nil, detailPlaceData: specificPlaceData?.data[indexPath.row])
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
    
    func getPlaceData(city: Int, limit: Int) {

        MapDataProvider.shared.fetchSpecificPlaceInfo(city: city, limit: limit) { [weak self] result in
            switch result {
            case .success(let data):
                self?.specificPlaceData = data
                guard let specificPlaceData = self?.specificPlaceData else { return }

                if specificPlaceData.data.count > 0 {
                    guard let specificPlaceData = self?.specificPlaceData else { return }
                    for index in 0...specificPlaceData.data.count - 1 {
                        ImageManager.shared.fetchImage(imageUrl: specificPlaceData.data[index].image) { [weak self] image in
                            self?.images.append(image)
                            self?.collectionView.reloadData()
                        }
                    }
                }

            case .failure:
                self?.view.makeToast("????????????????????????", duration: 0.5, position: .center)
            }
        }
    }
}
