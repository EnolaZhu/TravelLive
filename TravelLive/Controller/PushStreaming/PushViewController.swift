//
//  PushViewController.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/4.
//

import UIKit
import CoreLocation
import Speech
import ReplayKit
import TXLiteAVSDK_Professional

class PushViewController: UIViewController, V2TXLivePusherObserver {
    var date = Int(Date().timeIntervalSince1970)
    var longitude = Double()
    var latitude = Double()
    var postStreamerInfoTimer = Timer()
    var recordingLimitTimer = Timer()
    private let secondDayMillis = 86400
    private let time = 1000 * 3 * 60
    let locationManager = CLLocationManager()
    // PushStreaming
    var pusher: V2TXLivePusher! = V2TXLivePusher.init(liveMode: V2TXLiveMode.RTMP)
    let pushStreamingProvider = PushStreamingProvider()
    // STT
    let audioEngine = AVAudioEngine()
    let speechRecognizer: SFSpeechRecognizer! = SFSpeechRecognizer(locale: Locale.init(identifier: "zh-Hant-TW"))
    var request: SFSpeechAudioBufferRecognitionRequest?
    var task: SFSpeechRecognitionTask!
    var streamingUrl: PushStreamingObject?
    var lastSegmentIndex = 0
    
    // record
    var recordingTime = Int()
    let record = RPScreenRecorder.shared()
    var isRecordingClicked = false
    private var recordingSeconds = 0
    
    let imagePickerController = UIImagePickerController()
    var startLiveButton = UIButton()
    
    private let ruleMessage = """
若出現以下違規，將結束直播：
⦿ 違法
⦿ 情色、裸露
⦿ 煙、酒、賭、毒
⦿ 侵犯智慧財產權
⦿ 屢次遭到封鎖、檢舉
⦿ 歧視、霸凌、語言暴力
⦿ 暴力、傷害、血腥、危險
"""
    
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
        // check if streamer is streaming by 5s
        //        postStreamerInfoTimer = Timer.scheduledTimer(timeInterval: TimeInterval(time), target: self, selector: #selector(postPushStreamingInfo), userInfo: nil, repeats: true)
        pusher.setObserver(self)
        
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        
        LottieAnimationManager.shared.createlottieAnimation(name: "loading", view: self.view, animationSpeed: 4, isRemove: false, theX: Int(UIScreen.width) / 8, theY: Int(UIScreen.height) / 4, width: 400, height: 400)
        
        // 创建一个 view 对象，并将其嵌入到当前界面中
        pusher.setRenderView(view)
        addPushPreview()
        closeButton.isHidden = false
        view.addSubview(closeButton)
        closeButton.addTarget(self, action: #selector(didTappedCloseButton(_:)), for: .touchUpInside)
        setUpStartButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        createPushStreamingRuleAlert()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // 將timer的執行緒停止
        postStreamerInfoTimer.invalidate()
        // Cancel STT
        //        if task != nil {
        //            cancelSpeechRecognization()
        //        }
        deletePushStreming()
        tabBarController?.tabBar.isHidden = false
        
        startLiveButton.isHidden = false
        
        for view in self.view.subviews {
            view.removeFromSuperview()
        }
    }
    
