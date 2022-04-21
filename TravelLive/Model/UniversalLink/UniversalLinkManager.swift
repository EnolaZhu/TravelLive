//
//  UniversalLinkManager.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/22.
//

import Foundation
import UIKit

class UniversalLinkManager {
    static let manager = UniversalLinkManager()
    // 之後再加上判斷是否登錄的邏輯，FALSE 則回去登錄頁面，再 call back回來繼續跳轉
    
    /*
     input:https://travellive.page.link/?link=https://travellive-1d79e.web.app/WebRTCPlayer.html?live=Enola
     output:Optional(["link": "https://travellive-1d79e.web.app/WebRTCPlayer.html?live=Enola"])
     
     input:https://travellive-1d79e.web.app/WebRTCPlayer.html?live=Enola
     output:Optional(["live": "Enola"])
     */
    func redirect(dynamicUrl: URL) {
        let firstWebAppLinkDic = dynamicUrl.queryParameters
        guard let firstWebAppLinkDicValue = firstWebAppLinkDic?["link"] else { return }
        guard let finalWebAppLinkDic = URL(string: firstWebAppLinkDicValue)?.queryParameters else { return }
        if finalWebAppLinkDic.keys.contains("live") {
            let pullStreamingVC = UIStoryboard.pullStreaming.instantiateViewController(withIdentifier: String(describing: PullStreamingViewController.self)
            )
            guard let pullVC = pullStreamingVC as? PullStreamingViewController else { return }
            // webrtc://pull.whiletrue.cafe/TravelLive/
            pullVC.streamingUrl = finalWebAppLinkDic["live"] ?? ""
            UIApplication.shared.keyWindow?.rootViewController?.present(pullVC,animated: true)
//            let viewController = UIApplication.shared.windows.first!.rootViewController as! pullVC
        }
    }
}
