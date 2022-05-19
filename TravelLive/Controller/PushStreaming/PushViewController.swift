//
//  PushViewController.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/4.
//

import UIKit
import CoreLocation
import TXLiteAVSDK_Professional

class PushViewController: UIViewController, V2TXLivePusherObserver {
    // MARK: - Property
    private var date = Int(Date().timeIntervalSince1970)
    private var location = CLLocationCoordinate2D()
    private var postStreamerInfoTimer = Timer()
    private var recordingLimitTimer = Timer()
    private let time = 1000 * 3 * 60
    // post streamer location by 3s
    private let locationManager = CLLocationManager()
    private let pushStreamingProvider = PushStreamingProvider()
    private var lastSegmentIndex = 0
    var streamingUrl: PushStreamingObject?
    
    private let sttManager = STTManager()
    private let pushStreamingManager = PushStreamingManager()
    // record
    private let recorder = RPScreenRecorder.shared() //
    private var recordingSeconds = 0 // data
    private var isRecordingClicked = false
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // location
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        // check if streamer is streaming by 5s
        //        postStreamerInfoTimer = Timer.scheduledTimer(timeInterval: TimeInterval(time), target: self, selector: #selector(postPushStreamingInfo), userInfo: nil, repeats: true)
        pushStreamingManager.createObserver(pushVC: self) //
        
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        // 3-4 param
        LottieAnimationManager.shared.createlottieAnimation(name: LottieAnimation.lodingAnimation.title, view: view, isRemove: false, location: CGRect(x: Int(UIScreen.width) / 8, y: Int(UIScreen.height) / 4, width: 400, height: 400))
        
        // create pushStreaming view
        pushStreamingManager.createRenderView(view: view)
        
        addPushPreview()
        closeButton.isHidden = false
        setUpCloseButton()
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
        // stop timer thread
        recordingLimitTimer.invalidate()
        postStreamerInfoTimer.invalidate()
        deletePushStreaming()
        
        tabBarController?.tabBar.isHidden = false
        startLiveButton.isHidden = false
        
