//
//  ChatViewController.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/8.
//

import UIKit
import PubNub
import Lottie

class ChatViewController: BaseViewController, PNEventsListener, UIGestureRecognizerDelegate {
    private struct Message {
        var message: String
        var username: String
        var uuid: String
    }
    
    // MARK: - Property
    @IBOutlet weak var chatView: UITableView! {
        didSet {
            chatView.delegate = self
            chatView.dataSource = self
            chatView.estimatedRowHeight = 30
            chatView.rowHeight = UITableView.automaticDimension
            chatView.backgroundColor = UIColor.clear
        }
    }
    @IBOutlet weak var caption: UILabel!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var inputTextfield: UITextField!
    
    private var messages = [Message]() {
        didSet {
            chatView.reloadData()
            scroolRowToNewestRow(chatView)
        }
    }
    
    private let intervalSendPubnub = 500
    private let sendPubnubThreshold = 2000
    
    var noMoreMessages = false
    var earliestMessageTime: NSNumber = -1
    var loadingMore = false
    var client: PubNub!
    var channelName = String()
    var textsOfSTT = [String]()
    var sendPubNubTimer = Timer()
    private var totalTime = 0
    var isFromStreamer = false
    var userDisplayName = String()
    
    // MARK: - Lifecycle]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getUserInfo(id: UserManager.shared.userID)
        setupChatView()
        // setting up our PubNub object
        let configuration = PNConfiguration(publishKey: Secret.pubNubPublishKey.title, subscribeKey: Secret.pubNubSubscribeKey.title)
        configuration.uuid = UUID().uuidString
        client = PubNub.clientWithConfiguration(configuration)
        client.addListener(self)
        client.subscribeToChannels([channelName], withPresence: true)
        
