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
        do {
            let outfileName = String(format: "%@_%@", ProcessInfo.processInfo.globallyUniqueString, "outfile.gif")
            let outfileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(outfileName)
            
            print("\(outfileURL)")
            let convertQueue = DispatchQueue(label: "convertToGIF")
            convertQueue.async {
                let _ = MobileFFmpeg.execute("-i \(fileURL.path) -vf fps=10,scale=150:-1 \(outfileURL.path)")
                completion(Result.success("\(outfileURL)"))
            }
        } catch {
            print("Error was:", error)
        }
    }
}
