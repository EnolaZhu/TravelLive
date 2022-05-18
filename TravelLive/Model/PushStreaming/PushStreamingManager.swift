//
//  PushStreamingManager.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/5/18.
//

import UIKit
import TXLiteAVSDK_Professional

class PushStreamingManager {
    var pusher: V2TXLivePusher! = V2TXLivePusher.init(liveMode: V2TXLiveMode.RTMP)
    
    func createObserver(pushVC: V2TXLivePusherObserver!) {
        pusher.setObserver(pushVC)
    }
    
    func createRenderView(view: UIView) {
        pusher.setRenderView(view)
    }
    
    func createStartCamera(isStartCamera: Bool) {
        pusher.startCamera(isStartCamera)
        if isStartCamera {
            pusher.startMicrophone()
        }
    }
    
    func stopStreaming() {
        pusher.stopPush()
        pusher.stopMicrophone()
        pusher.stopCamera()
    }
    
    func startBeauty() {
        pusher.getBeautyManager().setBeautyStyle(TXBeautyStyle.nature)
        pusher.getBeautyManager().setBeautyLevel(Float(0))
    }
    
    func closeBeauty() {
        pusher.getBeautyManager().setBeautyStyle(TXBeautyStyle.smooth)
        pusher.getBeautyManager().setBeautyLevel(Float(9))
    }
    
    func switchCamera() {
        pusher.getDeviceManager().switchCamera(!pusher.getDeviceManager().isFrontCamera())
    }
    
    func startPush(url: String) {
        pusher.startPush(url)
    }
}
