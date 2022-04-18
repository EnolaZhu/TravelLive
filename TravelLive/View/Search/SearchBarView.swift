//
//  SearchBarView.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/17.
//

import UIKit

class SearchBarView: UICollectionReusableView {
    @IBOutlet weak var searchBar: UISearchBar! {
        didSet {
            searchBar.backgroundColor = UIColor.clear
            searchBar.tintColor = UIColor.primary
        }
    }
}
