//
//  PushViewController.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/4.
//

import UIKit
import LFLiveKit
import CoreLocation
import Speech
import ReplayKit

class PushViewController: UIViewController, LFLiveSessionDelegate {
    var date = Int(Date().timeIntervalSince1970)
    var longitude = Double()
    var latitude = Double()
    var timer = Timer()
    private let secondDayMillis = 86400
    private let time = 1000 * 3 * 60
    // Hard code streamerID
    let streamerId = "Enola"
    let pushStreamingProvider = PushStreamingProvider()
    let locationManager = CLLocationManager()
    // STT
    let audioEngine = AVAudioEngine()
    let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "zh_Hans_CN"))
    let request = SFSpeechAudioBufferRecognitionRequest()
    var task: SFSpeechRecognitionTask!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Location
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        // Timer
        //        self.timer = Timer.scheduledTimer(timeInterval: TimeInterval(time), target: self, selector: #selector(postPushStreamingInfo), userInfo: nil, repeats: true)
        session.delegate = self
        session.preView = view
        addPushPreview()
        addChatView()
        view.addSubview(cameraButton)
        view.addSubview(closeButton)
        view.addSubview(beautyButton)
        view.addSubview(startLiveButton)
        view.addSubview(recordButton)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // 將timer的執行緒停止
        timer.invalidate()
        // Cancel STT
        if task != nil {
            cancelSpeechRecognization()
        }
        tabBarController?.tabBar.isHidden = false
    }
    
    private func addPushPreview() {
        requestAccessForVideo()
        requestAccessForAudio()
        view.backgroundColor = UIColor.clear
        view.addSubview(containerView)
        containerView.addSubview(stateLabel)
        cameraButton.addTarget(self, action: #selector(didTappedCameraButton(_:)), for: .touchUpInside)
        beautyButton.addTarget(self, action: #selector(didTappedBeautyButton(_:)), for: .touchUpInside)
        startLiveButton.addTarget(self, action: #selector(didTappedStartLiveButton(_:)), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(didTappedCloseButton(_:)), for: .touchUpInside)
        recordButton.addTarget(self, action: #selector(didTappedRecordButton(_:)), for: .touchUpInside)
    }
    
    func requestPermission() {
        SFSpeechRecognizer.requestAuthorization { authState in
            OperationQueue.main.addOperation {
                if authState == .authorized {
                    print("Accepted")
                } else if authState == .denied {
                    self.alertView(message: "User denied the permission")
                } else if authState == .notDetermined {
                    self.alertView(message: "In user phone there is no speech recognization")
                } else if authState == .restricted {
                    self.alertView(message: "User has been restricted for using the speech recognization")
                }
            }
        }
    }
    
    func alertView(message: String) {
        let controller = UIAlertController.init(title: "Error ocured...", message: message, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
            controller.dismiss(animated: true, completion: nil)
        }))
        self.present(controller, animated: true, completion: nil)
    }
    
    func startSpeechRecognization(){
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, _) in
            self.request.append(buffer)
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch let error {
            alertView(message: "Error comes here for starting the audio listner =\(error.localizedDescription)")
        }
        
        guard let myRecognization = SFSpeechRecognizer() else {
            self.alertView(message: "Recognization is not allow on your local")
            return
        }
        
        if !myRecognization.isAvailable {
            self.alertView(message: "Recognization is free right now, Please try again after some time.")
        }
        
        task = speechRecognizer?.recognitionTask(with: request, resultHandler: { (response, error) in
            guard let response = response else {
                if error != nil {
                    self.alertView(message: error.debugDescription)
                } else {
                    self.alertView(message: "Problem in giving the response")
                }
                return
            }
            let message = response.bestTranscription.formattedString
            let streamerText = ["streamer": message]
            NotificationCenter.default.post(name: .textNotificationKey, object: nil, userInfo: streamerText)
        })
    }
    
    // swiftlint:disable trailing_whitespace
    private func addChatView() {
        let chatMessageVC = UIStoryboard.chat.instantiateViewController(withIdentifier: String(describing: ChatViewController.self)
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
    func cancelSpeechRecognization() {
        task.finish()
        task.cancel()
        task = nil
        request.endAudio()
        audioEngine.stop()
        //audioEngine.inputNode.removeTap(onBus: 0)
        
        //MARK: UPDATED
        if audioEngine.inputNode.numberOfInputs > 0 {
            audioEngine.inputNode.removeTap(onBus: 0)
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
            stateLabel.text = ComponentText.noConnect.text
        case LFLiveState.pending:
            stateLabel.text = ComponentText.connecting.text
        case LFLiveState.start:
            stateLabel.text = ComponentText.connected.text
        case LFLiveState.error:
            stateLabel.text = ComponentText.connectError.text
        case LFLiveState.stop:
            stateLabel.text = ComponentText.disconnect.text
        default:
            break
        }
    }
    // MARK: - Getters and Setters
    //  默認分辨率368 ＊ 640  音頻：44.1 iphone6以上48  雙聲道  豎屏
    var session: LFLiveSession = {
        let audioConfiguration = LFLiveAudioConfiguration.defaultConfiguration(for: LFLiveAudioQuality.low)
        let videoConfiguration = LFLiveVideoConfiguration.defaultConfiguration(for: LFLiveVideoQuality.low1)
        let session = LFLiveSession(audioConfiguration: audioConfiguration, videoConfiguration: videoConfiguration)
        return session!
    }()
    // View
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
        stateLabel.text = ComponentText.noConnect.text
        stateLabel.textColor = UIColor.white
        stateLabel.font = UIFont.systemFont(ofSize: 14)
        return stateLabel
    }()
    // close
    var closeButton: UIButton = {
        let closeButton = UIButton(frame: CGRect(x: UIScreen.width - 10 - 44, y: 80, width: 44, height: 44))
        closeButton.setImage(UIImage.asset(.Icons_close_preview), for: UIControl.State())
        return closeButton
    }()
    // camera
    var cameraButton: UIButton = {
        let cameraButton = UIButton(frame: CGRect(x: UIScreen.width - 60, y: UIScreen.height - 430, width: 44, height: 44))
        cameraButton.setImage(UIImage.asset(.Icons_camera_preview), for: UIControl.State())
        return cameraButton
    }()
    //  camera
    var beautyButton: UIButton = {
        let beautyButton = UIButton(frame: CGRect(x: UIScreen.width - 60, y: UIScreen.height - 380, width: 44, height: 44))
        beautyButton.setImage(UIImage.asset(.Icons_camera_beauty), for: UIControl.State.selected)
        beautyButton.setImage(UIImage.asset(.Icons_camera_beauty_close), for: UIControl.State())
        return beautyButton
    }()
    // record
    var recordButton: UIButton = {
        let recordButton = UIButton(frame: CGRect(x: UIScreen.width - 60, y: UIScreen.height - 530, width: 44, height: 44))
        recordButton.setImage(UIImage.asset(.play), for: UIControl.State())
        return recordButton
    }()
    
    // 開始直播
    var startLiveButton: UIButton = {
        let startLiveButton = UIButton(frame: CGRect(x: UIScreen.width - 60, y: UIScreen.height - 280, width: 44, height: 44))
        startLiveButton.layer.cornerRadius = 22
        startLiveButton.setTitleColor(UIColor.black, for: UIControl.State())
        startLiveButton.setTitle(ComponentText.startLive.text, for: UIControl.State())
        startLiveButton.titleLabel!.font = UIFont.systemFont(ofSize: 14)
        startLiveButton.backgroundColor = UIColor.primary
        return startLiveButton
    }()
    
    // MARK: - Events
    
    // start streming
    @objc func didTappedStartLiveButton(_ button: UIButton) {
        // STT
        requestPermission()
        startSpeechRecognization()
        
        let key = Secret.liveKey.rawValue
        let hexTime = String(format: "%02X", date + secondDayMillis)
        let secret = (key + streamerId + hexTime).md5
        let pushStreamingUrl = Secret.pushStreamingUrl.rawValue + streamerId + "?txSecret=" + secret + "&txTime=" + hexTime
        startLiveButton.isSelected = !startLiveButton.isSelected
        if startLiveButton.isSelected {
            startLiveButton.setTitle(ComponentText.closelive.text, for: UIControl.State())
            let stream = LFLiveStreamInfo()
            stream.url = pushStreamingUrl
            session.startLive(stream)
        } else {
            startLiveButton.setTitle(ComponentText.startLive.text, for: UIControl.State())
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
        // 測試！！！
        //        deletePushStreming()
        //        postPushStreamingInfo()
        self.timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(postPushStreamingInfo), userInfo: nil, repeats: true)
        let devicePositon = session.captureDevicePosition
        session.captureDevicePosition = (devicePositon == AVCaptureDevice.Position.back) ? AVCaptureDevice.Position.front : AVCaptureDevice.Position.back
    }
    
    // close
    @objc func didTappedCloseButton(_ button: UIButton) {
        print("close!")
        view.removeFromSuperview()
        tabBarController?.selectedIndex = 0
//        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
//        if let tabBarController = self.presentingViewController as? UITabBarController {
//                       tabBarController.selectedIndex = 0
//                   }
//        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
//        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    // record
    @objc func didTappedRecordButton(_ button: UIButton) {
        // swiftlint:disable force_cast identifier_name
        let record = RPScreenRecorder.shared()
        guard record.isAvailable else {
            print("ReplayKit unavailable")
            return
        }
        if record.isRecording {
            RecordManager.record.stopRecording(button, record, self)
        }
        else {
             RecordManager.record.startRecording(button, record)
        }
    }
    
    @objc func postPushStreamingInfo() {
        pushStreamingProvider.postPushStreamingInfo(streamerId: streamerId, longitude: longitude, latitude: latitude) { [weak self] result in
            print("post success")
        }
    }
    
    func deletePushStreming() {
        pushStreamingProvider.deletePushStreamingInfo(streamerId: streamerId) { [weak self] result in
            print("delete success")
        }
    }
}

private enum ComponentText {
    case noConnect
    case connecting
    case connected
    case connectError
    case disconnect
    case startLive
    case closelive
    var text: String {
        switch self {
        case .noConnect: return "No connect"
        case .connecting: return "Connecting"
        case .connected: return "Connected"
        case .connectError: return "Connect error"
        case .disconnect: return "Disconnect"
        case .startLive: return "Start"
        case .closelive: return "Stop"
        }
    }
}

extension PushViewController: CLLocationManagerDelegate, RPPreviewViewControllerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        longitude = locValue.longitude
        latitude = locValue.latitude
    }
    
    func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
        previewController.dismiss(animated: true, completion: nil)
    }
}
