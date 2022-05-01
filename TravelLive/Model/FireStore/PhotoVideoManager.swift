//
//  PhotoVideoManager.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/15.
//

import Foundation
import Firebase
import FirebaseStorage

class PhotoVideoManager {
    static let shared = PhotoVideoManager()
    //    lazy var storage = Storage.storage()
    let storageRef = Storage.storage().reference()
    func uploadImageVideo(url: String, child: String) {
        let newChild = child.replacingOccurrences(of: " ", with: "+")
        let encodedChild = newChild.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let localFile = URL(string: url)!
        let riversRef = storageRef.child(encodedChild)
        let uploadTask = riversRef.putFile(from: localFile, metadata: nil) { metadata, error in
            guard let metadata = metadata else { return }
            let size = metadata.size
            riversRef.downloadURL { (url, error) in
                guard let downloadURL = url else { return }
                print("\(String(describing: url))")
            }
        }
    }
}
