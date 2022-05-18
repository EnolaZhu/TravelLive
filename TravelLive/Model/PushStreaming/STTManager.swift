//
//  STTManager.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/5/17.
//

import UIKit
import Speech

class STTManager {
    private let audioEngine = AVAudioEngine()
    private let speechRecognizer: SFSpeechRecognizer! = SFSpeechRecognizer(locale: Locale.init(identifier: "zh-Hant-TW"))
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask!
    
    func requestPermission(view: UIView, completion: @escaping () -> Void) {
        SFSpeechRecognizer.requestAuthorization { authState in
            OperationQueue.main.addOperation {
                if authState == .authorized {
                    completion()
                } else if authState == .denied {
                    view.makeToast("使用者拒絕開放權限", duration: 1.0, position: .center)
                } else if authState == .notDetermined {
                    view.makeToast("使用者手機裡沒有聲音辨識", duration: 1.0, position: .center)
                } else if authState == .restricted {
                    view.makeToast("使用者限制權限", duration: 1.0, position: .center)
                }
            }
        }
    }
    
    func startRecognization(view: UIView, completion: @escaping (SFSpeechRecognitionResult) -> Void) {
        audioEngine.inputNode.removeTap(onBus: 0)
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        request = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = request else { return }
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, _) in
            recognitionRequest.append(buffer)
        }
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch let error {
            view.makeToast("Error comes here for starting the audio listner =\(error.localizedDescription)", duration: 1.0, position: .center)
        }
        guard let myRecognization = SFSpeechRecognizer() else {
            view.makeToast("許可在本地端不被允許", duration: 1.0, position: .center)
            return
        }
        
        if !myRecognization.isAvailable {
            view.makeToast("請下次再試", duration: 1.0, position: .center)
        }
        task = speechRecognizer.recognitionTask(with: recognitionRequest, resultHandler: { (response, error) in
            guard let response = response else {
                if self.task == nil {
                    return
                }
                if error != nil {
                    view.makeToast("發生錯誤", duration: 1.0, position: .center)
                } else {
                    view.makeToast("請回報問題", duration: 1.0, position: .center)
                }
                return
            }
            completion(response)
        })
    }
    
    func cancelRecognization() {
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
}
