//
//  ProfileViewController.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/14.
//

import UIKit
import CoreServices
import GoogleMobileAds

class ProfileViewController: UIViewController, UICollectionViewDelegate {
    
    enum Section: Int {
        case image = 0
        case gif = 1
    }
    
    @IBOutlet weak var payButton: UIButton!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var postAssetButton: UIButton!
    @IBOutlet weak var bannerView: GADBannerView!
    var postButton: UIButton = {
        let postButton = UIButton(frame: CGRect(x: UIScreen.width - 120, y: UIScreen.height - 430, width: 88, height: 88))
        postButton.tintColor = UIColor.primary
        postButton.setImage(UIImage.asset(.plus), for: UIControl.State())
        return postButton
    }()
    let imagePickerController = UIImagePickerController()
    let userId = "Enola"
    
    var collection: UICollectionView! = nil
    var dynamicAnimator: UIDynamicAnimator!
    var dataSource: UICollectionViewDiffableDataSource<Section, Int>! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        postButton.addTarget(self, action: #selector(postImage(_:)), for: .touchUpInside)
        payButton.addTarget(self, action: #selector(hideBanner(_:)), for: .touchUpInside)

        navigationItem.title = "個人"
        // Add advertisement
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        // collection view
        configureHierarchy()
        configureDataSource()
        view.addSubview(postButton)
    }
    
    private func configureHierarchy() {
//        dynamicAnimator = UIDynamicAnimator(referenceView: view)
// view.bounds
        collection = UICollectionView(frame: CGRect(x: 0, y: 400, width: view.bounds.width, height: 300), collectionViewLayout: createLayout())
        collection.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collection.backgroundColor = .systemBackground
        collection.registerCellWithNib(identifier: String(describing: ImageCell.self), bundle: nil)
        collection.delegate = self
        view.addSubview(collection)
    }
    
    private func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { sectionNumber, env -> NSCollectionLayoutSection? in
            switch Section(rawValue: sectionNumber) {
            case .image:
                return self.imageSection()
            case .gif:
                return self.imageSection()
            default:
                return nil
            }
        }
    }

    
    private func imageSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5),
                                              heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: .fractionalHeight(0.8))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                         subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        // 分頁效果
        section.orthogonalScrollingBehavior = .groupPaging
        return section
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Int>(collectionView: collection) {
            (collectionView: UICollectionView, indexPath: IndexPath, identifier: Int) -> UICollectionViewCell? in

            // Get a cell of the desired kind.
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: String(describing: ImageCell.self),
                for: indexPath) as? ImageCell else { fatalError("Cannot create new cell") }
            if indexPath.section == 0 {
                cell.backgroundColor = UIColor.primary
            } else {
                cell.backgroundColor = UIColor.blue
            }
            
            // Populate the cell with our item description.
//            cell.configureWith(text: "\(indexPath.row)", image: nil)

            // Return the cell.
            return cell
        }

        // initial data
        var snapshot = NSDiffableDataSourceSnapshot<Section, Int>()
        snapshot.appendSections([.image])
        snapshot.appendItems(Array(1..<15))
        snapshot.appendSections([.gif])
        snapshot.appendItems(Array(6..<37))
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    @objc func postImage(_ button: UIButton) {
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
        // TODO: Tag
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
