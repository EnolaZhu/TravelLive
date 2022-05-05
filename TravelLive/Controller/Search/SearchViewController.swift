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
    var searchController = UISearchController()
    let searchDataProvider = SearchDataProvider()
    var showNoResultLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.searchController = searchController
        searchCollectionView.isUserInteractionEnabled = true
        arrInstaBigCells.append(1)
        
        // Fix searchbar hidden when change view
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchBar.delegate = self
        
        var tempStorage = false
        for _ in 1...21 {
            if tempStorage {
                arrInstaBigCells.append(arrInstaBigCells.last! + 10)
            } else {
                arrInstaBigCells.append(arrInstaBigCells.last! + 8)
            }
            tempStorage = !tempStorage
        }
        
        getSearchData()
        
        view.backgroundColor = .backgroundColor
        searchCollectionView.backgroundColor = .backgroundColor
        searchCollectionView.dataSource = self
        searchCollectionView.delegate = self
        searchCollectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        searchCollectionView.contentOffset = CGPoint(x: -10, y: -10)
        searchController.searchBar.setValue("取消", forKey: "cancelButtonText")
        gridLayout.delegate = self
        gridLayout.itemSpacing = 3
        gridLayout.fixedDivisionCount = 3
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
        navigationController?.setNavigationBarHidden(false, animated: animated)
        
        searchController.searchBar.text = ""
        searchController.searchBar.placeholder = "搜尋"
        searchController.searchBar.tintColor = UIColor.primary
        
        setNeedsStatusBarAppearanceUpdate()
        navigationController?.navigationBar.backgroundColor = .backgroundColor
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.setStatusBar(backgroundColor: UIColor.backgroundColor)
        navigationController?.navigationBar.setNeedsLayout()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
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
        
        
        let tapGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        
        if images.count > 0 {
            cell.imageView.image = images[indexPath.row]
            cell.imageView.isUserInteractionEnabled = true
        } else {
            cell.imageView.image = UIImage.asset(.placeholder)
            cell.imageView.isUserInteractionEnabled = false
        }
        cell.imageView.addGestureRecognizer(tapGestureRecognizer)
        
        return cell
    }
    
    @objc private func imageTapped(tapGestureRecognizer: UILongPressGestureRecognizer) {
        // swiftlint:disable force_cast
        _ = tapGestureRecognizer.view as! UIImageView
        let point = tapGestureRecognizer.view?.convert(CGPoint.zero, to: searchCollectionView)
        blockUser(index: point)
    }
    
    private func blockUser(index: CGPoint?) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "封鎖並檢舉此貼圖主人", style: .destructive, handler: { [weak self] _ in
            guard let indexPath = self?.searchCollectionView.indexPathForItem(at: index ?? CGPoint()) else { return }
            self?.postBlockData(indexPath: indexPath)
        }))
        alertController.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { _ in
        }))
        
        alertController.view.tintColor = UIColor.black
        self.present(alertController, animated: true)
    }
    
    private func postBlockData(indexPath: IndexPath) {
        DetailDataProvider.shared.postBlockData(
            userId: userID, blockId: searchDataObjc?.data[indexPath.item].propertyId ?? ""
        )
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
        fetchSearchData(userId: userID, tag: nil)
    }
    
    private func fetchSearchData(userId: String, tag: String?) {
        searchDataProvider.fetchSearchData(userId: userId, tag: tag) { [weak self] result in
            switch result {
            case .success(let data):
                print("\(data)")
                self?.searchDataObjc = data
                guard let searchDataObjc = self?.searchDataObjc else { return }
                if searchDataObjc.data.isEmpty {
                    self?.searchCollectionView.reloadData()
                }
                
                if searchDataObjc.data.count > 0 {
                    // placeholder
                    self?.images = [UIImage](repeating: UIImage.asset(.placeholder) ?? UIImage(), count: searchDataObjc.data.count)
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
    
    private func setUpNoResultLabel() {
        view.addSubview(showNoResultLabel)
        
        showNoResultLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            showNoResultLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            showNoResultLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            showNoResultLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 50),
            showNoResultLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -50)
        ])
        showNoResultLabel.text = "暫無搜尋結果"
        showNoResultLabel.textColor = UIColor.gray
        showNoResultLabel.contentMode = .center
    }
}

extension SearchViewController: UISearchBarDelegate, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        if images.count < indexPath.item + 1 { return }
        let image = images[indexPath.item]
        
        let detailTableViewVC = UIStoryboard.propertyDetail.instantiateViewController(withIdentifier: String(describing: DetailViewController.self)
        )
        guard let detailVC = detailTableViewVC as? DetailViewController else { return }
        
        detailVC.detailData = searchDataObjc?.data[indexPath.row]
        detailVC.detailPageImage = image
        detailVC.propertyId = searchDataObjc?.data[indexPath.row].propertyId ?? ""
        detailVC.imageOwnerName = searchDataObjc?.data[indexPath.row].name ?? ""
        
        show(detailVC, sender: nil)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchController.searchBar.text else {
            return
        }
        if text != "" {
            images.removeAll()
            searchBar.resignFirstResponder()
            fetchSearchData(userId: userID, tag: text)
        }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        fetchSearchData(userId: userID, tag: nil)
    }
}

enum SearchQuery: String {
    case video = "video"
    case image = "image"
}
