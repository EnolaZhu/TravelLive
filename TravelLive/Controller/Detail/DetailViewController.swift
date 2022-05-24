//
//  DetailViewController.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/19.
//

import UIKit
import Lottie
import Toast_Swift
import CoreAudio

class DetailViewController: BaseViewController, UIGestureRecognizerDelegate {
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var sendCommentButton: UIButton!
    @IBOutlet weak var detailTableView: UITableView!
    let reportMaskView = UIView()
    let animationView = AnimationView(name: LottieAnimation.lodingAnimation.title)
    var allCommentData: CommentObject?
    var detailData: SearchData?
    var detailPageImage = UIImage()
    var avatarImage: UIImage?
    var commentImage: UIImage?
    var avatarUrl: String?
    var propertyId = String()
    var imageOwnerName = String()
    var isLiked = Bool()
    var isFromProfile = false
    var allMessageArray = [String]()
    var placeHolderImage = UIImage.asset(.placeholder)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpTableView()
        setUpSubview()
        //        setGestureOnCell()
        
        if isFromProfile {
            getOwnerAvatar(avatarUrl ?? "")
        } else {
            getOwnerAvatar(detailData?.avatar ?? "")
        }
        
        navigationController?.navigationBar.tintColor = UIColor.primary
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        LottieAnimationManager.shared.showLoadingAnimation(animationView: animationView, view: self.view, name: LottieAnimation.lodingAnimation.title)
        
