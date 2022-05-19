//
//  ProfileViewController.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/14.
//

import UIKit
import CoreServices
import GoogleMobileAds
import FirebaseAuth
import Toast_Swift
import MJRefresh
import Lottie

class ProfileViewController: UIViewController {
    
    //    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var profileView: UICollectionView!
    let imagePickerController = UIImagePickerController()
    fileprivate var imageWidth: CGFloat = 0
    var userPropertyData: ProfilePropertyObject?
    var propertyImages = [UIImage]() {
        didSet {
            profileView.reloadData()
        }
    }
    var profileInfo: ProfileObject?
    var imagePicker: ImagePicker!
    var isFromOther = false
    var propertyOwnerId = String()
    var displayName: String? {
        didSet {
            profileView.reloadData()
        }
    }
    var avatarImage: UIImage? {
        didSet {
            profileView.reloadData()
        }
    }
    lazy var postButton: UIButton = {
        let postButton = UIButton(frame: CGRect(x: UIScreen.width - 100, y: UIScreen.height - 180, width: 88, height: 88))
        postButton.tintColor = UIColor.primary
        postButton.setImage(UIImage.asset(.add), for: UIControl.State())
        return postButton
    }()
    
    let animationView = AnimationView(name: "loading")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        LottieAnimationManager.shared.showLoadingAnimation(animationView: animationView, view: self.view, name: "loading")
        
