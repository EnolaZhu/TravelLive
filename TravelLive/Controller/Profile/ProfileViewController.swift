//
//  ProfileViewController.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/14.
//

import UIKit
import CoreServices

class ProfileViewController: UIViewController {
    var postButton: UIButton = {
        let postButton = UIButton(frame: CGRect(x: UIScreen.width - 120, y: UIScreen.height - 430, width: 88, height: 88))
        postButton.tintColor = UIColor.primary
        postButton.setImage(UIImage.asset(.plus), for: UIControl.State())
        return postButton
    }()
    let imagePickerController = UIImagePickerController()
    let userId = "Enola"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        postButton.addTarget(self, action: #selector(postImage(_:)), for: .touchUpInside)
        view.addSubview(postButton)
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
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //    swiftlint: disable identifier_name
        let d = Date()
        let df = DateFormatter()
        df.dateFormat = "SSSSSS"
        let date = Int(Date().timeIntervalSince1970)
        
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            let imgUrl = info[UIImagePickerController.InfoKey.imageURL] as? URL
            guard let url = imgUrl else { return }
            PhotoVideoManager.shared.uploadImageVideo(url: String(describing: url), child: (userId + "_" + "\(date)" + df.string(from: d)))
        }
        if let url = info[.mediaURL] as? URL {
            let videoUrl = createTemporaryURLforVideoFile(url: url as NSURL)
            PhotoVideoManager.shared.uploadImageVideo(url: String(describing: videoUrl), child: (userId + "_" + "\(date)" + df.string(from: d)))
        }
        imagePickerController.dismiss(animated: true, completion: nil)
    }
}
