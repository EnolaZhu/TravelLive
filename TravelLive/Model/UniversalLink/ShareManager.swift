//
//  shareManager.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/23.
//

import UIKit

class ShareManager {
    static let share = ShareManager()
    
    func shareLink(textToShare: String, shareUrl: String, thevVC: UIViewController, sender: UIButton) {
        UIGraphicsBeginImageContext(thevVC.view.frame.size)
        thevVC.view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let textToShare = textToShare
        
        if let myWebsite = URL(string: shareUrl) {
            // Enter link to your app here
            let objectsToShare = [textToShare, myWebsite, image ?? #imageLiteral(resourceName: "app-logo")] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList]
            
            activityVC.popoverPresentationController?.sourceView = sender
            thevVC.present(activityVC, animated: true, completion: nil)
        }
    }
}