        // Add observer of change images
        NotificationCenter.default.addObserver(self, selector: #selector(self.showUserProperty(_:)), name: .showUserPropertyKey, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.showLikedProperty(_:)), name: .showLikedPropertyKey, object: nil)
        // change avatar
        NotificationCenter.default.addObserver(self, selector: #selector(self.showEditView(_:)), name: .showEditAvatarViewKey, object: nil)
        // Add advertisement
        //        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        //        bannerView.rootViewController = self
        //        bannerView.load(GADRequest())
        
        profileView.delegate = self
        profileView.dataSource = self
        
        profileView.contentInsetAdjustmentBehavior = .never
        profileView.showsVerticalScrollIndicator = false
        profileView.backgroundColor = UIColor.backgroundColor
        
        if isFromOther {
            getUserInfo(id: propertyOwnerId)
            getUserProperty(id: UserManager.shared.userID, byUser: propertyOwnerId)
        } else {
            addRefreshHeader()
            getUserInfo(id: UserManager.shared.userID)
            getUserProperty(id: UserManager.shared.userID, byUser: UserManager.shared.userID)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
        imageWidth = ((UIScreen.width - 4) / 3)  - 2
        
        if !isFromOther {
            postButton.addTarget(self, action: #selector(postImage(_:)), for: .touchUpInside)
            view.addSubview(postButton)
            navigationItem.rightBarButtonItems = [UIBarButtonItem(image: UIImage.asset(.menu)?.maskWithColor(color: UIColor.primary), style: .plain, target: self, action: #selector(createAlertSheet))]
        } else {
            navigationItem.rightBarButtonItems = [UIBarButtonItem(image: UIImage.asset(.menu)?.maskWithColor(color: UIColor.primary), style: .plain, target: self, action: #selector(blockUser))]
        }
        
        setNeedsStatusBarAppearanceUpdate()
        navigationController?.navigationBar.backgroundColor = .backgroundColor
        navigationItem.rightBarButtonItem?.tintColor = UIColor.primary
        // default segment index
        NotificationCenter.default.post(name: .defaultSegmentIndexKey, object: nil, userInfo: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationController?.setStatusBar(backgroundColor: UIColor.backgroundColor)
        self.navigationController?.navigationBar.setNeedsLayout()
    }
    
    @objc func showEditView(_ notification: NSNotification) {
        self.openCameraActionSheet { cameraState in
            if let state = cameraState {
                self.openImagePicker(with: state)
            }
        }
    }
    
    private func addRefreshHeader() {
        MJRefreshNormalHeader { [weak self] in
            self?.getUserProperty(id: UserManager.shared.userID, byUser: UserManager.shared.userID)
        }.autoChangeTransparency(true)
            .link(to: profileView)
    }
    
    // show selected image
    private func presentCropViewController(_ image: UIImage) {
        let cropViewController = CropViewController(image: image) { [unowned self] croppedImage in
            self.avatarImage = croppedImage ?? UIImage()
            
            // Put user selected image to firebase
            let imageBase64 = ConvertImageTOBase64Manager().convertImageToBase64String(image: croppedImage ?? UIImage())
            ProfileProvider.shared.putUserAvatar(userID: UserManager.shared.userID, photoBase64: imageBase64)
        }
        self.present(cropViewController, animated: true, completion: nil)
    }
    
    // async 取回選擇的 image
    private func openImagePicker(with state: CameraState) {
        self.imagePicker = ImagePicker(fromController: self, state: state, compltionClouser: { [unowned self] pickupResult in
            switch pickupResult {
            case .success(let selectedImage):
                DispatchQueue.main.async {
                    self.presentCropViewController(selectedImage)
                }
            case .error:
                self.view.makeToast("請去設定中打開權限方能使用哦", duration: 2, position: .center)
            }
        })
    }
    
    private func getUserInfo(id: String) {
        ProfileProvider.shared.fetchUserData(userId: id) { [weak self] result in
            switch result {
            case .success(let data):
                self?.profileInfo = data
                self?.displayName = data.name
                
                ImageManager.shared.fetchImageWithoutCache(imageUrl: data.avatar) { [weak self] image in
                    self?.avatarImage = image
                    self?.profileView.reloadData()
                }
            case .failure(let error):
                print(error)
                self?.view.makeToast("失敗，請稍後再試。", duration: 1, position: .center)
            }
        }
    }
    
    func getUserProperty(id: String, byUser: String?) {
        propertyImages.removeAll()
        
        ProfileProvider.shared.fetchUserPropertyData(userId: id, byUser: byUser) { [weak self] result in
            switch result {
            case .success(let data):
                self?.userPropertyData = data
                guard let userPropertyData = self?.userPropertyData else { return }
                
                if userPropertyData.data.count > 0 {
                    
                    for index in 0...userPropertyData.data.count - 1 {
                        if userPropertyData.data[index].thumbnailUrl == "" {
                            self?.getImage(imageUrl: userPropertyData.data[index].fileUrl)
                        } else {
                            self?.getUserThumbnail(property: userPropertyData.data[index], index: index)
                        }
                    }
                }
                LottieAnimationManager.shared.stopAnimation(animationView: self?.animationView)
                
                self?.profileView.reloadData()
                self?.profileView.mj_header?.endRefreshing()
                
            case .failure:
                self?.view.makeToast("失敗", duration: 1, position: .center)
            }
        }
    }
    
    private func getLikedProperty(id: String) {
        propertyImages.removeAll()
        userPropertyData?.data.removeAll()
        
        ProfileProvider.shared.fetchUserLikedData(userId: id) { [weak self] data in
            switch data {
            case .success(let data):
                self?.userPropertyData = data
                guard let userPropertyData = self?.userPropertyData else { return }
                
                if userPropertyData.data.count > 0 {
                    
                    for index in 0...userPropertyData.data.count - 1 {
                        if userPropertyData.data[index].thumbnailUrl == "" {
                            self?.getImage(imageUrl: userPropertyData.data[index].fileUrl)
                        } else {
                            self?.getUserThumbnail(property: userPropertyData.data[index], index: index)
                        }
                    }
                }
            case .failure:
                self?.view.makeToast("失敗", duration: 0.5, position: .center)
            }
        }
    }
    
    private func getImage(imageUrl: String) {
        ImageManager.shared.fetchImage(imageUrl: imageUrl) { [weak self] image in
            self?.propertyImages.append(image)
            self?.profileView.reloadData()
        }
    }
    
    private func getUserThumbnail(property: Property, index: Int) {
        ImageManager.shared.fetchUserGIF(thumbnailUrl: property.thumbnailUrl) { [weak self] gif in
            self?.propertyImages.append(gif)
            self?.profileView.reloadData()
        }
    }
    
    @objc private func showUserProperty(_ notification: NSNotification) {
        getUserProperty(id: UserManager.shared.userID, byUser: UserManager.shared.userID)
        postButton.isHidden = false
    }
    
    @objc private func showLikedProperty(_ notification: NSNotification) {
        getLikedProperty(id: UserManager.shared.userID)
        postButton.isHidden = true
    }
    
    @objc private func createAlertSheet() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "編輯", style: .default, handler: { [weak self] _ in
            self?.createModifyNameAlert()
        }))
        alertController.addAction(UIAlertAction(title: "登出", style: .destructive, handler: { [weak self] _ in
            self?.signOut()
        }))
        alertController.addAction(UIAlertAction(title: "刪除", style: .destructive, handler: { [weak self] _ in
            ProfileProvider.shared.deleteAccount(userId: UserManager.shared.userID)
            self?.signOut()
        }))
        alertController.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { _ in
        }))
        
        alertController.view.tintColor = UIColor.black
        
        // iPad specific code
        if UIDevice.current.userInterfaceIdiom == .pad {
            alertController.popoverPresentationController?.sourceView = self.view
            let xOrigin = self.view.bounds.width / 2
            let popoverRect = CGRect(x: xOrigin, y: 0, width: 1, height: 1)
            alertController.popoverPresentationController?.sourceRect = popoverRect
            alertController.popoverPresentationController?.permittedArrowDirections = .up
        }
        self.present(alertController, animated: true)
    }
    
    @objc private func blockUser() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "封鎖此人", style: .destructive, handler: { [weak self] _ in
            self?.postBlockData()
        }))
        alertController.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { _ in
        }))
        
        alertController.view.tintColor = UIColor.black
        // iPad specific code
        if UIDevice.current.userInterfaceIdiom == .pad {
            alertController.popoverPresentationController?.sourceView = self.view
            
            let xOrigin = self.view.bounds.width / 2
            
            let popoverRect = CGRect(x: xOrigin, y: 0, width: 1, height: 1)
            
            alertController.popoverPresentationController?.sourceRect = popoverRect
            
            alertController.popoverPresentationController?.permittedArrowDirections = .up
        }
        
        self.present(alertController, animated: true)
    }
    
    private func postBlockData() {
        DetailDataProvider.shared.postBlockData(userId: UserManager.shared.userID, blockId: propertyOwnerId) { [weak self] result in
            if result == "" {
                self?.navigationController?.popToRootViewController(animated: true)
//                self?.dismiss(animated: true, completion: nil)
            } else {
                self?.view.makeToast("封鎖失敗", duration: 0.5, position: .center)
            }
        }
    }
    
    // User sign out
    private func signOut() {
        do {
            try Auth.auth().signOut()
            UserManager.shared.userID = ""
            self.view.makeToast("登出成功", duration: 0.5, position: .center)
            // Sign out back to login vc
            backToLoginView()
        } catch {
            print(error)
        }
    }
    
    private func backToLoginView() {
        let loginViewController = UIStoryboard.main.instantiateViewController(withIdentifier: String(describing: LoginViewController.self)) as? LoginViewController
        guard let loginVC = loginViewController else { return }
        loginVC.modalPresentationStyle = .fullScreen
        present(loginVC, animated: false)
    }
    
    @objc private func postImage(_ sender: UIButton) {
        imagePickerController.delegate = self
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            // 如果可以，指定 UIImagePickerController 的照片來源為 照片圖庫 (.photoLibrary)，並 present UIImagePickerController
            imagePickerController.sourceType = .photoLibrary
            if let mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary) {
                imagePickerController.mediaTypes = mediaTypes
            }
            self.present(imagePickerController, animated: true, completion: nil)
        }
    }
    
    //    @objc private func hideBanner(_ button: UIButton) {
    //        bannerView.isHidden = true
    //    }
    
    private func createTemporaryURLforVideoFile(url: NSURL) -> NSURL {
        // Create the temporary directory.
        let temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        // create a temporary file for us to copy the video to.
        let temporaryFileURL = temporaryDirectoryURL.appendingPathComponent(url.lastPathComponent ?? "")
        // Attempt the copy.
        do {
            try FileManager().copyItem(at: url.absoluteURL!, to: temporaryFileURL)
        } catch {
            print("There was an error copying the video file to the temporary location.")
        }
        return temporaryFileURL as NSURL
    }
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        let uploadDate = Date()
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "SSSSSS"
        let uploadTimestamp = Int(uploadDate.timeIntervalSince1970)
        let storageRefPath = UserManager.shared.userID + "_" + "\(uploadTimestamp)" + dateFormat.string(from: uploadDate)
        
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            // Image Labeling
            ImageLabelingManager.shared.getImageLabel(inputImage: pickedImage) { [weak self] data in
                var result = String()
                for index in 0..<data.count {
                    result += data[index].text.lowercased() + (index == data.count - 1 ? "" : ",")
                }
                var storageRefPathWithTag = storageRefPath + (result.isEmpty ? "" : ("_" + result))
                storageRefPathWithTag = storageRefPathWithTag.replacingOccurrences(of: " ", with: "")
                
                let imageUrl = info[UIImagePickerController.InfoKey.imageURL] as? URL
                guard let imgUrl = imageUrl else { return }
                PhotoVideoManager.shared.uploadFileFromIo(url: String(describing: imgUrl), child: storageRefPathWithTag) { [weak self] result in
                    if result == "" {
                        self?.view.makeToast("上傳成功", duration: 0.5, position: .center)
                        self?.getUserInfo(id: UserManager.shared.userID)
                        self?.getUserProperty(id: UserManager.shared.userID, byUser: UserManager.shared.userID)
                    } else {
                        self?.view.makeToast("失敗", duration: 0.5, position: .center)
                    }
                }
            }
        }
        
        if let mediaUrl = info[.mediaURL] as? URL {
            // Upload video file
            let videoUrl = createTemporaryURLforVideoFile(url: mediaUrl as NSURL)
            PhotoVideoManager.shared.uploadFileFromIo(url: String(describing: videoUrl), child: storageRefPath) { [weak self] result in
                if result == "" {
                    self?.view.makeToast("上傳成功", duration: 0.5, position: .center)
                } else {
                    self?.view.makeToast("失敗", duration: 0.5, position: .center)
                }
            }
            // Extract frame from video
            PhotoVideoManager.shared.getImageFromVideo(url: mediaUrl, at: TimeInterval(uploadTimestamp)) { image in
                let storageRefImagePath = "videoimage_" + UserManager.shared.userID + "_" + "\(uploadTimestamp)" + dateFormat.string(from: uploadDate)
                guard let image = image else { return }
                PhotoVideoManager.shared.uploadFileFromMemory(image: image, child: storageRefImagePath) { result in
                    if result == "" {
                        print("extra frame from video success")
                    } else {
                        print("extra frame from video falil")
                    }
                }
            }
            
            // Convert video type to GIF
            let storageRefGifPath = "thumbnail_" + UserManager.shared.userID + "_" + "\(uploadTimestamp)" + dateFormat.string(from: uploadDate)
            GIFManager.shared.convertMp4ToGIF(fileURL: mediaUrl) { [weak self] result in
                switch result {
                case .success(let urlOfGIF):
                    // Upload GIF file
                    PhotoVideoManager.shared.uploadFileFromIo(url: urlOfGIF, child: storageRefGifPath) { [weak self] result in
                        if result == "" {
                            self?.view.makeToast("上傳成功", duration: 0.5, position: .center)
                            self?.getUserInfo(id: UserManager.shared.userID)
                            self?.getUserProperty(id: UserManager.shared.userID, byUser: UserManager.shared.userID)
                        } else {
                            self?.view.makeToast("失敗", duration: 0.5, position: .center)
                        }
                    }
                case .failure:
                    print("Failed")
                }
            }
        }
        imagePickerController.dismiss(animated: true, completion: nil)
    }
}

