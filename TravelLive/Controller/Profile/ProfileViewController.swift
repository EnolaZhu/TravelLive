//
//  ProfileViewController.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/14.
//

import UIKit
import CoreServices
import GoogleMobileAds

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var profileView: UICollectionView!
    let itemSize = CGSize(width: 50, height: 50)
    var postButton: UIButton = {
        let postButton = UIButton(frame: CGRect(x: UIScreen.width - 120, y: UIScreen.height - 430, width: 88, height: 88))
        postButton.tintColor = UIColor.primary
        postButton.setImage(UIImage.asset(.plus), for: UIControl.State())
        return postButton
    }()
    let imagePickerController = UIImagePickerController()
    let userId = "Enola"
    fileprivate var imageWidth: CGFloat = 0
    var userPropertyData:  ProfilePropertyObject?
    var avatarImage = UIImage()
    var propertyImages = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postButton.addTarget(self, action: #selector(postImage(_:)), for: .touchUpInside)

        navigationItem.title = "個人"
        // Add advertisement
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        
        view.addSubview(postButton)
        
        profileView.delegate = self
        profileView.dataSource = self
        imageWidth = profileView.frame.width / 3 - 1
    
        profileView.contentInsetAdjustmentBehavior = .never
//        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage.asset(.plus), style: .plain, target: nil, action: #selector(postImage))
        getUserInfo()
        getUserProperty()
    }
    
    func getUserInfo() {
        ProfileProvider.shared.fetchUserData(userId: userId) { [weak self] result in
            switch result {
            case .success(let data):
                
                ImageManager.shared.fetchStorageImage(imageUrl: data.avatar ?? "") { image in
                    self?.avatarImage = image
                    self?.profileView.reloadData()
                }
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func getUserProperty() {
        ProfileProvider.shared.fetchUserPropertyData(userId: userId) { [weak self] result in
            switch result {
            case .success(let data):
                self?.userPropertyData = data
                guard let userPropertyData = self?.userPropertyData else { return }
                
                if userPropertyData.data.count > 0 {
                    
                    for index in 0...userPropertyData.data.count - 1 {
                        if userPropertyData.data[index].thumbnailUrl == "" {
                            self?.getImage(imageUrl: userPropertyData.data[index].fileUrl ?? "")
                        } else {
                            self?.getThumbnail(property: userPropertyData.data[index], index: index)
                        }
                    }
                }
                self?.profileView.reloadData()
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func getImage(imageUrl: String) {
        // Image
        ImageManager.shared.fetchStorageImage(imageUrl: imageUrl) { image in
            self.propertyImages.append(image)
            self.profileView.reloadData()
        }
    }
    
    private func getThumbnail(property: Property, index: Int) {
        ImageManager.shared.fetchUserGIF(thumbnailUrl: property.thumbnailUrl) { gif in
            self.propertyImages.append(gif)
            self.profileView.reloadData()
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
        /// Create the temporary directory.
        let temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        /// create a temporary file for us to copy the video to.
        let temporaryFileURL = temporaryDirectoryURL.appendingPathComponent(url.lastPathComponent ?? "")
        /// Attempt the copy.
        do {
            try FileManager().copyItem(at: url.absoluteURL!, to: temporaryFileURL)
        } catch {
            print("There was an error copying the video file to the temporary location.")
        }
        return temporaryFileURL as NSURL
    }
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //    swiftlint: disable identifier_name
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let uploadDate = Date()
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "SSSSSS"
        let uploadTimestamp = Int(uploadDate.timeIntervalSince1970)
        
        let tag = "\(Int.random(in: 0...2))"
        let storageRefPath = userId + "_" + "\(uploadTimestamp)" + dateFormat.string(from: uploadDate) + "_" + tag
        
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
            let storageRefGifPath = "thumbnail_" + userId + "_" + "\(uploadTimestamp)" + dateFormat.string(from: uploadDate) + "_" + tag
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
        header.layoutProfileHeader(avatar: avatarImage)
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        propertyImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ProfileCollectionCell.self), for: indexPath) as? ProfileCollectionCell else {
            fatalError("Couldn't create cell")
        }
        cell.profileImageView.frame = CGRect(x: 0, y: 0, width: imageWidth, height: imageWidth)
        
//        if propertyImages.isEmpty {
//            cell.layoutCell(image: UIImage(named: "placeholder") ?? UIImage())
//        } else {
            cell.layoutCell(image: propertyImages[indexPath.row])
//        }
        cell.profileImageView.contentMode = .scaleAspectFill
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: imageWidth, height: imageWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
}