        fetchComment(propertyId: propertyId, userId: UserManager.shared.userID)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        setUpButtonBasicColor(sendCommentButton, UIImage.asset(.send) ?? UIImage(), color: UIColor.primary)
    }
    
    private func setGestureOnCell() {
        let longPressGesture: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress(sender:)))
        longPressGesture.delegate = self
        self.detailTableView.addGestureRecognizer(longPressGesture)
    }
    
    @objc private func handleLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let touchPoint = sender.location(in: detailTableView)
            if let indexPath = detailTableView.indexPathForRow(at: touchPoint) {
                createBlockAlert(index: indexPath.row - 1)
            }
        }
    }
    
    private func createBlockAlert(index: Int) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "封鎖此則留言的主人", style: .destructive, handler: { [weak self] _ in
            self?.postBlockCommentData(blockId: self?.allCommentData?.message[index].reviewerId ?? "")
        }))
        alertController.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { _ in
        }))
        
        alertController.view.tintColor = UIColor.black
        
        // iPad specific code
        IpadAlertManager.ipadAlertManager.makeAlertSuitIpad(alertController, view: self.view)
        
        self.present(alertController, animated: true)
    }
    
    private func postBlockImageData(blockId: String) {
        if UserManager.shared.userID == blockId {
            self.view.makeToast(TextManager.blockSelf.text, duration: 0.5, position: .center)
        } else {
            DetailDataProvider.shared.postBlockData(userId: UserManager.shared.userID, blockId: blockId) { [weak self] result in
                if result == "" {
                    self?.navigationController?.popViewController(animated: true)
                } else {
                    self?.view.makeToast(TextManager.blockFail.text, duration: 0.5, position: .center)
                }
            }
        }
    }
    
    private func postBlockCommentData(blockId: String) {
        if UserManager.shared.userID == blockId {
            self.view.makeToast(TextManager.blockSelf.text, duration: 0.5, position: .center)
            return
        } else if detailData?.ownerId ?? "" == blockId {
            
            DetailDataProvider.shared.postBlockData(userId: UserManager.shared.userID, blockId: blockId) { [weak self] result in
                if result == "" {
                    self?.navigationController?.popViewController(animated: true)
                } else {
                    self?.view.makeToast(TextManager.blockFail.text, duration: 0.5, position: .center)
                }
            }
        } else {
            
            DetailDataProvider.shared.postBlockData(userId: UserManager.shared.userID, blockId: blockId) { [weak self] result in
                if result == "" {
                    self?.fetchComment(propertyId: self?.propertyId ?? "", userId: UserManager.shared.userID)
                } else {
                    self?.view.makeToast(TextManager.blockFail.text, duration: 0.5, position: .center)
                }
            }
        }
    }
    
    private func setUpTableView() {
        detailTableView.rowHeight = UITableView.automaticDimension
        detailTableView.estimatedRowHeight = 200.0
        detailTableView.delegate = self
        detailTableView.dataSource = self
        detailTableView.separatorStyle = .none
        detailTableView.backgroundColor = UIColor.backgroundColor
        
        detailTableView.registerCellWithNib(identifier: String(describing: DetailViewImageCell.self), bundle: nil)
        detailTableView.registerCellWithNib(identifier: String(describing: DetailViewCommentCell.self), bundle: nil)
    }
    
    private func setUpSubview() {
        commentTextField.placeholder = "發表評論"
        sendCommentButton.addTarget(self, action: #selector(sendComment), for: .touchUpInside)
        sendCommentButton.isEnabled = false
        view.backgroundColor = UIColor.backgroundColor
    }
    
    private func fetchComment(propertyId: String, userId: String) {
        DetailDataProvider.shared.fetchCommentData(propertyId: propertyId, userId: userId) { [weak self] result in
            switch result {
            case .success(let data):
                self?.allCommentData = data
                guard (self?.allCommentData) != nil else { return }
                LottieAnimationManager.shared.stopAnimation(animationView: self?.animationView)
                self?.detailTableView.reloadData()
                
            case .failure(let error):
                self?.view.makeToast("獲取評論失敗", duration: 1.0, position: .center)
            }
        }
    }
    
    private func getOwnerAvatar(_ imageUrl: String) {
        avatarImage = nil
        ImageManager.shared.fetchImage(imageUrl: imageUrl) { [weak self] image in
            self?.avatarImage = image
        }
    }
    
    @IBAction private func editComment(_ sender: UITextField) {
        if sender.text == "" {
            return
        } else {
            sendCommentButton.isEnabled = true
        }
    }
    
    
    @objc private func sendComment(_ sender: UIButton) {
        if commentTextField.text == "" {
            return
        } else {
            DetailDataProvider.shared.postComment(id: propertyId, reviewerId: UserManager.shared.userID, message: commentTextField.text ?? "") { [weak self] result in
                if result == "" {
                    self?.fetchComment(propertyId: self?.propertyId ?? "", userId: UserManager.shared.userID)
                } else {
                    self?.view.makeToast("失敗", duration: 0.5, position: .center)
                }
            }
            commentTextField.text = ""
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
            
            imageCell.backgroundColor = UIColor.backgroundColor
            
            imageCell.reportButton.addTarget(self, action: #selector(createBlockSheet(_:)), for: .touchUpInside)
            imageCell.loveButton.addTarget(self, action: #selector(clickLoveButton), for: .touchUpInside)
            imageCell.layoutCell(mainImage: detailPageImage, propertyId: propertyId, isLiked: allCommentData?.isLiked ?? Bool(), imageOwnerName: imageOwnerName, avatar: (avatarImage ?? placeHolderImage)!)
            
            if isLiked {
                setUpButtonBasicColor(imageCell.loveButton, UIImage.asset(.theheart) ?? UIImage(), color: UIColor.primary)
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
            commentCell.backgroundColor = UIColor.backgroundColor
            commentCell.selectionStyle = .default
            
            let longPressGesture: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress(sender:)))
            longPressGesture.delegate = self
            cell.addGestureRecognizer(longPressGesture)
            
            if allCommentData == nil {
                return UITableViewCell()
            } else {
//                ImageManager.shared.fetchImage(imageUrl: allCommentData?.message[indexPath.row - 1].avatar ?? "") { [weak self] image in
//                    self?.commentImage = image
//                }
                ImageManager.shared.loadImage(imageView: commentCell.reviewerAvatarImage, url: allCommentData?.message[indexPath.row - 1].avatar ?? "")
                
                commentCell.layoutCell(name: allCommentData?.message[indexPath.row - 1].name ?? "", comment: allCommentData?.message[indexPath.row - 1].message ?? "", time: allCommentData?.message[indexPath.row - 1].timestamp ?? "")
            }
            return commentCell
        }
    }
    
    @objc private func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        LottieAnimationManager.shared.createlottieAnimation(name: LottieAnimation.heart.title, view: self.view, location: CGRect(x: 0, y: Int(UIScreen.height) / 4, width: 400, height: 400))
        // change heart button
        NotificationCenter.default.post(name: .changeLoveButtonKey, object: nil)
    }
    
    @objc private func avatarTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        let profileViewController = UIStoryboard.profile.instantiateViewController(withIdentifier: String(describing: ProfileViewController.self)
        )
        guard let profileVC = profileViewController as? ProfileViewController else { return }
        profileVC.propertyOwnerId = detailData?.ownerId ?? ""
        profileVC.isFromOther = true
        show(profileVC, sender: nil)
    }
    
    @objc private func createBlockSheet(_ sender: UIButton) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "封鎖此貼文的主人", style: .destructive, handler: { [weak self] _ in
            self?.postBlockImageData(blockId: self?.detailData?.ownerId ?? "")
        }))
        
        alertController.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        
        alertController.view.tintColor = UIColor.black
        
        // iPad specific code
        IpadAlertManager.ipadAlertManager.makeAlertSuitIpad(alertController, view: self.view)
        
        self.present(alertController, animated: true)
    }
    
    
    @objc private func clickLoveButton(_ sender: UIButton) {
        if sender.hasImage(named: "theheart", for: .normal) {
            DetailDataProvider.shared.postLike(propertyId: propertyId, userId: UserManager.shared.userID, isLiked: false)
            LottieAnimationManager.shared.createlottieAnimation(name: LottieAnimation.breakHeart.title, view: self.view, animationSpeed: 1, location: CGRect(x: 0, y: Int(UIScreen.height) / 8, width: 400, height: Int(UIScreen.height) + 50))
            
            setUpButtonBasicColor(sender, UIImage.asset(.emptyHeart) ?? UIImage(), color: UIColor.primary)
        } else {
            DetailDataProvider.shared.postLike(propertyId: propertyId, userId: UserManager.shared.userID, isLiked: true)
            
            LottieAnimationManager.shared.createlottieAnimation(name: LottieAnimation.heart.title, view: self.view, location: CGRect(x: 0, y: Int(UIScreen.height) / 4, width: 400, height: 400))
            setUpButtonBasicColor(sender, UIImage.asset(.theheart) ?? UIImage(), color: UIColor.primary)
        }
    }
}
