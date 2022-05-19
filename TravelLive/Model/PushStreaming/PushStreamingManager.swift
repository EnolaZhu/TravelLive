//
//  PushStreamingManager.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/5/18.
//

import UIKit
import TXLiteAVSDK_Professional

class PushStreamingManager: NSObject, V2TXLivePusherObserver {
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
    
    func stopStreaming(completion: @escaping () -> Void) {
        pusher.stopPush()
        pusher.stopMicrophone()
        pusher.stopCamera()
        completion()
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
    
    func requestAccessForVideo() { //
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch status {
            // request authorization license
        case AVAuthorizationStatus.notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted) in
                if granted {
                    DispatchQueue.main.async {
                    }
                }
            })
        default: break
        }
    }
    
    func requestAccessForAudio() { //
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.audio)
        switch status {
            // request authorization license
        case AVAuthorizationStatus.notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.audio, completionHandler: { _ in })
        default: break
        }
    }
}
