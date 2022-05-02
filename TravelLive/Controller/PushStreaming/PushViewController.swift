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
    var postStreamerInfoTimer = Timer()
    var recordingLimitTimer = Timer()
    private let secondDayMillis = 86400
    private let time = 1000 * 3 * 60
    let pushStreamingProvider = PushStreamingProvider()
    let locationManager = CLLocationManager()
    // STT
    let audioEngine = AVAudioEngine()
    let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "zh_Hans_CN"))
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
        session.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        
        session.preView = view
        addPushPreview()
        view.addSubview(closeButton)
        closeButton.addTarget(self, action: #selector(didTappedCloseButton(_:)), for: .touchUpInside)
        setUpStartButton()
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
        view.backgroundColor = UIColor.clear
        view.addSubview(containerView)
        cameraButton.addTarget(self, action: #selector(didTappedCameraButton(_:)), for: .touchUpInside)
        beautyButton.addTarget(self, action: #selector(didTappedBeautyButton(_:)), for: .touchUpInside)
        stopLiveButton.addTarget(self, action: #selector(didTappedStopLiveButton(_:)), for: .touchUpInside)
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
    
    func startSpeechRecognization() {
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        request = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = request else { fatalError("Unable to created a SFSpeechAudioBufferRecognitionRequest object") }
        node.installTap(onBus: 20, bufferSize: 1024, format: recordingFormat) { (buffer, _) in
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
        
        task = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (response, error) in
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
            changeButtonTintColor(stateButton, false, UIImage.asset(.onAir) ?? UIImage())
        case LFLiveState.pending:
            changeButtonTintColor(stateButton, false, UIImage.asset(.onAir) ?? UIImage())
        case LFLiveState.start:
            changeButtonTintColor(stateButton, true, UIImage.asset(.onAir) ?? UIImage())
        case LFLiveState.error:
            changeButtonTintColor(stateButton, false, UIImage.asset(.onAir) ?? UIImage())
        case LFLiveState.stop:
            changeButtonTintColor(stateButton, false, UIImage.asset(.onAir) ?? UIImage())
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
    var stateButton: UIButton = {
        let stateLabel = UIButton(frame: CGRect(x: 20, y: 40, width: 80, height: 40))
        stateLabel.roundCorners(cornerRadius: 8)
//        stateLabel.isEnabled = false
//        stateLabel.text = ComponentText.noConnect.text
        stateLabel.setImage(UIImage.asset(.onAir), for: .normal)
        return stateLabel
    }()
    // close
    var closeButton: UIButton = {
        let closeButton = UIButton(frame: CGRect(x: UIScreen.width - 60, y: 70, width: 32, height: 32))
        closeButton.setImage(UIImage.asset(.close)?.maskWithColor(color: UIColor.primary), for: UIControl.State())
        return closeButton
    }()
    // camera
    var cameraButton: UIButton = {
        let cameraButton = UIButton(frame: CGRect(x: UIScreen.width - 60, y: UIScreen.height - 430, width: 44, height: 44))
        cameraButton.setImage(UIImage.asset(.Icons_camera_preview)?.maskWithColor(color: .primary), for: UIControl.State())
        return cameraButton
    }()
    //  camera
    var beautyButton: UIButton = {
        let beautyButton = UIButton(frame: CGRect(x: UIScreen.width - 60, y: UIScreen.height - 380, width: 44, height: 44))
        beautyButton.setImage(UIImage.asset(.Icons_camera_beauty)?.maskWithColor(color: .primary), for: UIControl.State.selected)
        beautyButton.setImage(UIImage.asset(.Icons_camera_beauty_close)?.maskWithColor(color: .primary), for: UIControl.State())
        return beautyButton
    }()
    // record
    var recordButton: UIButton = {
        let recordButton = UIButton(frame: CGRect(x: UIScreen.width - 60, y: UIScreen.height - 530, width: 44, height: 44))
        recordButton.setImage(UIImage.asset(.play)?.maskWithColor(color: .primary), for: UIControl.State())
        return recordButton
    }()
    
    // 結束直播
    var stopLiveButton: UIButton = {
        let stopLiveButton = UIButton(frame: CGRect(x: UIScreen.width - 60, y: UIScreen.height - 280, width: 44, height: 44))
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
        startLiveButton.addTarget(self, action: #selector(startStreaming(_:)), for: .touchUpInside)
    }
    
    
    // MARK: - Events
    
    // start streming
    
    @objc func startStreaming(_ sender: UIButton) {
        // STT
//        requestPermission()
//        startSpeechRecognization()
        
        postPushStreamingInfo()
        startLiveButton.isHidden = true
        closeButton.isHidden = true
        addChatView()
        view.addSubview(cameraButton)
        view.addSubview(beautyButton)
        view.addSubview(recordButton)
        view.addSubview(stopLiveButton)
        view.addSubview(stateButton)
    }
    
    @objc func didTappedStopLiveButton(_ button: UIButton) {
        session.stopLive()
        deletePushStreming()
        cancelSpeechRecognization()
        NotificationCenter.default.post(name: .closePullingViewKey, object: nil)
        view.removeFromSuperview()
        tabBarController?.selectedIndex = 0
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
        session.stopLive()
        deletePushStreming()
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
                    LottieAnimationManager.shared.setUplottieAnimation(name: "Success", excitTime: 1, view: self.view, ifPulling: false)
                case .failure(_):
                    LottieAnimationManager.shared.setUplottieAnimation(name: "Fail", excitTime: 1, view: self.view, ifPulling: false)
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
                    
                    LottieAnimationManager.shared.setUplottieAnimation(name: "Success", excitTime: 1, view: self?.view ?? UIView(), ifPulling: false)
                case .failure(_):
                    LottieAnimationManager.shared.setUplottieAnimation(name: "Fail", excitTime: 1, view: self?.view ?? UIView(), ifPulling: false)
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
            let stream = LFLiveStreamInfo()
            stream.url = url
            session.startLive(stream)
            audioEngine.inputNode.removeTap(onBus: 0)
            self.startSpeechRecognization()
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
