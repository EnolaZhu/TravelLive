//
//  PushViewController.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/4.
//

import UIKit
import CoreLocation
import ReplayKit
import TXLiteAVSDK_Professional

class PushViewController: UIViewController, V2TXLivePusherObserver {
    // MARK: - Property
    private var date = Int(Date().timeIntervalSince1970)
    private var longitude = Double()
    private var latitude = Double()
    private var postStreamerInfoTimer = Timer()
    private var recordingLimitTimer = Timer()
    private let time = 1000 * 3 * 60
    private let locationManager = CLLocationManager()
    private let pushStreamingProvider = PushStreamingProvider()
    private var lastSegmentIndex = 0
    var streamingUrl: PushStreamingObject?
    
    private let STTManagerShared = STTManager()
    private let pushStreamingShared = PushStreamingManager()
    // record
    private let record = RPScreenRecorder.shared()
    private var recordingSeconds = 0
    private var isRecordingClicked = false
    
    lazy var startLiveButton = UIButton()
    
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
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Location
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        // check if streamer is streaming by 5s
        //        postStreamerInfoTimer = Timer.scheduledTimer(timeInterval: TimeInterval(time), target: self, selector: #selector(postPushStreamingInfo), userInfo: nil, repeats: true)
        pushStreamingShared.createObserver(pushVC: self)
        
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        
        LottieAnimationManager.shared.createlottieAnimation(name: "loading", view: self.view, animationSpeed: 4, isRemove: false, theX: Int(UIScreen.width) / 8, theY: Int(UIScreen.height) / 4, width: 400, height: 400)
        
        // Create pushStreaming view
        pushStreamingShared.createRenderView(view: view)
        
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
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // 將timer的執行緒停止
        postStreamerInfoTimer.invalidate()
        deletePushStreming()
        
        tabBarController?.tabBar.isHidden = false
        startLiveButton.isHidden = false
        
