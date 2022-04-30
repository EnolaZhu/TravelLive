//
//  ImageLabelingManager.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/30.
//

import Foundation
import UIKit
import MLKitVision
import MLKitImageLabeling
import MLKitImageLabelingCommon

class ImageLabelingManager {
    
    func getImageLabel(inputImage: UIImage, label: @escaping ([ImageLabel]) -> Void) {
        let visionImage = VisionImage(image: inputImage)
        visionImage.orientation = inputImage.imageOrientation
        
        let options = ImageLabelerOptions()
        options.confidenceThreshold = 0.8
        let labeler = ImageLabeler.imageLabeler(options: options)
        
        labeler.process(visionImage) { labels, error in
            guard error == nil, let labels = labels else { return }
            label(labels)
        }
    }
}
