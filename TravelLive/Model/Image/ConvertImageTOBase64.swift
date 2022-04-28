//
//  ConvertImageTOBase64.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/28.
//

import UIKit

class ConvertImageTOBase64Manager {
    // Encode
    func convertImageToBase64String(image: UIImage) -> String {
        return image.jpegData(compressionQuality: 1)?.base64EncodedString() ?? ""
    }
}
