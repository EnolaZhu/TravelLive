//
//  PhotoVideoManager.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/15.
//

import Foundation
import Firebase
import FirebaseStorage
import UIKit
import AVFoundation

class PhotoVideoManager {
    static let shared = PhotoVideoManager()
    let storageRef = Storage.storage().reference()
    
    func uploadFileFromIo(url: String, child: String, completion: @escaping (String) -> Void) {
//        let encodedChild = child.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let localFile = URL(string: url)!
        let riversRef = storageRef.child(child)
        
        _ = riversRef.putFile(from: localFile, metadata: nil) { _, _ in
            riversRef.downloadURL { (url, error) in
                if error != nil {
                    completion("error")
                } else {
                    completion("")
                }
            }
        }
    }
    
    func uploadFileFromMemory(image: UIImage, child: String, completion: @escaping (String) -> Void) {
        let data = image.pngData() ?? Data()
        let riversRef = storageRef.child(child)
        
        _ = riversRef.putData(data, metadata: nil) { _, _ in
            riversRef.downloadURL { (url, _) in
                if url == nil {
                    completion("error")
                } else {
                    completion("")
                }
            }
        }
    }
    
    public func getImageFromVideo(url: URL, at time: TimeInterval, completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global(qos: .background).async {
            let asset = AVURLAsset(url: url)

            let assetIG = AVAssetImageGenerator(asset: asset)
            assetIG.appliesPreferredTrackTransform = true
            assetIG.apertureMode = AVAssetImageGenerator.ApertureMode.encodedPixels

            let cmTime = CMTime(seconds: time, preferredTimescale: 60)
            let thumbnailImageRef: CGImage
            do {
                thumbnailImageRef = try assetIG.copyCGImage(at: cmTime, actualTime: nil)
            } catch let error {
                return completion(nil)
            }

            DispatchQueue.main.async {
                completion(UIImage(cgImage: thumbnailImageRef))
            }
        }
    }
}
