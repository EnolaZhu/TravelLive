//
//  SearchViewController.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/11.
//

import UIKit
import FirebaseStorage

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
        fetchSearchData(type: "?type=" + SearchQuery.image.rawValue)
        fetchSearchData(type: "?type=" + SearchQuery.video.rawValue)
    }
    
    private func fetchSearchData(type: String) {
        searchDataProvider.fetchSearchData(query: type) { [weak self] result in
            switch result {
            case .success(let data):
                print("\(data)")
                self?.searchDataObjc = data
                guard let searchDataObjc = self?.searchDataObjc else { return }
                if searchDataObjc.data.count > 0 {
                    for index in 0...searchDataObjc.data.count - 1 {
                        if searchDataObjc.data[0].thumbnailUrl == "" {
                            self?.getImage(searchData: searchDataObjc.data[index], imageUrl: searchDataObjc.data[index].fileUrl)
                        } else {
                            self?.getThumbnail(searchData: searchDataObjc.data[index])
                        }
                    }
                }
            case .failure:
                print("Failed")
            }
        }
    }
    
    private func getImage(searchData: SearchData, imageUrl: String) {
        // Image
        ImageManager.shared.fetchStorageImage(imageUrl: imageUrl) { image in
            self.images.append(image)
            self.searchCollectionView.reloadData()
        }
    }
    
    private func getThumbnail(searchData: SearchData) {
        // video GIF
        ImageManager.shared.fetchUserGIF(thumbnailUrl: searchData.thumbnailUrl) { gif in
            self.images.append(gif)
            self.searchCollectionView.reloadData()
        }
    }
}

extension SearchViewController: UISearchBarDelegate, UICollectionViewDelegate, UISearchResultsUpdating {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let image = images[indexPath.item]
        print("\(indexPath.item)")
        let detailVC = DetailViewController()
        detailVC.detailPageImage = image
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
