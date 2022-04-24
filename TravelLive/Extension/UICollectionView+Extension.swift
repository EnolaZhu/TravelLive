//
//  UICollectionView+Extension.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/22.
//

import UIKit

extension UICollectionView {

    func registerCellWithNib(identifier: String, bundle: Bundle?) {

        let nib = UINib(nibName: identifier, bundle: bundle)

        register(nib, forCellWithReuseIdentifier: identifier)
    }
}
