//
//  VideoWallViewController.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/5/11.
//

import UIKit
import Toast_Swift

class VideoWallViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    let videoWallTableViewCellIdentifier = "VideoWallTableViewCell"
    let loadingCellTableViewCellCellIdentifier = "LoadingCellTableViewCell"
    var resultDataObjc: SearchDataObject?
    var videoData: [SearchData]?
    var videoUrls = [String]()
    var imageUrls = [String]()
    lazy var blockButton = UIButton()
    lazy var avatarView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        fetchVideoData(userId: UserManager.shared.userID, tag: nil)
        tableView.isPagingEnabled = true
        
        var cellNib = UINib(nibName: videoWallTableViewCellIdentifier, bundle: nil)
        self.tableView.register(cellNib, forCellReuseIdentifier: videoWallTableViewCellIdentifier)
        cellNib = UINib(nibName: loadingCellTableViewCellCellIdentifier, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: loadingCellTableViewCellCellIdentifier)
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        NotificationCenter.default.addObserver(self, selector: #selector(self.appEnteredFromBackground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.tintColor = UIColor.primary
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        pausePlayeVideos()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        stopVideo()
        tabBarController?.tabBar.isHidden = false
    }
    
    private func stopVideo() {
        ASVideoPlayerController.sharedVideoPlayer.pausePlayeVideosFor(tableView: tableView, appEnteredFromBackground: true, isStopVideo: true)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        videoUrls.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: videoWallTableViewCellIdentifier, for: indexPath)
        guard let videoWallCell = cell as? VideoWallTableViewCell else { return cell }
        
        videoWallCell.configureCell(imageUrl: imageUrls[indexPath.row], videoUrl: videoUrls[indexPath.row], name: videoData?[indexPath.row].name ?? "")
        ImageManager.shared.loadImage(imageView: videoWallCell.avatarImageView, url: videoData?[indexPath.row].avatar ?? "")
        videoWallCell.blockButton.addTarget(self, action: #selector(blockVideoOwner(_:)), for: .touchUpInside)
        return videoWallCell
    }
                                            
    @objc private func blockVideoOwner(_ sender: UIButton) {
        let point = sender.convert(CGPoint.zero, to: tableView)
        guard let indexPath = tableView.indexPathForRow(at: point) else { return }
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "封鎖此人", style: .destructive, handler: { [weak self] _ in
            guard let self = self else { return }
            guard let ownerID = self.videoData?[indexPath.row].ownerId else { return }
            
            if ownerID == UserManager.shared.userID {
                self.view.makeToast("不可以封鎖自己哦", duration: 0.5, position: .center)
            } else {
                self.postBlockData(blockId: self.videoData?[indexPath.row].ownerId ?? "")
            }
        }))
        alertController.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        
        alertController.view.tintColor = UIColor.black
        // iPad specific code
        IpadAlertManager.ipadAlertManager.makeAlertSuitIpad(alertController, view: self.view)
        
        self.present(alertController, animated: true)
    }
    
    private func postBlockData(blockId: String) {
        DetailDataProvider.shared.postBlockData(userId: UserManager.shared.userID, blockId: blockId) { [weak self] result in
            guard let self = self else { return }
            if result == "" {
                self.fetchVideoData(userId: UserManager.shared.userID, tag: nil)
                self.tableView.reloadData()
            } else {
                self.view.makeToast("封鎖失敗", duration: 0.5, position: .center)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        view.safeAreaLayoutGuide.layoutFrame.height
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let videoCell = cell as? ASAutoPlayVideoLayerContainer, let _ = videoCell.videoURL {
            ASVideoPlayerController.sharedVideoPlayer.removeLayerFor(cell: videoCell)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pausePlayeVideos()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            pausePlayeVideos()
        }
    }
    
    func pausePlayeVideos() {
        ASVideoPlayerController.sharedVideoPlayer.pausePlayeVideosFor(tableView: tableView)
    }
    
    @objc func appEnteredFromBackground() {
        ASVideoPlayerController.sharedVideoPlayer.pausePlayeVideosFor(tableView: tableView, appEnteredFromBackground: true)
    }
    
    private func fetchVideoData(userId: String, tag: String?) {
        SearchDataProvider().fetchSearchData(userId: userId, tag: tag) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let data):
                self.resultDataObjc = data
                guard let resultDataObjc = self.resultDataObjc else { return }
                self.videoData = resultDataObjc.data.filter({ $0.type == "video" })
                guard let videoData = self.videoData else { return }
                
                for index in 0..<videoData.count {
                    self.videoUrls.append(videoData[index].fileUrl)
                    self.imageUrls.append(videoData[index].videoImageUrl)
                }
                self.tableView.reloadData()
                
            case .failure:
                self.view.makeToast("搜尋影片失敗", duration: 1, position: .center)
            }
        }
    }
}
