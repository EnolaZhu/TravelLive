//
//  DetailViewController.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/19.
//

import UIKit
import SwiftUI
import Lottie

class DetailViewController: BaseViewController {
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var sendCommentButton: UIButton!
    @IBOutlet weak var detailTableView: UITableView!
    let reportMaskView = UIView()
    let commentVC = CommentViewController()
    var allCommentData: CommentObject?
    var detailData: SearchData?
    var detailPageImage = UIImage()
    var avatarImage: UIImage? {
        didSet {
            detailTableView.reloadData()
        }
    }
    var avatarUrl: String?
    var propertyId = String()
    var imageOwnerName = String()
    var isLiked = Bool()
    var placeHolderImage = UIImage(named: "placeholder")
    var isFromProfile = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        detailTableView.rowHeight = UITableView.automaticDimension
        detailTableView.estimatedRowHeight = 200.0
        detailTableView.delegate = self
        detailTableView.dataSource = self
        detailTableView.separatorStyle = .none
        self.navigationController?.navigationBar.tintColor = UIColor.black
        
        setUpTableView()
        
        if isFromProfile {
            getOwnerAvatar(avatarUrl ?? "")
        } else {
            getOwnerAvatar(detailData?.avatar ?? "")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // owner id 換成 property id   從 search 頁和圖片一起帶過來
        
        fetchComment(propertyId: propertyId, userId: userID)
        tabBarController?.tabBar.isHidden = true
    }
    
    private func setUpTableView() {
        detailTableView.registerCellWithNib(identifier: String(describing: DetailViewImageCell.self), bundle: nil)
        detailTableView.registerCellWithNib(identifier: String(describing: DetailViewCommentCell.self), bundle: nil)
    }
    
    private func fetchComment(propertyId: String, userId: String) {
        DetailDataProvider.shared.fetchCommentData(propertyId: propertyId, userId: userId) { [weak self] result in
            switch result {
            case .success(let data):
                self?.allCommentData = data
                guard (self?.allCommentData) != nil else { return }
                self?.detailTableView.reloadData()
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func getOwnerAvatar(_ imageUrl: String) {
        ImageManager.shared.fetchImage(imageUrl: imageUrl) { [weak self] image in
            self?.avatarImage = image
        }
    }
}

extension DetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1 + (allCommentData?.message.count ?? 0)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: DetailViewImageCell.self), for: indexPath)
            guard let imageCell = cell as? DetailViewImageCell else { return cell }
            imageCell.reportButton.addTarget(self, action: #selector(showReportPage(_:)), for: .touchUpInside)
//            imageCell.commentButton.addTarget(self, action: #selector(showCommentPage(_:)), for: .touchUpInside)
            imageCell.loveButton.addTarget(self, action: #selector(clickLoveButton), for: .touchUpInside)
            
            imageCell.shareButton.addTarget(self, action: #selector(shareLink(_:)), for: .touchUpInside)
            
            imageCell.layoutCell(mainImage: detailPageImage, propertyId: propertyId, isLiked: allCommentData?.isLiked ?? Bool(), imageOwnerName: imageOwnerName, avatar: (avatarImage ?? placeHolderImage)!)
            
            if isLiked {
                imageCell.loveButton.setImage(UIImage(named: "theheart"), for: .normal)
            }
            
            // Avatar gesture
            let tapAvatarGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(avatarTapped(tapGestureRecognizer:)))
            // ImageView gesture
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
            imageCell.userUploadImageView.isUserInteractionEnabled = true
            imageCell.userAvatarimage.isUserInteractionEnabled = true
            imageCell.userAvatarimage.addGestureRecognizer(tapAvatarGestureRecognizer)
            imageCell.userUploadImageView.addGestureRecognizer(tapGestureRecognizer)
            
            return imageCell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: DetailViewCommentCell.self), for: indexPath)
            guard let commentCell = cell as? DetailViewCommentCell else { return cell }
            
