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
    var channelName = String()
    private var livePlayer = V2TXLivePlayer()
    private var streamId: String?
    private var shareButton = UIButton()
    
    private let ruleMessage = """
進入聊天室，請遵守以下規則：
⦿ 不得發送違法訊息
⦿ 不得侵犯智慧財產權
⦿ 不得發送情色、賭、毒訊息
⦿ 不得進行歧視、霸凌、語言暴力
"""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startPlay(streamingUrl)
        addChatView()
        createAnimationButton()
        createShareButton()
        loveButton.addTarget(self, action: #selector(click), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(shareLink(_:)), for: .touchUpInside)
        
        self.navigationController?.navigationBar.tintColor = UIColor.primary
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tabBarController?.tabBar.isHidden = true
        createPullStreamingRuleAlert()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        tabBarController?.tabBar.isHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func createPullStreamingRuleAlert() {
        let ruleAlertController = UIAlertController(title: "警告", message: ruleMessage, preferredStyle: .alert)
        
        ruleAlertController.addAction(UIAlertAction(title: "我會遵守聊天室規則", style: .default, handler: { _ in
        }))
        
        ruleAlertController.view.tintColor = UIColor.black
        ruleAlertController.setMessageAlignment(.left)
        self.present(ruleAlertController, animated: true)
    }
    
    func startPlay(_ url: String) {
        livePlayer.setRenderView(view)
        livePlayer.startPlay(url)
    }
    
    private func addChatView() {
        let chatMessageVC = UIStoryboard.chat.instantiateViewController(withIdentifier: String(describing: ChatViewController.self)
        )
        guard let chatVC = chatMessageVC as? ChatViewController else { return }
        chatVC.channelName = channelName
        view.addSubview(chatVC.view)
        self.addChild(chatVC)
    }
    
    private func createAnimationButton() {
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
    
    private func createShareButton() {
        view.addSubview(shareButton)
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            [shareButton.widthAnchor.constraint(equalToConstant: 44),
             shareButton.heightAnchor.constraint(equalToConstant: 44),
             shareButton.bottomAnchor.constraint(equalTo: loveButton.topAnchor, constant: -20),
             shareButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20)]
        )
        setUpButtonBasicColor(shareButton, UIImage.asset(.secondShare) ?? UIImage(), color: UIColor.primary)
    }
    
    @objc private func shareLink(_ sender: UIButton) {
        let url = "https://travellive.page.link/?link=https://travellive-1d79e.web.app/WebRTCPlayer.html?live=" + (streamId ?? "")
        ShareManager.share.shareLink(textToShare: "快來看這個直播", shareUrl: url, thevVC: self, sender: sender)
    }
    
    @objc func click() {
        NotificationCenter.default.post(name: .animationNotificationKey, object: nil)
    }
}
