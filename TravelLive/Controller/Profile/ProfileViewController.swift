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

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var profileView: UICollectionView!
    var postButton: UIButton = {
        let postButton = UIButton(frame: CGRect(x: UIScreen.width - 100, y: UIScreen.height - 730, width: 88, height: 88))
        postButton.tintColor = UIColor.primary
        postButton.setImage(UIImage.asset(.plus), for: UIControl.State())
        return postButton
    }()
    let imagePickerController = UIImagePickerController()
    fileprivate var imageWidth: CGFloat = 0
    var userPropertyData: ProfilePropertyObject?
    var likedPropertyData: ProfileLikedObject?
    var avatarImage: UIImage? {
        didSet {
            profileView.reloadData()
        }
    }
    var propertyImages = [UIImage]()
    var profileInfo: ProfileObject?
    var displayName: String? {
        didSet {
            profileView.reloadData()
        }
    }
    var imagePicker: ImagePicker!
    var isFromOther = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add observer of change images
        NotificationCenter.default.addObserver(self, selector: #selector(self.showUserProperty(_:)), name: .showUserPropertyKey, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.showLikedProperty(_:)), name: .showLikedPropertyKey, object: nil)
        // change avatar
        NotificationCenter.default.addObserver(self, selector: #selector(self.showEditView(_:)), name: .showEditAvatarViewKey, object: nil)
        
        navigationItem.title = "個人"
        // Add advertisement
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        
        profileView.delegate = self
        profileView.dataSource = self
        
        profileView.contentInsetAdjustmentBehavior = .never
        profileView.showsVerticalScrollIndicator = false
        
        if isFromOther {
            
        } else {
            postButton.addTarget(self, action: #selector(postImage(_:)), for: .touchUpInside)
            
            view.addSubview(postButton)
            
            navigationItem.rightBarButtonItems = [UIBarButtonItem(image: UIImage.asset(.menu), style: .plain, target: self, action: #selector(createAlertSheet))]
        }
        //        getUserInfo()
        //        getUserProperty()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
        imageWidth = ((UIScreen.width - 4) / 3)  - 2
        getUserInfo()
        getUserProperty()
    }
    
    @objc func showEditView(_ notification: NSNotification) {
        self.openCameraActionSheet { cameraState in
            if let state = cameraState {
                self.openImagePicker(with: state)
            }
        }
    }
    
    // show selected image
    private func presentCropViewController(_ image: UIImage) {
        let cropViewController = CropViewController(image: image) { [unowned self] croppedImage in
            self.avatarImage = croppedImage ?? UIImage()
            
            // Put user selected image to firebase
            let imageBase64 = ConvertImageTOBase64Manager().convertImageToBase64String(image: croppedImage ?? UIImage())
            ProfileProvider.shared.putUserAvatar(userID: userID, photoBase64: imageBase64)
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
            case .error(let message):
                self.presentAlertMessage(message: message)
            }
        })
    }
    
    private func getUserInfo() {
        ProfileProvider.shared.fetchUserData(userId: userID) { [weak self] result in
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
            }
        }
    }
    
    func getUserProperty() {
        propertyImages.removeAll()
        
        ProfileProvider.shared.fetchUserPropertyData(userId: userID) { [weak self] result in
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
                self?.profileView.reloadData()
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func getLikedProperty() {
        propertyImages.removeAll()
        
        ProfileProvider.shared.fetchUserLikedData(userId: userID) { [weak self] data in
            switch data {
            case .success(let data):
                self?.likedPropertyData = data
                guard let likedPropertyData = self?.likedPropertyData else { return }
                
                if likedPropertyData.data.count > 0 {
                    
                    for index in 0...likedPropertyData.data.count - 1 {
                        if likedPropertyData.data[index].thumbnailUrl == "" {
                            self?.getImage(imageUrl: likedPropertyData.data[index].fileUrl)
                        } else {
                            self?.getLikedThumbnail(likedProperty: likedPropertyData.data[index], index: index)
                        }
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func getImage(imageUrl: String) {
        // Image
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
    
    private func getLikedThumbnail(likedProperty: Liked, index: Int) {
        ImageManager.shared.fetchUserGIF(thumbnailUrl: likedProperty.thumbnailUrl) { [weak self] gif in
            self?.propertyImages.append(gif)
            self?.profileView.reloadData()
        }
    }
    
    @objc func showUserProperty(_ notification: NSNotification) {
        getUserProperty()
    }
    
    @objc func showLikedProperty(_ notification: NSNotification) {
        getLikedProperty()
    }
    
    @objc func createAlertSheet() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "編輯資料", style: .default, handler: { [weak self] _ in
            self?.createModifyNameAlert()
        }))
        alertController.addAction(UIAlertAction(title: "登出", style: .default, handler: { [weak self] _ in
            self?.signOut()
        }))
        alertController.addAction(UIAlertAction(title: "刪除帳號", style: .default, handler: { _ in
            ProfileProvider.shared.deleteAccount(userId: userID)
        }))
        alertController.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { _ in
        }))
        self.present(alertController, animated: true)
    }
    
    // User sign out
    func signOut() {
        do {
            try Auth.auth().signOut()
            userID = ""
        } catch {
            print(error)
        }
    }
    
    @objc func postImage(_ sender: UIButton) {
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
    
    @objc func hideBanner(_ button: UIButton) {
        bannerView.isHidden = true
    }
    
    func createTemporaryURLforVideoFile(url: NSURL) -> NSURL {
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
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let uploadDate = Date()
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "SSSSSS"
        let uploadTimestamp = Int(uploadDate.timeIntervalSince1970)
        
        let tag = "\(Int.random(in: 0...2))"
        let storageRefPath = userID + "_" + "\(uploadTimestamp)" + dateFormat.string(from: uploadDate) + "_" + tag
        
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            let imageUrl = info[UIImagePickerController.InfoKey.imageURL] as? URL
            guard let imgUrl = imageUrl else { return }
            PhotoVideoManager.shared.uploadImageVideo(url: String(describing: imgUrl), child: storageRefPath)
        }
        
        if let mediaUrl = info[.mediaURL] as? URL {
            // Upload video file
            let videoUrl = createTemporaryURLforVideoFile(url: mediaUrl as NSURL)
            PhotoVideoManager.shared.uploadImageVideo(url: String(describing: videoUrl), child: storageRefPath)
            
            // Convert video type to GIF
            let storageRefGifPath = "thumbnail_" + userID + "_" + "\(uploadTimestamp)" + dateFormat.string(from: uploadDate) + "_" + tag
            GIFManager.shared.convertMp4ToGIF(fileURL: mediaUrl) { [weak self] result in
                switch result {
                case .success(let urlOfGIF):
                    // Upload GIF file
                    PhotoVideoManager.shared.uploadImageVideo(url: urlOfGIF, child: storageRefGifPath)
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
        
        header.layoutSegment(firstSegmentTitle: "我的照片", secondSegmentTitle: "我的喜歡")
        if isFromOther {
            header.editAvatarButton.isHidden = true
            header.layoutSegment(firstSegmentTitle: "照片", secondSegmentTitle: "喜歡")
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
        // ImageView gesture
        let tapGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        cell.profileImageView.isUserInteractionEnabled = true
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
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) -> Void in
            guard let indexPath = self.profileView.indexPathForItem(at: index ?? CGPoint()) else { return }
            // delete image from local
            self.propertyImages.remove(at: indexPath.row)
            // delete image from database
            ProfileProvider.shared.deleteSpecificProperty(propertyId: self.userPropertyData?.data[indexPath.row].propertyId ?? ""
            )
            self.profileView.reloadData()
        })
        deleteAlert.addAction(okAction)
        self.present(deleteAlert, animated: true, completion: nil)
    }
    
    private func createModifyNameAlert() {
        let controller = UIAlertController(title: "名字", message: "修改的名字只在 APP 內使用哦", preferredStyle: .alert)
        controller.addTextField { textField in
            textField.placeholder = "名字"
        }
        
        let okAction = UIAlertAction(title: "完成", style: .default) { [unowned controller] _ in
            let displayName = controller.textFields?[0].text
            
            ProfileProvider.shared.putModifyUserInfo(userID: userID, name: displayName ?? userID)
            self.displayName = displayName
        }
        
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
        let detailVC = DetailViewController()
        //TODO: 判斷 liked 和 property
        detailVC.propertyId = userPropertyData?.data[indexPath.row].propertyId ?? ""
        detailVC.imageOwnerName = userPropertyData?.data[indexPath.row].name ?? ""
        detailVC.detailPageImage = image
        navigationController?.pushViewController(detailVC, animated: true)
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
        
        if let popoverController = cameraActionSheet.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.maxY, width: 0, height: 0)
        }
        self.present(cameraActionSheet, animated: true, completion: nil)
    }
    
    // Error alert
    func presentAlertMessage(title: String = "Alert", message: String, okclick: (() -> Void)? = nil) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { [unowned self] _ in
            if okclick != nil {
                okclick!()
            }
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true) {
        }
    }
}
