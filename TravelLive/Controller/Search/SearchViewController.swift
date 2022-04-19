//
//  SearchViewController.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/11.
//

import UIKit

class SearchViewController: BaseViewController, UICollectionViewDataSource, GridLayoutDelegate {
    var images = [UIImage]()
    @IBOutlet weak var searchCollectionView: UICollectionView!
    @IBOutlet weak var gridLayout: GridLayout!
    
    var arrInstaBigCells = [Int]()
    var searchDataObjc: SearchDataObject?
    let searchController = UISearchController()
    let searchDataProvider = SearchDataProvider()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.searchController = searchController
        
        images = Array(repeatElement(#imageLiteral(resourceName: "avatar"), count: 99))
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
        
        print(arrInstaBigCells)
        searchCollectionView.backgroundColor = .white
        searchCollectionView.dataSource = self
        searchCollectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        searchCollectionView.contentOffset = CGPoint(x: -10, y: -10)
        
        gridLayout.delegate = self
        gridLayout.itemSpacing = 3
        gridLayout.fixedDivisionCount = 3
        
        getSearchData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        searchController.searchBar.placeholder = "搜尋"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 99
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchCollectionViewCell", for: indexPath) as? SearchCollectionViewCell else { return UICollectionViewCell() }
        cell.imageView.image = images[indexPath.row]
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
        fetchSearchData(type: SearchQuery.image.rawValue)
        fetchSearchData(type: SearchQuery.video.rawValue)
    }
    
    private func fetchSearchData(type: String) {
        searchDataProvider.fetchSearchData(type: type) { [weak self] result in
            switch result {
            case .success(let data):
                print("\(data)")
                self?.searchDataObjc = data
                guard let searchDataObjc = self?.searchDataObjc else { return }
//                for index in 0...searchDataObjc.data?.count - 1 {
//                    if searchDataObjc.data[0].thumbnailName == "" {
//                        self?.getImage(searchData: searchDataObjc.data[index], imageUrl: searchDataObjc.data[index].fileName)
//                    } else {
//                        self?.getImage(searchData: searchDataObjc.data[index], imageUrl: searchDataObjc.data[index].thumbnailName ?? "")
//                    }
//                }
            case .failure:
                print("Failed")
            }
        }
    }
    
    private func getImage(searchData: SearchData, imageUrl: String) {
        // Image
        MarkerManager.shared.fetchStreamerImage(hostUrl: searchData.storageBucket, imageUrl: imageUrl) { image in
        }
    }
    
    private func getthumbnail(searchData: SearchData) {
        // video GIF
        MarkerManager.shared.fetchStreamerImage(hostUrl: searchData.storageBucket, imageUrl: searchData.thumbnailName ?? "" ) { thumbnail in
        }
    }
}

extension SearchViewController: UISearchBarDelegate {
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let searchBarView: UICollectionReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SearchBar", for: indexPath)
        return searchBarView
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == false {
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
    }
}

enum SearchQuery: String {
    case video = "video"
    case image = "image"
}
