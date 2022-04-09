//
//  PushViewController.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/4.
//

import UIKit
import LFLiveKit

class PushViewController: UIViewController, LFLiveSessionDelegate {
    // swiftlint:disable trailing_whitespace
    override func viewDidLoad() {
        super.viewDidLoad()
        session.delegate = self
        session.preView = view
        addPushPreview()
        addChatView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func addPushPreview() {
        requestAccessForVideo()
        requestAccessForAudio()
        view.backgroundColor = UIColor.clear
        view.addSubview(containerView)
        containerView.addSubview(stateLabel)
        containerView.addSubview(closeButton)
        containerView.addSubview(beautyButton)
        containerView.addSubview(cameraButton)
        containerView.addSubview(startLiveButton)
        cameraButton.addTarget(self, action: #selector(didTappedCameraButton(_:)), for: .touchUpInside)
        beautyButton.addTarget(self, action: #selector(didTappedBeautyButton(_:)), for: .touchUpInside)
        startLiveButton.addTarget(self, action: #selector(didTappedStartLiveButton(_:)), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(didTappedCloseButton(_:)), for: .touchUpInside)
    }
    // swiftlint:disable trailing_whitespace
    private func addChatView() {
        let chatMessageVC = UIStoryboard.chat.instantiateViewController(withIdentifier:
            String(describing: ChatViewController.self)
        )
        guard let chatVC = chatMessageVC as? ChatViewController else { return }
        view.addSubview(chatVC.view)
        self.addChild(chatVC)
    }
    
    func requestAccessForVideo() {
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch status {
            // request authorization license
        case AVAuthorizationStatus.notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted) in
                if granted {
                    DispatchQueue.main.async {
                        self.session.running = true
                    }
                }
            })
            // open authorizatio, continuew
        case AVAuthorizationStatus.authorized:
            session.running = true
            // user defuse authorization, or can't access camera
        case AVAuthorizationStatus.denied: break
        case AVAuthorizationStatus.restricted:break
        default:
            break
        }
    }
    
    func requestAccessForAudio() {
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.audio)
        switch status {
            // request authorization license
        case AVAuthorizationStatus.notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.audio, completionHandler: { _ in })
            // open authorizatio, continuew
        case AVAuthorizationStatus.authorized:
            break
            // user defuse authorization, or can't access camera
        case AVAuthorizationStatus.denied: break
        case AVAuthorizationStatus.restricted: break
        default:
            break
        }
    }
    
    // MARK: - Callbacks
    
    func liveSession(_ session: LFLiveSession?, debugInfo: LFLiveDebug?) {
        print("debugInfo: \(String(describing: debugInfo?.currentBandwidth))")
    }
    
    func liveSession(_ session: LFLiveSession?, errorCode: LFLiveSocketErrorCode) {
        print("errorCode: \(errorCode.rawValue)")
    }
    
    func liveSession(_ session: LFLiveSession?, liveStateDidChange state: LFLiveState) {
        print("liveStateDidChange: \(state.rawValue)")
        switch state {
        case LFLiveState.ready:
            stateLabel.text = "No connection"
        case LFLiveState.pending:
            stateLabel.text = "Connecting"
        case LFLiveState.start:
            stateLabel.text = "Connected"
        case LFLiveState.error:
            stateLabel.text = "Connect error"
        case LFLiveState.stop:
            stateLabel.text = "Disconnect"
        default:
            break
        }
    }
    // MARK: - Getters and Setters
    //  默認分辨率368 ＊ 640  音頻：44.1 iphone6以上48  雙聲道  豎屏
    var session: LFLiveSession = {
        let audioConfiguration = LFLiveAudioConfiguration.defaultConfiguration(for: LFLiveAudioQuality.high)
        let videoConfiguration = LFLiveVideoConfiguration.defaultConfiguration(for: LFLiveVideoQuality.low3)
        let session = LFLiveSession(audioConfiguration: audioConfiguration, videoConfiguration: videoConfiguration)
        return session!
    }()
    // 視圖
    // swiftlint:disable line_length
    var containerView: UIView = {
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.width, height: UIScreen.height))
        containerView.backgroundColor = UIColor.clear
        containerView.autoresizingMask = [UIView.AutoresizingMask.flexibleHeight, UIView.AutoresizingMask.flexibleHeight]
        return containerView
    }()
    // Label
    var stateLabel: UILabel = {
        let stateLabel = UILabel(frame: CGRect(x: 20, y: 40, width: 80, height: 40))
        stateLabel.text = "No connect"
        stateLabel.textColor = UIColor.white
        stateLabel.font = UIFont.systemFont(ofSize: 14)
        return stateLabel
    }()
    // close
    var closeButton: UIButton = {
        let closeButton = UIButton(frame: CGRect(x: UIScreen.width - 10 - 44, y: 40, width: 44, height: 44))
        closeButton.setImage(UIImage.asset(.Icons_close_preview), for: UIControl.State())
        return closeButton
    }()
    // camera
    var cameraButton: UIButton = {
        let cameraButton = UIButton(frame: CGRect(x: UIScreen.width - 54 * 2, y: UIScreen.height - 140, width: 44, height: 44))
        cameraButton.setImage(UIImage.asset(.Icons_camera_preview), for: UIControl.State())
        return cameraButton
    }()
    //  camera
    var beautyButton: UIButton = {
        let beautyButton = UIButton(frame: CGRect(x: UIScreen.width - 54 * 3, y: UIScreen.height - 140, width: 44, height: 44))
        beautyButton.setImage(UIImage.asset(.Icons_camera_beauty), for: UIControl.State.selected)
        beautyButton.setImage(UIImage.asset(.Icons_camera_beauty_close), for: UIControl.State())
        return beautyButton
    }()
    
    // 開始直播
    var startLiveButton: UIButton = {
        let startLiveButton = UIButton(frame: CGRect(x: 30, y: UIScreen.height - 100, width: UIScreen.width - 10 - 44, height: 44))
        startLiveButton.layer.cornerRadius = 22
        startLiveButton.setTitleColor(UIColor.black, for: UIControl.State())
        startLiveButton.setTitle("Start sharing your life!", for: UIControl.State())
        startLiveButton.titleLabel!.font = UIFont.systemFont(ofSize: 14)
        startLiveButton.backgroundColor = UIColor.red
        return startLiveButton
    }()
    
    // MARK: - Events
    
    // start streming
    @objc func didTappedStartLiveButton(_ button: UIButton) {
        startLiveButton.isSelected = !startLiveButton.isSelected
        if startLiveButton.isSelected {
            startLiveButton.setTitle("Close sharing", for: UIControl.State())
            let stream = LFLiveStreamInfo()
            stream.url = Secret.pushStreamingUrl.rawValue
            session.startLive(stream)
        } else {
            startLiveButton.setTitle("Start sharing your life!", for: UIControl.State())
            session.stopLive()
        }
    }
    
    // beautify
    @objc func didTappedBeautyButton(_ button: UIButton) {
        session.beautyFace = !session.beautyFace
        beautyButton.isSelected = !session.beautyFace
    }
    
    // 摄像头
    @objc func didTappedCameraButton(_ button: UIButton) {
        let devicePositon = session.captureDevicePosition
        session.captureDevicePosition = (devicePositon == AVCaptureDevice.Position.back) ? AVCaptureDevice.Position.front : AVCaptureDevice.Position.back
    }
    
    // close
    @objc func didTappedCloseButton(_ button: UIButton) {
        print("close!")
        view.removeFromSuperview()
    }
}
