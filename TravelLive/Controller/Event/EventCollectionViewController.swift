//
//  EventCollectionViewController.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/26.
//

import UIKit

class EventCollectionViewController: UIViewController {
    let collectionView: UICollectionView

    private let layout: UICollectionViewFlowLayout

    override func viewDidLoad() {
        super.viewDidLoad()

        setupCollectionView()
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

        collectionView.backgroundColor = UIColor.clear

        let nib = UINib(nibName: String(describing: EventCollectionViewCell.self), bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: String(describing: EventCollectionViewCell.self))

        view.addSubview(collectionView)
    }
}

extension EventCollectionViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return 5

    }
//swiftlint:disable force_cast identifier_name
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: EventCollectionViewCell.self), for: indexPath) as? EventCollectionViewCell else {
            fatalError("Couldn't create cell")
        }

//        cell.indexLabel.text = String(indexPath.row)
        cell.eventImageView.image = UIImage(named: "avatar")
        return cell
    }
}

extension EventCollectionViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let itemSize = CGSize(width: UIScreen.width / 2, height: self.collectionView.frame.height)

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
}

