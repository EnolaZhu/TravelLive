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
    let storageRef = Storage.storage().reference()
    func uploadImageVideo(url: String, child: String, completion: @escaping (String) -> Void) {
        let encodedChild = child.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let localFile = URL(string: url)!
        let riversRef = storageRef.child(encodedChild)
        
        let uploadTask = riversRef.putFile(from: localFile, metadata: nil) { metadata, error in
            riversRef.downloadURL { (url, error) in
                print("\(String(describing: url))")
                if error != nil {
                    completion("error")
                } else {
                    completion("")
                }
            }
        }
    }
}
