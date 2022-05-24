//
//  GIFManager.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/18.
//

import Foundation
import mobileffmpeg

class GIFManager {
    static let shared = GIFManager()
    
    func convertMp4ToGIF(fileURL: URL, completion: @escaping (Result<String>) -> Void) {
            let outfileName = String(format: "%@_%@", ProcessInfo.processInfo.globallyUniqueString, "outfile.gif")
            let outfileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(outfileName)
            
            let convertQueue = DispatchQueue(label: "convertToGIF")
            convertQueue.async {
                _ = MobileFFmpeg.execute("-i \(fileURL.path) -vf fps=15,scale=250:-1 \(outfileURL.path)")
                completion(Result.success("\(outfileURL)"))
            }
    }
}
