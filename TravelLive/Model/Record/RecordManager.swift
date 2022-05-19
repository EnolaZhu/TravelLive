//
//  RecordManager.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/15.
//

import UIKit
import ReplayKit

class RecordManager {
    static let record = RecordManager()
    
    func startRecording(_ record: RPScreenRecorder, completion: @escaping (String?) -> Void) {
        record.startRecording(handler: { (error: Error?) -> Void in
            if error == nil {
                completion("")
            } else {
                completion(nil)
            }
        })
    }
    
    func stopRecording(_ record: RPScreenRecorder, _ theVC: UIViewController, completion: @escaping (Result<Any>) -> Void) {
        record.stopRecording(handler: { previewViewController, error in
            if let pvc = previewViewController {
                
                if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
                    pvc.modalPresentationStyle = UIModalPresentationStyle.popover
                    pvc.popoverPresentationController?.sourceRect = CGRect.zero
                    pvc.popoverPresentationController?.sourceView = theVC.view
                }
                pvc.previewControllerDelegate = theVC as? RPPreviewViewControllerDelegate
                theVC.present(pvc, animated: true, completion: nil)
                guard let previewViewController = previewViewController else { return }
                completion(Result.success(previewViewController))
            } else if let error = error {
                print(error.localizedDescription)
                completion(Result.failure(error))
            }
        })
    }
}
