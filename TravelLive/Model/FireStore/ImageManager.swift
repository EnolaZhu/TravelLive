//
//  ImageManager.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/17.
//

import Kingfisher

class ImageManager {
    static let shared = ImageManager()
    
    func loadImage(imageView: UIImageView, url: String) {
        imageView.kf.setImage(with: URL(string: url))
    }
    
    func downloadImage(with urlString : String, imageCompletionHandler: @escaping (UIImage?) -> Void) {
        guard let url = URL.init(string: urlString) else {
            return  imageCompletionHandler(nil)
        }
        let resource = ImageResource(downloadURL: url)
        
        KingfisherManager.shared.retrieveImage(with: resource, options: nil, progressBlock: nil) { result in
            switch result {
            case .success(let value):
                imageCompletionHandler(value.image)
            case .failure:
                imageCompletionHandler(nil)
            }
        }
    }
    
    func fetchImage(imageUrl: String, completion: @escaping (UIImage) -> Void) {
        self.downloadImage(with: imageUrl) { uiImage in
            completion((uiImage ?? UIImage())!)
        }
    }
    
    func fetchUserGIF(thumbnailUrl: String, completion: @escaping (UIImage) -> Void) {
        let image = UIImage.gifImageWithURL(thumbnailUrl) ?? UIImage()
        completion(image)
    }
}