        // add observer for animation
        NotificationCenter.default.addObserver(self, selector: #selector(self.showAnimation(_:)), name: .animationNotificationKey, object: nil)
        // add observer for STT text
        NotificationCenter.default.addObserver(self, selector: #selector(self.getStreamerText(_:)), name: .textNotificationKey, object: nil)
        // add streamer close live observer
        NotificationCenter.default.addObserver(self, selector: #selector(self.closePullingView(_:)), name: .closePullingViewKey, object: nil)
        
        if isFromStreamer {
            initTimer()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // clear caption
        caption.text = ""
    }
    
    // MARK: - Notification methods
    
    @objc func getStreamerText(_ notification: NSNotification) {
        if let text = notification.userInfo?["streamer"] as? String {
            caption.text = (caption.text ?? "") + text
        }
    }
    
    @objc func showAnimation(_ notification: NSNotification) {
        publishAnimation()
    }
    
    @objc func closePullingView(_ notification: NSNotification) {
        
        self.client.publish(["message": "close",
                             "username": "close",
                             "uuid": self.client.uuid()
                            ], toChannel: channelName) { _ in }
    }
    
    private func createCloseAlert() {
        let closeAlertController = UIAlertController(
            title: "主播已下播",
            message: "去別的地方看看吧！",
            preferredStyle: .alert)
        let okAction = UIAlertAction(title: "好~", style: .default, handler: { (_: UIAlertAction!) -> Void in
            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
            self.navigationController?.popToRootViewController(animated: true)
        })
        closeAlertController.addAction(okAction)
        self.present(closeAlertController, animated: true, completion: nil)
    }
    
    // MARK: - Component
    private func setupChatView() {
        chatView.registerCellWithNib(identifier: "\(MessageCell.self)", bundle: nil)
        sendButton.tintColor = UIColor.primary
        sendButton.setImage(UIImage.asset(.send)?.maskWithColor(color: UIColor.primary), for: .normal)
        caption.backgroundColor = UIColor.primary
        caption.roundCorners(cornerRadius: 6)
    }
    
    // MARK: - Target / IBAction
    @IBAction func sendMessage(_ sender: UIButton) {
        if inputTextfield.text == "" {
            return
        } else {
            publishMessage()
        }
    }
    
    private func publishMessage() {
        if inputTextfield.text != "" || inputTextfield.text != nil {
            let messageString: String = inputTextfield.text!
            let messageObject: [String: Any] =
            [ "message": messageString,
              "username": userDisplayName,
              "uuid": client.uuid()
            ]
            
            client.publish(messageObject, toChannel: channelName) { _ in }
            inputTextfield.text = ""
        }
    }
    
    // MARK: - Method
    private func publishAnimation() {
        client.publish(["message": "heart",
                        "username": "animation",
                        "uuid": client.uuid()
                       ], toChannel: channelName) { _ in}
    }
    
    private func getUserInfo(id: String) {
        ProfileProvider.shared.fetchUserData(userId: id) { [weak self] result in
            switch result {
            case .success(let data):
                self?.userDisplayName = data.name
            case .failure:
                self?.view.makeToast("失敗，請稍後再試", duration: 0.5, position: .center)
            }
        }
    }

    func client(_ client: PubNub, didReceiveMessage message: PNMessageResult) {
        if channelName == message.data.channel {
            guard let theMessage = message.data.message as? [String: String] else { return }
            
            if theMessage["username"] == "animation" {
                LottieAnimationManager.shared.createlottieAnimation(name: LottieAnimation.fallHeart.title, view: self.view, location: CGRect(x: -20, y: -20, width: Int(UIScreen.width), height: Int(UIScreen.height) + 50))
                
            } else if theMessage["username"] == "STT" {
                if !isFromStreamer {
                    caption.text = theMessage["message"] ?? ""
                }
            } else if theMessage["username"] == "close" {
                createCloseAlert()
            } else {
                messages.append(Message(message: theMessage["message"]!, username: theMessage["username"]!, uuid: theMessage["uuid"]!))
            }
        }
    }
    
    private func scroolRowToNewestRow(_ tableView: UITableView) {
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
    private func initTimer() {
        sendPubNubTimer = Timer.scheduledTimer(timeInterval: Double(intervalSendPubnub) / 1000, target: self, selector: #selector(requestSendPubNub), userInfo: nil, repeats: true)
    }
    
    @objc private func requestSendPubNub() {
        totalTime += intervalSendPubnub
        if totalTime > sendPubnubThreshold {
            if caption.text?.isEmpty == true {
                totalTime = 0
            } else {
                sendPubNub(message: caption.text ?? "")
                caption.text = ""
            }
        }
    }
    
    private func sendPubNub(message: String) {
        if !message.isEmpty {
            self.client.publish(["message": message,
                                 "username": "STT",
                                 "uuid": self.client.uuid()
                                ], toChannel: channelName) { _ in }
            totalTime = 0
        }
    }
}

extension ChatViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(MessageCell.self)", for: indexPath)
        guard let messageCell = cell as? MessageCell else { return cell }
        messageCell.userNameLabel.text = messages[indexPath.row].username
        messageCell.messageLabel.text = messages[indexPath.row].message
        
        messageCell.isUserInteractionEnabled = true
        let longPressGesture: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress(sender:)))
        longPressGesture.delegate = self
        messageCell.addGestureRecognizer(longPressGesture)

        return messageCell
    }
    
    @objc private func handleLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let touchPoint = sender.location(in: chatView)
            if let indexPath = chatView.indexPathForRow(at: touchPoint) {
                createBlockReviewerAlert(index: indexPath.row)
            }
        }
    }
    
    private func createBlockReviewerAlert(index: Int) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "檢舉此則訊息的主人", style: .destructive, handler: { _ in
            self.view.makeToast("已檢舉", duration: 1, position: .center)
        }))
        alertController.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        
        alertController.view.tintColor = UIColor.black
        
        // iPad specific code
        IpadAlertManager.ipadAlertManager.makeAlertSuitIpad(alertController, view: self.view)
        
        self.present(alertController, animated: true)
    }
}