            if allCommentData == nil {
                return UITableViewCell()
            } else {
                ImageManager.shared.fetchImage(imageUrl: allCommentData?.message[indexPath.row - 1].avatar ?? "") { [weak self] image in
                    self?.avatarImage = image
                }
                commentCell.layoutCell(name: allCommentData?.message[indexPath.row - 1].name ?? "", comment: allCommentData?.message[indexPath.row - 1].message ?? "", avatar: (avatarImage ?? placeHolderImage)!, time: allCommentData?.message[indexPath.row - 1].timestamp ?? "")
            }
            return commentCell
        }
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        // swiftlint:disable force_cast
        _ = tapGestureRecognizer.view as! UIImageView
        LottieAnimationManager.shared.setUplottieAnimation(name: "Hearts moving", excitTime: 4, view: self.view, ifPulling: false)
        // change heart button
        NotificationCenter.default.post(name: .changeLoveButtonKey, object: nil)
    }
    
    @objc func avatarTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        let profileViewController = UIStoryboard.profile.instantiateViewController(withIdentifier:
            String(describing: ProfileViewController.self)
        )

        guard let profileVC = profileViewController as? ProfileViewController else { return }
        profileVC.isFromOther = true
        show(profileVC, sender: nil)
    }
    
    @objc func shareLink(_ sender: UIButton) {
        let url = "https://travellive.page.link/?link=https://travellive-1d79e.web.app/WebRTCPlayer.html?live=Broccoli2"
        ShareManager.share.shareLink(textToShare: "Check out my app", shareUrl: url, thevVC: self, sender: sender)
    }
    
    @objc func showReportPage(_ sender: UIButton) {
        let reportVC = ReportViewController()
        reportVC.propertyOwnerId = detailData?.ownerId ?? ""
        reportVC.clickCloseButton = self
        reportVC.view.frame = CGRect(x: 0, y: UIScreen.height, width: UIScreen.width, height: 202)
        view.addSubview(reportMaskView)
        // Animation
        UIView.animate(withDuration: 0.3, delay: 0.01, options: .curveEaseInOut, animations: { [self] in
            reportVC.view.frame = CGRect(
                x: 0,
                y: CGFloat(UIScreen.height - CGFloat(250.0)),
                width: UIScreen.width,
                height: 250.0
            )
        }, completion: { _ in print("report page show")})
        view.addSubview(reportVC.view)
        addChild(reportVC)
    }
    
    @objc func showCommentPage(_ sender: UIButton) {
        view.addSubview(reportMaskView)
        commentVC.clickCloseButton = self
        commentVC.propertyId = propertyId
        self.view.addSubview(commentVC.view)
        self.addChild(commentVC)
    }
    
    func setUpMaskView() {
        reportMaskView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
        reportMaskView.frame = CGRect(x: 0, y: 0, width: UIScreen.width, height: UIScreen.height)
    }
    
    @objc func clickLoveButton(_ sender: UIButton) {
        if sender.hasImage(named: "theheart", for: .normal) {
            DetailDataProvider.shared.postLike(propertyId: propertyId, userId: userID, isLiked: false)
            
            LottieAnimationManager.shared.setUplottieAnimation(name: "Heart break", excitTime: 4, view: self.view, ifPulling: false)
            
            sender.setImage(UIImage.asset(.emptyHeart), for: .normal)
        } else {
            DetailDataProvider.shared.postLike(propertyId: propertyId, userId: userID, isLiked: true)
            LottieAnimationManager.shared.setUplottieAnimation(name: "Hearts moving", excitTime: 4, view: self.view, ifPulling: false)
            sender.setImage(UIImage.asset(.theheart), for: .normal)
        }
    }
}

extension DetailViewController: CloseMaskView, CloseCommentView {
    func clickCloseButton() {
        reportMaskView.removeFromSuperview()
    }
    
    func pressCloseButton() {
        reportMaskView.removeFromSuperview()
    }
}
