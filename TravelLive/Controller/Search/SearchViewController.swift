//
//  SearchViewController.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/11.
//

import UIKit
import FirebaseStorage
import MJRefresh
import Lottie

class SearchViewController: BaseViewController, UICollectionViewDataSource, GridLayoutDelegate {
    
    // MARK: - Property
    @IBOutlet weak var searchCollectionView: UICollectionView!
    @IBOutlet weak var gridLayout: GridLayout!
    
    var arrInstaBigCells = [Int]()
    var images = [UIImage]()
    var searchDataObjc: SearchDataObject?
    var searchController = UISearchController()
    let searchDataProvider = SearchDataProvider()
    lazy var showNoResultLabel = UILabel()
    let animationView = AnimationView(name: LottieAnimation.lodingAnimation.title)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getSearchData()
        
        navigationItem.searchController = searchController
        searchCollectionView.isUserInteractionEnabled = true
        arrInstaBigCells.append(1)
        addRefreshHeader()
        
        // fix searchbar hidden when change view
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchBar.delegate = self
        searchController.searchBar.keyboardType = .asciiCapable
        
        var tempStorage = false
        for _ in 1...21 {
            if tempStorage {
                arrInstaBigCells.append(arrInstaBigCells.last! + 10)
            } else {
                arrInstaBigCells.append(arrInstaBigCells.last! + 8)
            }
            tempStorage = !tempStorage
        }
        
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
    
    // MARK: - Method
    @objc private func imageTapped(tapGestureRecognizer: UILongPressGestureRecognizer) {
        let point = tapGestureRecognizer.view?.convert(CGPoint.zero, to: searchCollectionView)
        blockUser(index: point)
    }
    
    private func blockUser(index: CGPoint?) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "封鎖此貼圖主人", style: .destructive, handler: { [weak self] _ in
            guard let indexPath = self?.searchCollectionView.indexPathForItem(at: index ?? CGPoint()) else { return }
            self?.postBlockData(blockId: self?.searchDataObjc?.data[indexPath.item].ownerId ?? "")
        }))
        alertController.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        
        alertController.view.tintColor = UIColor.black
        
        // iPad specific code
        IpadAlertManager.ipadAlertManager.makeAlertSuitIpad(alertController, view: self.view)
        
        self.present(alertController, animated: true)
    }
    
    private func postBlockData(blockId: String) {
        if UserManager.shared.userID == blockId {
            self.view.makeToast(BlockText.blockSelf.text, duration: 0.5, position: .center)
            return
        } else {
            DetailDataProvider.shared.postBlockData(userId: UserManager.shared.userID, blockId: blockId) { [weak self] resultString in
                if resultString == "" {
                    self?.images.removeAll()
                    self?.getSearchData()
                } else {
                    self?.view.makeToast(BlockText.blockFail.text, duration: 0.5, position: .center)
                }
            }
        }
    }
    
    // refresh Data by pull-down
    private func addRefreshHeader() {
        MJRefreshNormalHeader { [weak self] in
            self?.getSearchData()
        }.autoChangeTransparency(true)
            .link(to: searchCollectionView)
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
        fetchSearchData(userId: UserManager.shared.userID, tag: nil)
    }
    
    private func fetchSearchData(userId: String, tag: String?) {
        LottieAnimationManager.shared.showLoadingAnimation(animationView: animationView, view: self.view, name: LottieAnimation.lodingAnimation.title)
        searchDataProvider.fetchSearchData(userId: userId, tag: tag) { [weak self] result in
            switch result {
            case .success(let data):
                self?.searchDataObjc = data
                guard let searchDataObjc = self?.searchDataObjc else { return }
                if searchDataObjc.data.isEmpty {
                    self?.searchCollectionView.reloadData()
                }
                
                LottieAnimationManager.shared.stopAnimation(animationView: self?.animationView)
                
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
                } else {
                    self?.view.makeToast("暫無搜尋結果", duration: 0.5, position: .center)
                }
                self?.searchCollectionView.reloadData()
                self?.searchCollectionView.mj_header?.endRefreshing()
                
            case .failure:
                self?.view.makeToast("搜尋失敗", duration: 0.5, position: .center)
            }
        }
    }
    
    private func getImage(searchData: SearchData, imageUrl: String, index: Int) {
        // image
        ImageManager.shared.fetchImage(imageUrl: imageUrl) { [weak self] image in
            self?.images[index] = image
            self?.searchCollectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
        }
    }
    
    private func getThumbnail(searchData: SearchData, index: Int) {
        // video GIF
        ImageManager.shared.fetchUserGIF(thumbnailUrl: searchData.thumbnailUrl) { [weak self] gif in
            self?.images[index] = gif
            self?.searchCollectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
        }
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
            fetchSearchData(userId: UserManager.shared.userID, tag: text.lowercased())
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        fetchSearchData(userId: UserManager.shared.userID, tag: nil)
    }
}

private enum SearchQuery {
    case video
    case image
}