        //
        for view in self.view.subviews {
            view.removeFromSuperview()
        }
    }
    
    // MARK: - Components
    
    lazy var startLiveButton = UIButton()
    lazy var closeButton = UIButton()
    lazy var stateButton = UIButton()
    lazy var cameraButton = UIButton()
    lazy var beautyButton = UIButton()
    lazy var recordButton = UIButton()
    lazy var stopLiveButton = UIButton()
    
    func setUpStateButton() {
        view.addSubview(stateButton)
        stateButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stateButton.widthAnchor.constraint(equalToConstant: 80),
            stateButton.heightAnchor.constraint(equalToConstant: 40),
            stateButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            stateButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 40)
        ])
        stateButton.setImage(UIImage.asset(.onAir)?.maskWithColor(color: UIColor.primary), for: .normal)
    }
    
    func setUpCloseButton() {
        view.addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            closeButton.widthAnchor.constraint(equalToConstant: 32),
            closeButton.heightAnchor.constraint(equalToConstant: 32),
            closeButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: UIScreen.width - 60),
            closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 70)
        ])
        closeButton.setImage(UIImage.asset(.close)?.maskWithColor(color: UIColor.primary), for: .normal)
    }
    
    func setUpCameraButton() {
        view.addSubview(cameraButton)
        cameraButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cameraButton.widthAnchor.constraint(equalToConstant: 44),
            cameraButton.heightAnchor.constraint(equalToConstant: 44),
            cameraButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: UIScreen.width - 110),
            cameraButton.topAnchor.constraint(equalTo: view.topAnchor, constant: UIScreen.height - 180)
        ])
        cameraButton.setImage(UIImage.asset(.Icons_camera_preview)?.maskWithColor(color: UIColor.primary), for: .normal)
    }
    
    func setUpBeautyButton() {
        view.addSubview(beautyButton)
        beautyButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            beautyButton.widthAnchor.constraint(equalToConstant: 44),
            beautyButton.heightAnchor.constraint(equalToConstant: 44),
            beautyButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: UIScreen.width - 160),
            beautyButton.topAnchor.constraint(equalTo: view.topAnchor, constant: UIScreen.height - 180)
        ])
        beautyButton.setImage(UIImage.asset(.Icons_camera_beauty_close)?.maskWithColor(color: UIColor.primary), for: .normal)
        beautyButton.setImage(UIImage.asset(.Icons_camera_beauty)?.maskWithColor(color: UIColor.primary), for: .selected)
    }
    
    func setUpRecordButton() {
        view.addSubview(recordButton)
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            recordButton.widthAnchor.constraint(equalToConstant: 44),
            recordButton.heightAnchor.constraint(equalToConstant: 44),
            recordButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: UIScreen.width - 60),
            recordButton.topAnchor.constraint(equalTo: view.topAnchor, constant: UIScreen.height - 180)
        ])
        recordButton.setImage(UIImage.asset(.play)?.maskWithColor(color: UIColor.primary), for: .normal)
    }
    
    func setUpStopLiveButton() {
        view.addSubview(stopLiveButton)
        stopLiveButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stopLiveButton.widthAnchor.constraint(equalToConstant: 44),
            stopLiveButton.heightAnchor.constraint(equalToConstant: 44),
            stopLiveButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: UIScreen.width - 60),
            stopLiveButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 70)
        ])
        stopLiveButton.layer.cornerRadius = 22
        stopLiveButton.setTitleColor(UIColor.black, for: .normal)
        stopLiveButton.setTitle("停止", for: .normal)
        stopLiveButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        stopLiveButton.backgroundColor = UIColor.primary
    }
    
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
        startLiveButton.setTitle("開始直播", for: UIControl.State()) //
        startLiveButton.setTitleColor(UIColor.white, for: .normal)
        startLiveButton.titleLabel!.font = UIFont.systemFont(ofSize: 22)
        startLiveButton.backgroundColor = UIColor.primary
        startLiveButton.addTarget(self, action: #selector(requestLive(_:)), for: .touchUpInside)
    }
    
    // MARK: - IBAction
    
    @objc func requestLive(_ sender: UIButton) {
        sttManager.requestPermission(view: view) {
            self.postPushStreamingInfo()
            self.startLiveButton.isHidden = true
            self.closeButton.isHidden = true
            self.addChatView()
            self.setUpCameraButton()
            self.setUpBeautyButton()
            self.setUpRecordButton()
            self.setUpStopLiveButton()
            self.setUpStateButton()
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
            pushStreamingManager.startBeauty()
        } else {
            pushStreamingManager.closeBeauty()
        }
        beautyButton.isSelected = !beautyButton.isSelected
    }
    
    @objc private func didTappedCameraButton(_ button: UIButton) {
        pushStreamingManager.switchCamera()
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
        guard recorder.isAvailable else {
            return view.makeToast("錄製失效", duration: 0.5, position: .center)
        }
        if recorder.isRecording {
            RecordManager.record.stopRecording(recorder, self) { [weak self] result in
                guard let self = self else { return }
                let location = CGRect(x: Int(UIScreen.width) / 4, y: Int(UIScreen.height) / 4, width: 400, height: 400)
                
                switch result {
                case .success:
                    LottieAnimationManager.shared.createlottieAnimation(name: LottieAnimation.success.title, view: self.view, location: location)
                case .failure:
                    LottieAnimationManager.shared.createlottieAnimation(name: LottieAnimation.fail.title, view: self.view, location: location)
                }
            }
        } else {
            RecordManager.record.startRecording(recorder) { [weak self] result in
                if result == "" {
                    button.setImage(UIImage.asset(.stop), for: .normal)
                } else {
                    self?.view.makeToast("開始錄製失敗", duration: 1.0, position: .center)
                }
            }
        }
    }
    
    @objc func incrementSeconds() {
        recordingSeconds += 1
        if recordingSeconds == 10 {
            // Stop timer
            recordingLimitTimer.invalidate()// better
            
            RecordManager.record.stopRecording(recorder, self) { [weak self] result in
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
        pushStreamingProvider.postPushStreamingInfo(streamerId: UserManager.shared.userID, longitude: location.longitude, latitude: location.latitude) { [weak self] result in
            switch result {
            case .success(let url):
                self?.streamingUrl = url
                self?.startLive(self?.streamingUrl?.pushUrl ?? "")
            case .failure:
                self?.view.makeToast("直播主定位失敗", duration: 1.0, position: .center)
            }
        }
    }
    
    // MARK: - Method
    
    private func addPushPreview() {
        pushStreamingManager.requestAccessForVideo()
        pushStreamingManager.requestAccessForAudio()
        
        // Start local camera preview
        pushStreamingManager.createStartCamera(isStartCamera: true)
        
        view.backgroundColor = UIColor.clear
        cameraButton.addTarget(self, action: #selector(didTappedCameraButton(_:)), for: .touchUpInside)
        beautyButton.addTarget(self, action: #selector(didTappedBeautyButton(_:)), for: .touchUpInside)
        stopLiveButton.addTarget(self, action: #selector(didTappedStopLiveButton(_:)), for: .touchUpInside)
        recordButton.addTarget(self, action: #selector(didTappedRecordButton(_:)), for: .touchUpInside)
    }
    
    private func startSpeechRecognization() { // baochuqu
        sttManager.startRecognization(view: view) { response in
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
        let chatMessageVC = UIStoryboard.chat.instantiateViewController(withIdentifier: String(describing: ChatViewController.self) //
        )
        guard let chatVC = chatMessageVC as? ChatViewController else { return }
        chatVC.isFromStreamer = true
        chatVC.channelName = UserManager.shared.userID
        view.addSubview(chatVC.view)
        self.addChild(chatVC)
    }
    
    func onPushStatusUpdate(_ status: V2TXLivePushStatus, message msg: String!, extraInfo: [AnyHashable: Any]!) {
        if status == V2TXLivePushStatus.connectSuccess {
            changeButtonTintColor(stateButton, true, UIImage.asset(.onAir) ?? UIImage())
        } else {
            changeButtonTintColor(stateButton, false, UIImage.asset(.onAir) ?? UIImage())
        }
    }
    
    private func cancelSpeechRecognization() {
        sttManager.cancelRecognization()
    }
    
    private func stopStreaming() {
        pushStreamingManager.stopStreaming {
            self.deletePushStreaming()
            self.cancelSpeechRecognization()
        }
    }
    
    func createRecordDoneAlert(message: String) {
        let controller = UIAlertController.init(title: "提示", message: message, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
            controller.dismiss(animated: true, completion: nil)
        }))
        self.present(controller, animated: true, completion: nil)
    }
    
    private func deletePushStreaming() {
        pushStreamingProvider.deletePushStreamingInfo(streamerId: UserManager.shared.userID) { _ in
            print("delete success") //
        }
    }
    
    private func startLive(_ url: String) { //
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, options: .defaultToSpeaker)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            
            pushStreamingManager.startPush(url: url)
            startSpeechRecognization()
        } catch {
            view.makeToast("開始直播發生錯誤", duration: 1.0, position: .center)
        }
    }
    
    private func createPushStreamingRuleAlert() {
        let ruleAlertController = UIAlertController(title: "警告", message: TextManager.pushRuleMessage.text, preferredStyle: .alert)
        
        ruleAlertController.addAction(UIAlertAction(title: "我會遵守直播規則", style: .default, handler: nil))
        
        ruleAlertController.view.tintColor = UIColor.black
        ruleAlertController.setMessageAlignment(.left)
        self.present(ruleAlertController, animated: true)
    }
}

extension PushViewController: CLLocationManagerDelegate, RPPreviewViewControllerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        location = locValue
    }
    
    func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
        previewController.dismiss(animated: true, completion: nil)
    }
}