extension ProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    // Set up header
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "ProfileHeader", for: indexPath) as? ProfileHeader else { fatalError("Couldn't create header") }
        
        if isFromOther {
            header.changePropertySegment.isHidden = true
            header.avatarImageView.isUserInteractionEnabled = false
        }
        
        if displayName == nil {
            header.layoutProfileHeader(avatar: (avatarImage ?? UIImage(named: "placeholder"))!, displayName: "")
        } else {
            header.layoutProfileHeader(avatar: (avatarImage ?? UIImage(named: "placeholder"))!, displayName: displayName ?? "")
        }
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        propertyImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ProfileCollectionCell.self), for: indexPath) as? ProfileCollectionCell else {
            fatalError("Couldn't create cell")
        }
        // Placeholder
        cell.layoutCell(image: UIImage(named: "placeholder") ?? UIImage())
        // ImageView gesture
        let tapGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        if isFromOther {
            cell.profileImageView.isUserInteractionEnabled = false
        } else {
            cell.profileImageView.isUserInteractionEnabled = true
        }
        cell.profileImageView.addGestureRecognizer(tapGestureRecognizer)
        
        if propertyImages.isEmpty {
            cell.layoutCell(image: UIImage(named: "placeholder") ?? UIImage())
        } else {
            cell.layoutCell(image: propertyImages[indexPath.row])
        }
        
        return cell
    }
    
    @objc func imageTapped(tapGestureRecognizer: UILongPressGestureRecognizer) {
        // swiftlint:disable force_cast
        _ = tapGestureRecognizer.view as! UIImageView
        let point = tapGestureRecognizer.view?.convert(CGPoint.zero, to: profileView)
        createDeleteAlert(index: point)
    }
    
    private func createDeleteAlert(index: CGPoint?) {
        let deleteAlert = UIAlertController(
            title: "提示",
            message: "你確定要刪除這張圖片嗎",
            preferredStyle: .alert)
        let okAction = UIAlertAction(title: "確定", style: .default, handler: { (_: UIAlertAction!) -> Void in
            guard let indexPath = self.profileView.indexPathForItem(at: index ?? CGPoint()) else { return }
            // delete image from local
            self.propertyImages.remove(at: indexPath.row)
            // delete image from database
            ProfileProvider.shared.deleteSpecificProperty(propertyId: self.userPropertyData?.data[indexPath.row].propertyId ?? ""
            )
            self.profileView.reloadData()
        })
        deleteAlert.view.tintColor = UIColor.black
        deleteAlert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        deleteAlert.addAction(okAction)
        self.present(deleteAlert, animated: true, completion: nil)
    }
    
    private func createModifyNameAlert() {
        let controller = UIAlertController(title: "名字", message: "修改的名字只在 APP 內使用哦", preferredStyle: .alert)
        controller.addTextField { textField in
            textField.placeholder = "名字"
        }
        
        let okAction = UIAlertAction(title: "完成", style: .default) { [unowned controller] _ in
            if controller.textFields?[0].text == "" {
                self.view.makeToast("名字不可為空哦", duration: 1.0, position: .center)
            } else {
                let displayName = controller.textFields?[0].text
                ProfileProvider.shared.putModifyUserInfo(userID: UserManager.shared.userID, name: displayName ?? UserManager.shared.userID)
                self.displayName = displayName
            }
        }
        
        controller.view.tintColor = UIColor.black
        controller.addAction(okAction)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        controller.addAction(cancelAction)
        present(controller, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //        itemSize
        return CGSize(width: imageWidth, height: imageWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        2
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let image = propertyImages[indexPath.item]
        
        let detailTableViewVC = UIStoryboard.propertyDetail.instantiateViewController(withIdentifier: String(describing: DetailViewController.self)
        )
        guard let detailVC = detailTableViewVC as? DetailViewController else { return }
        
        detailVC.propertyId = userPropertyData?.data[indexPath.row].propertyId ?? ""
        detailVC.imageOwnerName = userPropertyData?.data[indexPath.row].name ?? ""
        detailVC.detailPageImage = image
        detailVC.avatarUrl = userPropertyData?.data[indexPath.row].avatar
        detailVC.isFromProfile = true
        
        show(detailVC, sender: nil)
    }
}

extension ProfileViewController {
    func openCameraActionSheet(compltion:@escaping (CameraState?) -> Void) {
        let cameraActionSheet = UIAlertController(title: "", message: "選項", preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "相機", style: .default) { _ in
            compltion(.camera)
        }
        
        let gallaryAction = UIAlertAction(title: "相冊", style: .default) { _ in
            compltion(.gallary)
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { _ in
            compltion(nil)
        }
        cameraActionSheet.addAction(cameraAction)
        cameraActionSheet.addAction(gallaryAction)
        cameraActionSheet.addAction(cancelAction)
        
        // iPad specific code
        if UIDevice.current.userInterfaceIdiom == .pad {
            cameraActionSheet.popoverPresentationController?.sourceView = self.view
            let xOrigin = self.view.bounds.width / 2
            let popoverRect = CGRect(x: xOrigin, y: 0, width: 1, height: 1)
            cameraActionSheet.popoverPresentationController?.sourceRect = popoverRect
            cameraActionSheet.popoverPresentationController?.permittedArrowDirections = .up
        }
        
        self.present(cameraActionSheet, animated: true, completion: nil)
    }
}