    private func addPushPreview() {
        requestAccessForVideo()
        requestAccessForAudio()
        
        //启动本地摄像头预览
        pusher.startCamera(true)
        pusher.startMicrophone()
        
        view.backgroundColor = UIColor.clear
        view.addSubview(containerView)
        cameraButton.addTarget(self, action: #selector(didTappedCameraButton(_:)), for: .touchUpInside)
        beautyButton.addTarget(self, action: #selector(didTappedBeautyButton(_:)), for: .touchUpInside)
        stopLiveButton.addTarget(self, action: #selector(didTappedStopLiveButton(_:)), for: .touchUpInside)
        recordButton.addTarget(self, action: #selector(didTappedRecordButton(_:)), for: .touchUpInside)
    }
    
    private func createPushStreamingRuleAlert() {
        let ruleAlertController = UIAlertController(title: "警告", message: ruleMessage, preferredStyle: .alert)
        
        ruleAlertController.addAction(UIAlertAction(title: "我會遵守直播規則", style: .default, handler: { _ in
        }))
        
        ruleAlertController.view.tintColor = UIColor.black
        ruleAlertController.setMessageAlignment(.left)
        self.present(ruleAlertController, animated: true)
    }
    
    func requestPermission(_ callback: @escaping () -> Void) {
        SFSpeechRecognizer.requestAuthorization { authState in
            OperationQueue.main.addOperation {
                if authState == .authorized {
                    callback()
                } else if authState == .denied {
                    self.alertView(message: "使用者拒絕開放權限")
                } else if authState == .notDetermined {
                    self.alertView(message: "使用者手機裡沒有聲音辨識")
                } else if authState == .restricted {
                    self.alertView(message: "使用者限制權限")
                }
            }
        }
    }
    
    func alertView(message: String) {
        let controller = UIAlertController.init(title: "發生錯誤.", message: message, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "好的", style: .default, handler: { _ in
            controller.dismiss(animated: true, completion: nil)
        }))
        self.present(controller, animated: true, completion: nil)
    }
    
    private func startSpeechRecognization() {
        audioEngine.inputNode.removeTap(onBus: 0)
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        request = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = request else { fatalError("Unable to created a SFSpeechAudioBufferRecognitionRequest object") }
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, _) in
            recognitionRequest.append(buffer)
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
        
        task = speechRecognizer.recognitionTask(with: recognitionRequest, resultHandler: { (response, error) in
            guard let response = response else {
                if self.task == nil {
                    return
                }
                if error != nil {
                    self.alertView(message: error.debugDescription)
                } else {
                    self.alertView(message: "Problem in giving the response")
                }
                return
            }
            var message = ""
            while self.lastSegmentIndex <= response.bestTranscription.segments.count - 1 {
                message += response.bestTranscription.segments[self.lastSegmentIndex].substring
                self.lastSegmentIndex += 1
            }
            let streamerText = ["streamer": message.replacingOccurrences(of: "。", with: "").replacingOccurrences(of: ".", with: "")]
            NotificationCenter.default.post(name: .textNotificationKey, object: nil, userInfo: streamerText)
        })
    }
    
    // swiftlint:disable trailing_whitespace
    private func addChatView() {
        let chatMessageVC = UIStoryboard.chat.instantiateViewController(withIdentifier: String(describing: ChatViewController.self)
        )
        guard let chatVC = chatMessageVC as? ChatViewController else { return }
        chatVC.isFromStreamer = true
        chatVC.channelName = userID
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
                    }
                }
            })
            // open authorizatio, continuew
        case AVAuthorizationStatus.authorized:
            // user defuse authorization, or can't access camera
            break
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
        audioEngine.stop()
        if audioEngine.inputNode.numberOfInputs > 0 {
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        request?.endAudio()
        request?.shouldReportPartialResults = false
        
        if task == nil {
            return
        } else {
            task.finish()
            task.cancel()
            task = nil
        }
    }

    func onPushStatusUpdate(_ status: V2TXLivePushStatus, message msg: String!, extraInfo: [AnyHashable: Any]!) {
        if status == V2TXLivePushStatus.connectSuccess {
            changeButtonTintColor(stateButton, true, UIImage.asset(.onAir) ?? UIImage())
        } else {
            changeButtonTintColor(stateButton, false, UIImage.asset(.onAir) ?? UIImage())
        }
    }

    // View
    // swiftlint:disable line_length
    lazy var containerView: UIView = {
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.width, height: UIScreen.height))
        containerView.backgroundColor = UIColor.clear
        containerView.autoresizingMask = [UIView.AutoresizingMask.flexibleHeight, UIView.AutoresizingMask.flexibleHeight]
        return containerView
    }()
    // Label
    lazy var stateButton: UIButton = {
        let stateLabel = UIButton(frame: CGRect(x: 20, y: 40, width: 80, height: 40))
        stateLabel.roundCorners(cornerRadius: 8)
//        stateLabel.isEnabled = false
//        stateLabel.text = ComponentText.noConnect.text
        stateLabel.setImage(UIImage.asset(.onAir), for: .normal)
        return stateLabel
    }()
    // close
    lazy var closeButton: UIButton = {
        let closeButton = UIButton(frame: CGRect(x: UIScreen.width - 60, y: 70, width: 32, height: 32))
        closeButton.setImage(UIImage.asset(.close)?.maskWithColor(color: UIColor.primary), for: UIControl.State())
        return closeButton
    }()
    // camera
    lazy var cameraButton: UIButton = {
        let cameraButton = UIButton(frame: CGRect(x: UIScreen.width - 110, y: UIScreen.height - 180, width: 44, height: 44))
        cameraButton.setImage(UIImage.asset(.Icons_camera_preview)?.maskWithColor(color: .primary), for: UIControl.State())
        return cameraButton
    }()
    //  camera
    lazy var beautyButton: UIButton = {
        let beautyButton = UIButton(frame: CGRect(x: UIScreen.width - 160, y: UIScreen.height - 180, width: 44, height: 44))
        beautyButton.setImage(UIImage.asset(.Icons_camera_beauty)?.maskWithColor(color: .primary), for: UIControl.State.selected)
        beautyButton.setImage(UIImage.asset(.Icons_camera_beauty_close)?.maskWithColor(color: .primary), for: UIControl.State())
        return beautyButton
    }()
    // record
    lazy var recordButton: UIButton = {
        let recordButton = UIButton(frame: CGRect(x: UIScreen.width - 60, y: UIScreen.height - 180, width: 44, height: 44))
        recordButton.setImage(UIImage.asset(.play)?.maskWithColor(color: .primary), for: UIControl.State())
        return recordButton
    }()
    
    // 結束直播
    lazy var stopLiveButton: UIButton = {
        let stopLiveButton = UIButton(frame: CGRect(x: UIScreen.width - 60, y: 70, width: 44, height: 44))
        stopLiveButton.layer.cornerRadius = 22
        stopLiveButton.setTitleColor(UIColor.black, for: UIControl.State())
        stopLiveButton.setTitle("停止", for: UIControl.State())
        stopLiveButton.titleLabel!.font = UIFont.systemFont(ofSize: 14)
        stopLiveButton.backgroundColor = UIColor.primary
        return stopLiveButton
    }()

    func setUpStartButton() {
        view.addSubview(startLiveButton)
        startLiveButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            startLiveButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -50),
            startLiveButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 50),
            startLiveButton.topAnchor.constraint(equalTo: view.topAnchor, constant: UIScreen.height - 150),
            startLiveButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100)
        ])
        
        startLiveButton.layer.cornerRadius = 22
        startLiveButton.setTitleColor(UIColor.black, for: UIControl.State())
        startLiveButton.setTitle("開始直播", for: UIControl.State())
        startLiveButton.setTitleColor(UIColor.white, for: .normal)
        startLiveButton.titleLabel!.font = UIFont.systemFont(ofSize: 22)
        startLiveButton.backgroundColor = UIColor.primary
        startLiveButton.addTarget(self, action: #selector(requestLive(_:)), for: .touchUpInside)
    }
    
    // MARK: - Events
    
    // start streming
    
    @objc func requestLive(_ sender: UIButton) {
        requestPermission {
            self.postPushStreamingInfo()
            self.startLiveButton.isHidden = true
            self.closeButton.isHidden = true
            self.addChatView()
            self.view.addSubview(self.cameraButton)
            self.view.addSubview(self.beautyButton)
            self.view.addSubview(self.recordButton)
            self.view.addSubview(self.stopLiveButton)
            self.view.addSubview(self.stateButton)
        }
    }
    
    private func stopStreaming() {
        pusher.stopPush()
        pusher.stopMicrophone()
        pusher.stopCamera()
        deletePushStreming()
        cancelSpeechRecognization()
    }
    
    @objc func didTappedStopLiveButton(_ button: UIButton) {
        stopStreaming()
        NotificationCenter.default.post(name: .closePullingViewKey, object: nil)
        view.removeFromSuperview()
        tabBarController?.selectedIndex = 0
    }

    // beautify
    @objc func didTappedBeautyButton(_ button: UIButton) {
        if beautyButton.isSelected {
            pusher.getBeautyManager().setBeautyStyle(TXBeautyStyle.nature)
            pusher.getBeautyManager().setBeautyLevel(Float(0))
        } else {
            pusher.getBeautyManager().setBeautyStyle(TXBeautyStyle.smooth)
            pusher.getBeautyManager().setBeautyLevel(Float(9))
        }
        beautyButton.isSelected = !beautyButton.isSelected
    }
    
    // 摄像头
    @objc func didTappedCameraButton(_ button: UIButton) {
        pusher.getDeviceManager().switchCamera(!pusher.getDeviceManager().isFrontCamera())
    }
    
    // close
    @objc func didTappedCloseButton(_ button: UIButton) {
        
        print("=== didTappedCloseButton")
        
        stopStreaming()
//        NotificationCenter.default.post(name: .closePullingViewKey, object: nil)
        
        // Make into map view
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
        // Limit streamer recording time
        recordingLimitTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(incrementSeconds), userInfo: nil, repeats: true)
        
        // change button image
        isRecordingClicked = !isRecordingClicked
        if isRecordingClicked {
            recordButton.setImage(UIImage.asset(.stop)?.maskWithColor(color: .primary), for: .normal)
        } else {
            recordButton.setImage(UIImage.asset(.play)?.maskWithColor(color: .primary), for: .normal)
        }
        // start record
        
        guard record.isAvailable else {
            print("ReplayKit unavailable")
            return
        }
        if record.isRecording {
            RecordManager.record.stopRecording(record, self) { result in
                switch result {
                case .success(_):
                    LottieAnimationManager.shared.createlottieAnimation(name: "Success", view: self.view, animationSpeed: 4, isRemove: false, theX: Int(UIScreen.width) / 2, theY: Int(UIScreen.height) / 2, width: 400, height: 400)
                case .failure(_):
                    LottieAnimationManager.shared.createlottieAnimation(name: "Fail", view: self.view, animationSpeed: 4, isRemove: false, theX: Int(UIScreen.width) / 2, theY: Int(UIScreen.height) / 2, width: 400, height: 400)
                }
            }
        } else {
            RecordManager.record.startRecording(button, record)
        }
    }
    
    @objc func incrementSeconds() {
        recordingSeconds += 1
        if recordingSeconds == 10 {
            // Stop timer
            recordingLimitTimer.invalidate()
            
            RecordManager.record.stopRecording(record, self) { [weak self] result in
                // 增加停止提醒
                
                switch result {
                case .success(_):
                    self?.createRecordDoneAlert(message: "錄製時間已到")
                    
                    LottieAnimationManager.shared.createlottieAnimation(name: "Success", view: self?.view ?? UIView(), animationSpeed: 4, isRemove: false, theX: Int(UIScreen.width) / 2, theY: Int(UIScreen.height) / 2, width: 400, height: 400)
                    
                case .failure(_):
                    LottieAnimationManager.shared.createlottieAnimation(name: "Fail", view: self?.view ?? UIView(), animationSpeed: 4, isRemove: false, theX: Int(UIScreen.width) / 2, theY: Int(UIScreen.height) / 2, width: 400, height: 400)
                }
            }
        }
    }
    
    
    func createRecordDoneAlert(message: String) {
            let controller = UIAlertController.init(title: "提示", message: message, preferredStyle: .alert)
            controller.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
                controller.dismiss(animated: true, completion: nil)
            }))
            self.present(controller, animated: true, completion: nil)
    }
    
    @objc func postPushStreamingInfo() {
        pushStreamingProvider.postPushStreamingInfo(streamerId: userID, longitude: longitude, latitude: latitude) { [weak self] result in
            switch result {
            case .success(let url):
                self?.streamingUrl = url
                self?.startLive(self?.streamingUrl?.pushUrl ?? "")
            case .failure:
                print("Failed")
            }
        }
    }
    
    func deletePushStreming() {
        pushStreamingProvider.deletePushStreamingInfo(streamerId: userID) { [weak self] result in
            print("delete success")
        }
    }
    
    func startLive(_ url: String) {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, options: .defaultToSpeaker)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            
            pusher.startPush(url)
            startSpeechRecognization()
        } catch {
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
        case .noConnect: return "沒有連線"
        case .connecting: return "連線中"
        case .connected: return "已連線"
        case .connectError: return "連線失敗"
        case .disconnect: return "關閉連線"
        case .startLive: return "開始"
        case .closelive: return "停止"
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

extension PushViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
}
