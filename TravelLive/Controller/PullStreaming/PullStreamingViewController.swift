//
//  PullStreamingViewController.swift
//  TravelLive
//  https://cloud.tencent.com/document/product/454/56588
//  Created by Enola Zhu on 2022/4/11.
//

import UIKit
import TXLiteAVSDK_Professional

class PullStreamingViewController: UIViewController, V2TXLivePlayerObserver {
    private let loveButton = UIButton()
    var streamingUrl = String()
    private var livePlayer = V2TXLivePlayer()
    private var streamId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startPlay(streamingUrl)
        addChatView()
        createAnimationButton()
        loveButton.addTarget(self, action: #selector(click), for: .touchUpInside)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func startPlay(_ url: String) {
        livePlayer.setRenderView(view)
        livePlayer.startPlay(url)
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
        loveButton.setImage(UIImage.asset(.heart), for: UIControl.State())
        NSLayoutConstraint.activate(
            [loveButton.widthAnchor.constraint(equalToConstant: 44),
            loveButton.heightAnchor.constraint(equalToConstant: 44),
            loveButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -200),
            loveButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20)]
        )
    }
    
    @objc func click() {
        NotificationCenter.default.post(name: .animationNotificationKey, object: nil)
    }
}
