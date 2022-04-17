//
//  ChatViewController.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/8.
//

import UIKit
import PubNub

class ChatViewController: BaseViewController, PNEventsListener {
    private struct Message {
        var message: String
        var username: String
        var uuid: String
    }
    
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
    @IBOutlet weak var inputTextfield: UITextField!
    
    private var messages = [Message]() {
        didSet {
            chatView.reloadData()
            scroolRowToNewestRow(chatView)
        }
    }
    var noMoreMessages = false
    var earliestMessageTime: NSNumber = -1
    var loadingMore = false
    var client: PubNub!
    var channelName = "Channel Name"
    var username = "Enola"
    var clickNumber = 0
    var textsOfSTT = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupChatView()
        // Setting up our PubNub object
        let configuration = PNConfiguration(publishKey: Secret.pubNubPublishKey.rawValue, subscribeKey: Secret.pubNubSubscribeKey.rawValue)
        configuration.uuid = UUID().uuidString
        client = PubNub.clientWithConfiguration(configuration)
        client.addListener(self)
        client.subscribeToChannels([channelName], withPresence: true)
        // Add observer for animation
        NotificationCenter.default.addObserver(self, selector: #selector(self.showAnimation(_:)), name: .animationNotificationKey, object: nil)
        // Add observer for STT text
        NotificationCenter.default.addObserver(self, selector: #selector(self.getStreamerText(_:)), name: .textNotificationKey, object: nil)
        // Clear caption
        caption.text = ""
    }
    
    @objc func getStreamerText(_ notification: NSNotification) {
        if let text = notification.userInfo?["streamer"] as? String {
            self.client.publish(["message": text,
                                 "username": "STT",
                                 "uuid": self.client.uuid()
                                ], toChannel: channelName) { status in
                print(status.data.information)
            }
            print(textsOfSTT)
        }
    }
    
    @objc func showAnimation(_ notification: NSNotification) {
        publishAnimation()
    }
    
    private func setupChatView() {
        chatView.registerCellWithNib(identifier: String(describing: MessageCell.self), bundle: nil)
    }
    
    @IBAction func sendMessage(_ sender: UIButton) {
        publishMessage()
    }
    
    func publishMessage() {
        if inputTextfield.text != "" || inputTextfield.text != nil {
            let messageString: String = inputTextfield.text!
            let messageObject: [String: Any] =
            [ "message": messageString,
              "username": username,
              "uuid": client.uuid()
            ]
            
            client.publish(messageObject, toChannel: channelName) { status in
                print(status.data.information)
            }
            inputTextfield.text = ""
        }
    }
    
    func publishAnimation() {
        clickNumber += 1
        client.publish(["message": "heart",
                        "username": "animation",
                        "uuid": client.uuid()
                       ], toChannel: channelName) { status in
            print(status.data.information)
        }
    }
    
    func createAnimation() {
        let animationImage = UIImageView(image: UIImage.asset(.heart))
        animationImage.frame = CGRect(x: UIScreen.width + 20, y: UIScreen.height + 20, width: 44, height: 44)
        
        if clickNumber % 2 == 0 {
            UIView.transition(with: self.view, duration: 1, options: .curveEaseOut) {
                animationImage.frame = CGRect(x: 0 - 30, y: 0 - 30, width: 44, height: 44)
                self.view.addSubview(animationImage)
                animationImage.alpha = 0.1
            } completion: {_ in
                animationImage.removeFromSuperview()
            }
        } else {
            animationImage.frame = CGRect(x: UIScreen.width + 20, y: UIScreen.height + 20, width: 44, height: 44)
            UIView.transition(with: self.view, duration: 1, options: .curveEaseInOut) {
                animationImage.frame = CGRect(x: UIScreen.width / 2, y: 0 - 30, width: 44, height: 44)
                self.view.addSubview(animationImage)
                animationImage.alpha = 0.2
            } completion: {_ in
                animationImage.removeFromSuperview()
            }
        }
    }
    
    func addHiistory(start: NSNumber?, end: NSNumber?, limit: UInt) {
        client.historyForChannel(channelName, start: start, end: end, limit: limit) { result, status in
            if result != nil && status == nil {
                if result!.data.start == 0 && result?.data.end == 0 {
                    self.noMoreMessages = true
                    return
                }
                self.earliestMessageTime = result!.data.start
                guard let messageDict = result!.data.messages as? [[String: String]] else { return }
                
                for theMessage in messageDict {
                    let message = Message(message: theMessage["message"]!, username: theMessage["username"]!, uuid: theMessage["uuid"]! )
                    self.messages.append(message)
                }
                self.loadingMore = false
            } else if status !=  nil {
                print(status!.category)
            } else {
                print("everything is nil whaat")
            }
        }
    }
    
    func client(_ client: PubNub, didReceiveMessage message: PNMessageResult) {
        if channelName == message.data.channel {
            guard let theMessage = message.data.message as? [String: String] else { return }
            if theMessage["username"] == "animation" {
                createAnimation()
            } else if theMessage["username"] == "STT" {
                caption.text = theMessage["message"]
            } else {
                messages.append(Message(message: theMessage["message"]!, username: theMessage["username"]!, uuid: theMessage["uuid"]!))
            }
        }
        print("Received message in Channel:", message.data.message!)
    }
    
    func scroolRowToNewestRow(_ tableView: UITableView) {
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
}

extension ChatViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MessageCell.self), for: indexPath)
        guard let messageCell = cell as? MessageCell else { return cell }
        messageCell.userNameLabel.text = messages[indexPath.row].username
        messageCell.messageLabel.text = messages[indexPath.row].message
        return messageCell
    }
}
