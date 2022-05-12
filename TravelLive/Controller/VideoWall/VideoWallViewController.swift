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
    var videoUrls = [String]()
    var imageUrls = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        fetchVideoData(userId: userID, tag: nil)
        
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
        
        videoWallCell.configureCell(imageUrl: imageUrls[indexPath.row], videoUrl: videoUrls[indexPath.row])
        return videoWallCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        view.safeAreaLayoutGuide.layoutFrame.height + view.safeAreaInsets.bottom
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
            switch result {
            case .success(let data):
                self?.resultDataObjc = data
                guard let resultDataObjc = self?.resultDataObjc else { return }
                let videoData = resultDataObjc.data.filter({ $0.type == "video" })
                
                for index in 0..<videoData.count {
                    self?.videoUrls.append(videoData[index].fileUrl)
                    self?.imageUrls.append(videoData[index].videoImageUrl)
                }
                self?.tableView.reloadData()
                
            case .failure:
                self?.view.makeToast("搜尋影片失敗", duration: 1, position: .center)
            }
        }
    }
}
