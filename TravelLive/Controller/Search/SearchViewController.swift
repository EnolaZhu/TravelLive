//
//  SearchViewController.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/11.
//

import UIKit
import FirebaseStorage
import SwiftUI

class SearchViewController: BaseViewController, UICollectionViewDataSource, GridLayoutDelegate {
    @IBOutlet weak var searchCollectionView: UICollectionView!
    @IBOutlet weak var gridLayout: GridLayout!
    
    var arrInstaBigCells = [Int]()
    var images = [UIImage]()
    var searchDataObjc: SearchDataObject?
    let searchController = UISearchController()
    let searchDataProvider = SearchDataProvider()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        searchCollectionView.isUserInteractionEnabled = true
        arrInstaBigCells.append(1)
        
        
        var tempStorage = false
        for _ in 1...21 {
            if tempStorage {
                arrInstaBigCells.append(arrInstaBigCells.last! + 10)
            } else {
                arrInstaBigCells.append(arrInstaBigCells.last! + 8)
            }
            tempStorage = !tempStorage
        }
        
        searchCollectionView.showsVerticalScrollIndicator = false
        searchCollectionView.backgroundColor = .white
        searchCollectionView.dataSource = self
        searchCollectionView.delegate = self
        searchCollectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        searchCollectionView.contentOffset = CGPoint(x: -10, y: -10)
        
        gridLayout.delegate = self
        gridLayout.itemSpacing = 3
        gridLayout.fixedDivisionCount = 3
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
        images.removeAll()
        getSearchData()
        searchController.searchBar.text = ""
        searchController.searchBar.placeholder = "搜尋"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchCollectionViewCell", for: indexPath) as? SearchCollectionViewCell else { return UICollectionViewCell() }
        if images.count > 0 {
            cell.imageView.image = images[indexPath.row]
        }
        return cell
    }
    
    // MARK: - PrimeGridDelegate
    
    func scaleForItem(inCollectionView collectionView: UICollectionView, withLayout layout: UICollectionViewLayout, atIndexPath indexPath: IndexPath) -> UInt {
        if arrInstaBigCells.contains(indexPath.row) || (indexPath.row == 1) {
            return 2
        } else {
            return 1
        }
    }
    
    func itemFlexibleDimension(inCollectionView collectionView: UICollectionView, withLayout layout: UICollectionViewLayout, fixedDimension: CGFloat) -> CGFloat {
        return fixedDimension
    }
    
    // Fetch search data
    private func getSearchData() {
        fetchSearchData(type: "")
    }
    
    private func fetchSearchData(type: String) {
        searchDataProvider.fetchSearchData(query: type) { [weak self] result in
            switch result {
            case .success(let data):
                print("\(data)")
                self?.searchDataObjc = data
                guard let searchDataObjc = self?.searchDataObjc else { return }
                if searchDataObjc.data.count > 0 {
                    // placeholder
                    self?.images = [UIImage](repeating: UIImage(named: "placeholder") ?? UIImage(), count: searchDataObjc.data.count)
                    for index in 0...searchDataObjc.data.count - 1 {
                        if searchDataObjc.data[index].thumbnailUrl == "" {
                            self?.getImage(searchData: searchDataObjc.data[index], imageUrl: searchDataObjc.data[index].fileUrl, index: index)
                        } else {
                            self?.getThumbnail(searchData: searchDataObjc.data[index], index: index)
                        }
                    }
                }
            case .failure:
                print("Failed")
            }
        }
    }
    
    private func getImage(searchData: SearchData, imageUrl: String, index: Int) {
        // Image
        ImageManager.shared.fetchImage(imageUrl: imageUrl) { [weak self] image in
            self?.images[index] = image
            self?.searchCollectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
        }
    }
    
    private func getThumbnail(searchData: SearchData, index: Int) {
        // video GIF
        ImageManager.shared.fetchUserGIF(thumbnailUrl: searchData.thumbnailUrl) { gif in
            self.images[index] = gif
            self.searchCollectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
        }
    }
}

extension SearchViewController: UISearchBarDelegate, UICollectionViewDelegate, UISearchResultsUpdating {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let image = images[indexPath.item]
        let detailVC = DetailViewController()
        detailVC.detailPageImage = image
        detailVC.propertyId = searchDataObjc?.data[indexPath.row].propertyId ?? ""
        detailVC.imageOwnerName = searchDataObjc?.data[indexPath.row].name ?? ""
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else {
            return
        }
        
        if text != "" {
            images.removeAll()
            fetchSearchData(type: "?tag=" + text)
        } else {
            print("Do nothing")
        }
    }
}

enum SearchQuery: String {
    case video = "video"
    case image = "image"
}
