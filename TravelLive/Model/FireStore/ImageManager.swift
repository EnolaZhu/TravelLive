//
//  ImageManager.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/17.
//

import Kingfisher
import UIKit

class ImageManager {
    static let shared = ImageManager()
    
    func loadImage(imageView: UIImageView, url: String) {
        imageView.kf.setImage(with: URL(string: url))
    }
    
    func downloadImage(isAvatar: Bool, with urlString: String, imageCompletionHandler: @escaping (UIImage?) -> Void) {
        guard let url = URL.init(string: urlString) else {
            return  imageCompletionHandler(nil)
        }
        let resource = ImageResource(downloadURL: url)
        
        if isAvatar {
            KingfisherManager.shared.retrieveImage(with: resource, options: [.forceRefresh], progressBlock: nil) { result in
                switch result {
                case .success(let value):
                    imageCompletionHandler(value.image)
                case .failure:
                    imageCompletionHandler(nil)
                }
            }
        } else {
            KingfisherManager.shared.retrieveImage(with: resource, options: nil, progressBlock: nil) { result in
                switch result {
                case .success(let value):
                    imageCompletionHandler(value.image)
                case .failure:
                    imageCompletionHandler(nil)
                }
            }
        }
    }
    
    func fetchImage(imageUrl: String, completion: @escaping (UIImage) -> Void) {
        self.downloadImage(isAvatar: false, with: imageUrl) { uiImage in
            completion((uiImage ?? UIImage())!)
        }
    }
    
    func fetchImageWithoutCache(imageUrl: String, completion: @escaping (UIImage) -> Void) {
        self.downloadImage(isAvatar: true, with: imageUrl) { uiImage in
            completion((uiImage ?? UIImage())!)
        }
    }
    
    func fetchUserGIF(thumbnailUrl: String, completion: @escaping (UIImage) -> Void) {
        let image = UIImage.gifImageWithURL(thumbnailUrl) ?? UIImage()
        completion(image)
    }
}
