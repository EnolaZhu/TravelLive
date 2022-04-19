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
    
    func startRecording(_ sender: UIButton, _ record: RPScreenRecorder) {
        record.startRecording(handler: { (error: Error?) -> Void in
            if error == nil {
                // Recording has started
                sender.setImage(UIImage.asset(.stop), for: .normal)
            } else {
                // Handle error
                print(error?.localizedDescription ?? "Unknown error")
            }
        })
    }
    
    func stopRecording(_ sender: UIButton, _ record: RPScreenRecorder, _ vc: UIViewController) {
        record.stopRecording( handler: { previewViewController, error in
            if let pvc = previewViewController {
                if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
                    pvc.modalPresentationStyle = UIModalPresentationStyle.popover
                    pvc.popoverPresentationController?.sourceRect = CGRect.zero
                    pvc.popoverPresentationController?.sourceView = vc.view
                }
                pvc.previewControllerDelegate = vc as? RPPreviewViewControllerDelegate
                vc.present(pvc, animated: true, completion: nil)
            }
            else if let error = error {
                print(error.localizedDescription)
            }
        })
    }
}
