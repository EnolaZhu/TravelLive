//
//  PullStreamingViewController.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/11.
//

import UIKit
import IJKMediaFramework

class PullStreamingViewController: UIViewController {
    var player: IJKFFMoviePlayerController!
    private let loveButton = UIButton()
    var streamingUrl = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createPlayer()
        addChatView()
        createAnimationButton()
        loveButton.addTarget(self, action: #selector(click), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // 開始播放
        player.prepareToPlay()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // 關閉播放器
        player.shutdown()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // "http://cdn-live1.qvc.jp/iPhone/800/800.m3u8"
    func createPlayer() {
        streamingUrl = "http://cdn-live1.qvc.jp/iPhone/800/800.m3u8"
        let options = IJKFFOptions.byDefault()
        let url = NSURL(string: streamingUrl)
        let player = IJKFFMoviePlayerController(contentURL: url as URL?, with: options)
        // 播放頁面寬高自適應
        let autoresize = UIView.AutoresizingMask.flexibleWidth.rawValue | UIView.AutoresizingMask.flexibleHeight.rawValue
        player?.view.autoresizingMask = UIView.AutoresizingMask(rawValue: autoresize)
        player?.view.frame = self.view.bounds
        // 縮放模式
        player?.scalingMode = .aspectFit
        // 啟動後自動播放
        player?.shouldAutoplay = true
        
        view.autoresizesSubviews = true
        view.addSubview((player?.view)!)
        self.player = player
    }
    
    private func addChatView() {
        let chatMessageVC = UIStoryboard.chat.instantiateViewController(withIdentifier: String(describing: ChatViewController.self)
        )
        guard let chatVC = chatMessageVC as? ChatViewController else { return }
        view.addSubview(chatVC.view)
        self.addChild(chatVC)
    }
    
    func createAnimationButton() {
        view.addSubview(loveButton)
        loveButton.translatesAutoresizingMaskIntoConstraints = false
        loveButton.setImage(UIImage.asset(.cherry_blossom), for: UIControl.State())
        NSLayoutConstraint.activate([loveButton.widthAnchor.constraint(equalToConstant: 44), loveButton.heightAnchor.constraint(equalToConstant: 44), loveButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -120), loveButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20)])
    }
    
    @objc func click() {
        NotificationCenter.default.post(name: NSNotification.Name("heart"), object: nil)
    }
}
