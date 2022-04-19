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
    
    func fetchStreamerImage(hostUrl: String, imageUrl: String, completion: @escaping (UIImage) -> Void) {
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
    
//    func fetchUserGIF(hostUrl: String, gifUrl: String, completion: @escaping (UIImage) -> Void) {
}