        for view in self.view.subviews {
            view.removeFromSuperview()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Components
    
    lazy var containerView: UIView = {
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.width, height: UIScreen.height))
        containerView.backgroundColor = UIColor.clear
        containerView.autoresizingMask = [UIView.AutoresizingMask.flexibleHeight, UIView.AutoresizingMask.flexibleHeight]
        return containerView
    }()
    
    lazy var stateButton: UIButton = {
        let stateLabel = UIButton(frame: CGRect(x: 20, y: 40, width: 80, height: 40))
        stateLabel.roundCorners(cornerRadius: 8)
        stateLabel.setImage(UIImage.asset(.onAir), for: .normal)
        return stateLabel
    }()
    
    lazy var closeButton: UIButton = {
        let closeButton = UIButton(frame: CGRect(x: UIScreen.width - 60, y: 70, width: 32, height: 32))
        closeButton.setImage(UIImage.asset(.close)?.maskWithColor(color: UIColor.primary), for: UIControl.State())
        return closeButton
    }()
    
    lazy var cameraButton: UIButton = {
        let cameraButton = UIButton(frame: CGRect(x: UIScreen.width - 110, y: UIScreen.height - 180, width: 44, height: 44))
        cameraButton.setImage(UIImage.asset(.Icons_camera_preview)?.maskWithColor(color: .primary), for: UIControl.State())
        return cameraButton
    }()
    
    lazy var beautyButton: UIButton = {
        let beautyButton = UIButton(frame: CGRect(x: UIScreen.width - 160, y: UIScreen.height - 180, width: 44, height: 44))
        beautyButton.setImage(UIImage.asset(.Icons_camera_beauty)?.maskWithColor(color: .primary), for: UIControl.State.selected)
        beautyButton.setImage(UIImage.asset(.Icons_camera_beauty_close)?.maskWithColor(color: .primary), for: UIControl.State())
        return beautyButton
    }()
    
    lazy var recordButton: UIButton = {
        let recordButton = UIButton(frame: CGRect(x: UIScreen.width - 60, y: UIScreen.height - 180, width: 44, height: 44))
        recordButton.setImage(UIImage.asset(.play)?.maskWithColor(color: .primary), for: UIControl.State())
        return recordButton
    }()
    
    // Close live
    lazy var stopLiveButton: UIButton = {
        let stopLiveButton = UIButton(frame: CGRect(x: UIScreen.width - 60, y: 70, width: 44, height: 44))
        stopLiveButton.layer.cornerRadius = 22
        stopLiveButton.setTitleColor(UIColor.black, for: UIControl.State())
        stopLiveButton.setTitle("停止", for: UIControl.State())
        stopLiveButton.titleLabel!.font = UIFont.systemFont(ofSize: 14)
        stopLiveButton.backgroundColor = UIColor.primary
        return stopLiveButton
    }()

    private func setUpStartButton() {
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
    
    // MARK: - IBAction
    
    @objc func requestLive(_ sender: UIButton) {
        STTManagerShared.requestPermission(view: view) {
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
    
    @objc private func didTappedStopLiveButton(_ button: UIButton) {
        stopStreaming()
        NotificationCenter.default.post(name: .closePullingViewKey, object: nil)
        view.removeFromSuperview()
        tabBarController?.selectedIndex = 0
    }

    @objc private func didTappedBeautyButton(_ button: UIButton) {
        if beautyButton.isSelected {
            pushStreamingShared.startBeauty()
        } else {
            pushStreamingShared.closeBeauty()
        }
        beautyButton.isSelected = !beautyButton.isSelected
    }
    
    @objc private func didTappedCameraButton(_ button: UIButton) {
        pushStreamingShared.switchCamera()
    }
    
    @objc private func didTappedCloseButton(_ button: UIButton) {
        stopStreaming()
//        NotificationCenter.default.post(name: .closePullingViewKey, object: nil)
        
        //  Guide into map view
        view.removeFromSuperview()
        tabBarController?.selectedIndex = 0
    }
    
    @objc private func didTappedRecordButton(_ button: UIButton) {
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
            return view.makeToast("錄製失效", duration: 0.5, position: .center)
        }
        if record.isRecording {
            RecordManager.record.stopRecording(record, self) { result in
                switch result {
                case .success:
                    LottieAnimationManager.shared.createlottieAnimation(name: "Success", view: self.view, animationSpeed: 4, isRemove: false, theX: Int(UIScreen.width) / 2, theY: Int(UIScreen.height) / 2, width: 400, height: 400)
                case .failure:
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
                case .success:
                    self?.createRecordDoneAlert(message: "錄製時間已到")
                    self?.view.makeToast("錄製完成", duration: 1.0, position: .center)
                    
                case .failure:
                    self?.view.makeToast("錄製失敗", duration: 1.0, position: .center)
                }
            }
        }
    }
    
    @objc private func postPushStreamingInfo() {
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
    
    // MARK: - Method
    
    private func addPushPreview() {
        requestAccessForVideo()
        requestAccessForAudio()
        
        // Start local camera preview
        pushStreamingShared.createStartCamera(isStartCamera: true)
        
        view.backgroundColor = UIColor.clear
        view.addSubview(containerView)
        cameraButton.addTarget(self, action: #selector(didTappedCameraButton(_:)), for: .touchUpInside)
        beautyButton.addTarget(self, action: #selector(didTappedBeautyButton(_:)), for: .touchUpInside)
        stopLiveButton.addTarget(self, action: #selector(didTappedStopLiveButton(_:)), for: .touchUpInside)
        recordButton.addTarget(self, action: #selector(didTappedRecordButton(_:)), for: .touchUpInside)
    }
    
    private func startSpeechRecognization() {
        STTManagerShared.startRecognization(view: view) { response in
            var message = ""
            while self.lastSegmentIndex <= response.bestTranscription.segments.count - 1 {
                message += response.bestTranscription.segments[self.lastSegmentIndex].substring
                self.lastSegmentIndex += 1
            }
            let streamerText = ["streamer": message.replacingOccurrences(of: "。", with: "").replacingOccurrences(of: ".", with: "")]
            NotificationCenter.default.post(name: .textNotificationKey, object: nil, userInfo: streamerText)
        }
    }
    
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
        case AVAuthorizationStatus.authorized: break
            // user defuse authorization, or can't access camera
        case AVAuthorizationStatus.denied: break
        case AVAuthorizationStatus.restricted: break
        default: break
        }
    }
    
    private func cancelSpeechRecognization() {
        STTManagerShared.cancelRecognization()
    }
    
    func onPushStatusUpdate(_ status: V2TXLivePushStatus, message msg: String!, extraInfo: [AnyHashable: Any]!) {
        if status == V2TXLivePushStatus.connectSuccess {
            changeButtonTintColor(stateButton, true, UIImage.asset(.onAir) ?? UIImage())
        } else {
            changeButtonTintColor(stateButton, false, UIImage.asset(.onAir) ?? UIImage())
        }
    }
    
    private func stopStreaming() {
        pushStreamingShared.stopStreaming()
        deletePushStreming()
        cancelSpeechRecognization()
    }
    
    func createRecordDoneAlert(message: String) {
            let controller = UIAlertController.init(title: "提示", message: message, preferredStyle: .alert)
            controller.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
                controller.dismiss(animated: true, completion: nil)
            }))
            self.present(controller, animated: true, completion: nil)
    }
    
    private func deletePushStreming() {
        pushStreamingProvider.deletePushStreamingInfo(streamerId: userID) { _ in
            print("delete success")
        }
    }
    
    private func startLive(_ url: String) {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, options: .defaultToSpeaker)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            
            pushStreamingShared.startPush(url: url)
            startSpeechRecognization()
        } catch {
            view.makeToast("開始直播發生錯誤", duration: 1.0, position: .center)
        }
    }
    
    private func createPushStreamingRuleAlert() {
        let ruleAlertController = UIAlertController(title: "警告", message: ruleMessage, preferredStyle: .alert)
        
        ruleAlertController.addAction(UIAlertAction(title: "我會遵守直播規則", style: .default, handler: { _ in
        }))
        
        ruleAlertController.view.tintColor = UIColor.black
        ruleAlertController.setMessageAlignment(.left)
        self.present(ruleAlertController, animated: true)
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
