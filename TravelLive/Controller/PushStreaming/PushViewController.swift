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
import AVFoundation
import Vision

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
    var request: SFSpeechAudioBufferRecognitionRequest?
    var task: SFSpeechRecognitionTask!
    var streamingUrl: PushStreamingObject?
    var click = true
    // swiftlint:disable force_cast
//    private var cameraView: CameraView { view as! CameraView }
    
    private let videoDataOutputQueue = DispatchQueue(label: "CameraFeedDataOutput", qos: .userInteractive)
    private var cameraFeedSession: AVCaptureSession?
    private var handPoseRequest = VNDetectHumanHandPoseRequest()
    
    private let drawOverlay = CAShapeLayer()
    private let drawPath = UIBezierPath()
    private var evidenceBuffer = [HandGestureProcessor.PointsPair]()
    private var lastDrawPoint: CGPoint?
    private var isFirstSegment = true
    private var lastObservationTimestamp = Date()
    
    private var gestureProcessor = HandGestureProcessor()
    
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
        
        drawOverlay.frame = view.layer.bounds
        drawOverlay.lineWidth = 5
        drawOverlay.backgroundColor = #colorLiteral(red: 0.9999018312, green: 1, blue: 0.9998798966, alpha: 0.5).cgColor
        drawOverlay.strokeColor = #colorLiteral(red: 0.6, green: 0.1, blue: 0.3, alpha: 1).cgColor
        drawOverlay.fillColor = #colorLiteral(red: 0.9999018312, green: 1, blue: 0.9998798966, alpha: 0).cgColor
        drawOverlay.lineCap = .round
        view.layer.addSublayer(drawOverlay)
        // This sample app detects one hand only.
        handPoseRequest.maximumHandCount = 1
        // Add state change handler to hand gesture processor.
        gestureProcessor.didChangeStateClosure = { [weak self] state in
            self?.handleGestureStateChange(state: state)
        }
        // Add double tap gesture recognizer for clearing the draw path.
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
        recognizer.numberOfTouchesRequired = 1
        recognizer.numberOfTapsRequired = 2
        view.addGestureRecognizer(recognizer)
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
        //        if task != nil {
        //            cancelSpeechRecognization()
        //        }
        deletePushStreming()
        tabBarController?.tabBar.isHidden = false
    }
    
    private func addPushPreview() {
        requestAccessForVideo()
        requestAccessForAudio()
        view.backgroundColor = UIColor.clear
        view.addSubview(containerViewML)
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
        audioEngine.stop()
        if audioEngine.inputNode.numberOfInputs > 0 {
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        request?.endAudio()
        request?.shouldReportPartialResults = false
        task.finish()
        task.cancel()
        task = nil
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
    
    // View
    // swiftlint:disable line_length
    var containerViewML: CameraView = {
        let containerViewML = CameraView(frame: CGRect(x: 0, y: 0, width: UIScreen.width, height: UIScreen.height))
        containerViewML.backgroundColor = UIColor.clear
        containerViewML.autoresizingMask = [UIView.AutoresizingMask.flexibleHeight, UIView.AutoresizingMask.flexibleHeight]
        return containerViewML
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
        //        requestPermission()
        //        startSpeechRecognization()
        postPushStreamingInfo()
        click = !click
        if click {
            startLiveButton.setTitle(ComponentText.startLive.text, for: UIControl.State())
        } else {
            startLiveButton.setTitle(ComponentText.closelive.text, for: UIControl.State())
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
        session.stopLive()
        deletePushStreming()
        //        NotificationCenter.default.post(name: .closePullingViewKey, object: nil)
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
        // change button image
        click = !click
        if click {
            recordButton.setImage(UIImage.asset(.play), for: .normal)
        } else {
            recordButton.setImage(UIImage.asset(.stop), for: .normal)
        }
        // start record
        let record = RPScreenRecorder.shared()
        guard record.isAvailable else {
            print("ReplayKit unavailable")
            return
        }
        if record.isRecording {
            RecordManager.record.stopRecording(button, record, self)
        } else {
            RecordManager.record.startRecording(button, record)
        }
    }
    
    @objc func postPushStreamingInfo() {
        pushStreamingProvider.postPushStreamingInfo(streamerId: streamerId, longitude: longitude, latitude: latitude) { [weak self] result in
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
        pushStreamingProvider.deletePushStreamingInfo(streamerId: streamerId) { [weak self] result in
            print("delete success")
        }
    }
    
    func startLive(_ url: String) {
        startLiveButton.isSelected = !startLiveButton.isSelected
        if startLiveButton.isSelected {
            startLiveButton.setTitle(ComponentText.startLive.text, for: UIControl.State())
            let stream = LFLiveStreamInfo()
            stream.url = url
            session.startLive(stream)
            audioEngine.inputNode.removeTap(onBus: 0)
            self.startSpeechRecognization()
        } else {
            startLiveButton.setTitle(ComponentText.closelive.text, for: UIControl.State())
            session.stopLive()
            deletePushStreming()
            cancelSpeechRecognization()
            NotificationCenter.default.post(name: .closePullingViewKey, object: nil)
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

extension PushViewController: CLLocationManagerDelegate, RPPreviewViewControllerDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        longitude = locValue.longitude
        latitude = locValue.latitude
    }
    
    func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
        previewController.dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        do {
            if cameraFeedSession == nil {
                containerViewML.previewLayer.videoGravity = .resizeAspectFill
                try setupAVSession()
                containerViewML.previewLayer.session = cameraFeedSession
            }
            cameraFeedSession?.startRunning()
        } catch {
            //            AppError.display(error, inViewController: self)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        cameraFeedSession?.stopRunning()
        super.viewWillDisappear(animated)
    }
    
    func setupAVSession() throws {
        // Select a front facing camera, make an input.
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
                        throw AppError.captureSessionSetup(reason: "Could not find a front facing camera.")
        }
        
        guard let deviceInput = try? AVCaptureDeviceInput(device: videoDevice) else {
                        throw AppError.captureSessionSetup(reason: "Could not create video device input.")
        }
        
        let session = AVCaptureSession()
        session.beginConfiguration()
        session.sessionPreset = AVCaptureSession.Preset.high
        
        // Add a video input.
        guard session.canAddInput(deviceInput) else {
                        throw AppError.captureSessionSetup(reason: "Could not add video device input to the session")
        }
        session.addInput(deviceInput)
        
        let dataOutput = AVCaptureVideoDataOutput()
        if session.canAddOutput(dataOutput) {
            session.addOutput(dataOutput)
            // Add a video data output.
            dataOutput.alwaysDiscardsLateVideoFrames = true
            dataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
            dataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        } else {
                        throw AppError.captureSessionSetup(reason: "Could not add video data output to the session")
        }
        session.commitConfiguration()
        cameraFeedSession = session
    }
    
    func processPoints(thumbTip: CGPoint?, indexTip: CGPoint?) {
        // Check that we have both points.
        guard let thumbPoint = thumbTip, let indexPoint = indexTip else {
            // If there were no observations for more than 2 seconds reset gesture processor.
            if Date().timeIntervalSince(lastObservationTimestamp) > 2 {
                gestureProcessor.reset()
            }
            containerViewML.showPoints([], color: .clear)
            return
        }
        
        // Convert points from AVFoundation coordinates to UIKit coordinates.
        let previewLayer = containerViewML.previewLayer
        let thumbPointConverted = previewLayer.layerPointConverted(fromCaptureDevicePoint: thumbPoint)
        let indexPointConverted = previewLayer.layerPointConverted(fromCaptureDevicePoint: indexPoint)
        
        // Process new points
        gestureProcessor.processPointsPair((thumbPointConverted, indexPointConverted))
    }
    
    private func handleGestureStateChange(state: HandGestureProcessor.State) {
        let pointsPair = gestureProcessor.lastProcessedPointsPair
        var tipsColor: UIColor
        switch state {
        case .possiblePinch, .possibleApart:
            // We are in one of the "possible": states, meaning there is not enough evidence yet to determine
            // if we want to draw or not. For now, collect points in the evidence buffer, so we can add them
            // to a drawing path when required.
            evidenceBuffer.append(pointsPair)
            tipsColor = .orange
        case .pinched:
            // We have enough evidence to draw. Draw the points collected in the evidence buffer, if any.
            for bufferedPoints in evidenceBuffer {
                updatePath(with: bufferedPoints, isLastPointsPair: false)
            }
            // Clear the evidence buffer.
            evidenceBuffer.removeAll()
            // Finally, draw the current point.
            updatePath(with: pointsPair, isLastPointsPair: false)
            tipsColor = .green
        case .apart, .unknown:
            // We have enough evidence to not draw. Discard any evidence buffer points.
            evidenceBuffer.removeAll()
            // And draw the last segment of our draw path.
            updatePath(with: pointsPair, isLastPointsPair: true)
            tipsColor = .red
        }
        containerViewML.showPoints([pointsPair.thumbTip, pointsPair.indexTip], color: tipsColor)
    }
    
    private func updatePath(with points: HandGestureProcessor.PointsPair, isLastPointsPair: Bool) {
        // Get the mid point between the tips.
        let (thumbTip, indexTip) = points
        let drawPoint = CGPoint.midPoint(p1: thumbTip, p2: indexTip)
        
        if isLastPointsPair {
            if let lastPoint = lastDrawPoint {
                // Add a straight line from the last midpoint to the end of the stroke.
                drawPath.addLine(to: lastPoint)
            }
            // We are done drawing, so reset the last draw point.
            lastDrawPoint = nil
        } else {
            if lastDrawPoint == nil {
                // This is the beginning of the stroke.
                drawPath.move(to: drawPoint)
                isFirstSegment = true
            } else {
                let lastPoint = lastDrawPoint!
                // Get the midpoint between the last draw point and the new point.
                let midPoint = CGPoint.midPoint(p1: lastPoint, p2: drawPoint)
                if isFirstSegment {
                    // If it's the first segment of the stroke, draw a line to the midpoint.
                    drawPath.addLine(to: midPoint)
                    isFirstSegment = false
                } else {
                    // Otherwise, draw a curve to a midpoint using the last draw point as a control point.
                    drawPath.addQuadCurve(to: midPoint, controlPoint: lastPoint)
                }
            }
            // Remember the last draw point for the next update pass.
            lastDrawPoint = drawPoint
        }
        // Update the path on the overlay layer.
        drawOverlay.path = drawPath.cgPath
    }
    
    @IBAction func handleGesture(_ gesture: UITapGestureRecognizer) {
        guard gesture.state == .ended else {
            return
        }
        evidenceBuffer.removeAll()
        drawPath.removeAllPoints()
        drawOverlay.path = drawPath.cgPath
    }
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        var thumbTip: CGPoint?
        var indexTip: CGPoint?
        
        defer {
            DispatchQueue.main.sync {
                self.processPoints(thumbTip: thumbTip, indexTip: indexTip)
            }
        }
        
        let handler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer, orientation: .up, options: [:])
        do {
            // Perform VNDetectHumanHandPoseRequest
            try handler.perform([handPoseRequest])
            // Continue only when a hand was detected in the frame.
            // Since we set the maximumHandCount property of the request to 1, there will be at most one observation.
            guard let observation = handPoseRequest.results?.first else {
                return
            }
            // Get points for thumb and index finger.
            let thumbPoints = try observation.recognizedPoints(.thumb)
            let indexFingerPoints = try observation.recognizedPoints(.indexFinger)
            // Look for tip points.
            guard let thumbTipPoint = thumbPoints[.thumbTip], let indexTipPoint = indexFingerPoints[.indexTip] else {
                return
            }
            // Ignore low confidence points.
            guard thumbTipPoint.confidence > 0.3 && indexTipPoint.confidence > 0.3 else {
                return
            }
            // Convert points from Vision coordinates to AVFoundation coordinates.
            thumbTip = CGPoint(x: thumbTipPoint.location.x, y: 1 - thumbTipPoint.location.y)
            indexTip = CGPoint(x: indexTipPoint.location.x, y: 1 - indexTipPoint.location.y)
        } catch {
            cameraFeedSession?.stopRunning()
                        let error = AppError.visionError(error: error)
                        DispatchQueue.main.async {
                            error.displayInViewController(self)
                        }
        }
    }
    
}
