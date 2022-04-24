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
    let detailTableView = UITableView()
    let reportMaskView = UIView()
    let commentVC = CommentViewController()
    var allCommentData: CommentObject?
    var detailPageImage = UIImage()
    var avatarImage = UIImage()
    var propertyId = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        detailTableView.rowHeight = UITableView.automaticDimension
        detailTableView.estimatedRowHeight = 200.0
        detailTableView.delegate = self
        detailTableView.dataSource = self
        detailTableView.separatorStyle = .none
        
        setUpTableView()
        setUpMaskView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // owner id 換成 property id   從 search 頁和圖片一起帶過來
        
        fetchComment(propertyId: propertyId, userId: "Enola")
        tabBarController?.tabBar.isHidden = true
    }
    
    private func setUpTableView() {
        self.view.addSubview(detailTableView)
        
        detailTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            detailTableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0),
            detailTableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0),
            detailTableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            detailTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)])
        
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
}

extension DetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1 + (allCommentData?.message.count ?? 0)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: DetailViewImageCell.self), for: indexPath)
            guard let imageCell = cell as? DetailViewImageCell else { return cell }
            
            imageCell.propertyId = propertyId
            imageCell.reportButton.addTarget(self, action: #selector(showReportPage(_:)), for: .touchUpInside)
            imageCell.commentButton.addTarget(self, action: #selector(showCommentPage(_:)), for: .touchUpInside)
            imageCell.loveButton.addTarget(self, action: #selector(clickLoveButton), for: .touchUpInside)
            imageCell.layoutCell(mainImage: detailPageImage, isLiked: allCommentData?.isLiked ?? Bool())
            // ImageView gesture
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
            imageCell.userUploadImageView.isUserInteractionEnabled = true
            imageCell.userUploadImageView.addGestureRecognizer(tapGestureRecognizer)
            return imageCell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: DetailViewCommentCell.self), for: indexPath)
            guard let commentCell = cell as? DetailViewCommentCell else { return cell }
            
            if allCommentData == nil {
                return UITableViewCell()
            } else {
                ImageManager.shared.fetchStorageImage(imageUrl: allCommentData?.message[indexPath.row - 1].avatar ?? "") { [weak self] image in
                    self?.avatarImage = image
                }
                commentCell.layoutCell(name: allCommentData?.message[indexPath.row - 1].reviewerId ?? "", comment: allCommentData?.message[indexPath.row - 1].message ?? "", avatar: avatarImage, time: allCommentData?.message[indexPath.row - 1].timestamp ?? "")
            }
            return commentCell
        }
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        // swiftlint:disable force_cast
        _ = tapGestureRecognizer.view as! UIImageView
        setUpHeartAnimation(name: "Hearts moving")
        // change heart button
        NotificationCenter.default.post(name: .changeLoveButtonKey, object: nil)
    }
    
    @objc func showReportPage(_ sender: UIButton) {
        let reportVC = ReportViewController()
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
            DetailDataProvider.shared.postLike(propertyId: propertyId, userId: "Enola", isLiked: false)
            setUpHeartAnimation(name: "Heart break")
            sender.setImage(UIImage.asset(.emptyHeart), for: .normal)
        } else {
            DetailDataProvider.shared.postLike(propertyId: propertyId, userId: "Enola", isLiked: true)
            setUpHeartAnimation(name: "Hearts moving")
            sender.setImage(UIImage.asset(.theheart), for: .normal)
        }
    }
    
    func setUpHeartAnimation(name: String) {
        let animationView = AnimationView(name: name)
        animationView.frame = CGRect(x: 0, y: 0, width: 400, height: 400)
        animationView.center = self.view.center
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .playOnce
        animationView.animationSpeed = 4
        view.addSubview(animationView)
        animationView.play()
        animationView.play { isCompleted in
            if isCompleted {
                animationView.removeFromSuperview()
            }
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
