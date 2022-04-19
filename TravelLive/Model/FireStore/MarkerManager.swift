//
//  MarkerManager.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/11.
//

import Foundation
import Firebase
import FirebaseStorage
import UIKit

class MarkerManager {
    static let shared = MarkerManager()
    lazy var storage = Storage.storage()
    var storageRef: StorageReference?
    
    func fetchStorageImage(hostUrl: String, imageUrl: String, completion: @escaping (UIImage) -> Void) {
        if hostUrl.hasPrefix("gs://") {
            if storageRef == nil {
                storageRef = storage.reference(forURL: hostUrl)
            }
            storageRef?.child(imageUrl).getData(maxSize: 1 * 1024 * 1024) { data, error in
                if let error = error {
                    print(error)
                } else {
                    let image = UIImage(data: data!)
                    print("Get Image")
                    completion(image!)
                }
            }
        } else {
            ImageManager.shared.downloadImage(with: imageUrl) { uiImage in
                completion(uiImage ?? UIImage())
            }
        }
    }
    
    func fetchUserGIF(thumbnailUrl: String, completion: @escaping (UIImage) -> Void) {
//        let gifURL = hostUrl + gifUrl
//        let gifURL = "gs://travellive-1d79e.appspot.com/Enola_1650298173491000_2_thumbnail"
//        let gifURL = "https://firebasestorage.googleapis.com/v0/b/travellive-1d79e.appspot.com/o/Enola_1650298173491000_2_thumbnail?alt=media&token=134d166a-ea09-479b-ba51-b5350e9850c7"
        let image = UIImage.gifImageWithURL(thumbnailUrl) ?? UIImage()
        completion(image)
        //                let imageView3 = UIImageView(image: imageURL)
        //                imageView3.frame = CGRect(x: 20.0, y: 390.0, width: self.view.frame.size.width - 40, height: 150.0)
        //                view.addSubview(imageView3)
    }
}
