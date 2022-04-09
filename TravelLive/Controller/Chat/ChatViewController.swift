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
    @IBOutlet weak var inputTextfield: UITextField!
    
    private var messages = [Message]() {
        didSet {
            chatView.reloadData()
        }
    }
    var noMoreMessages = false
    var earliestMessageTime: NSNumber = -1
    var loadingMore = false
    var client: PubNub!
    var channelName = "Channel Name"
    var username = "Enola"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupChatView()
        // Setting up our PubNub object
        let configuration = PNConfiguration(publishKey: Secret.pubNubPublishKey.rawValue, subscribeKey: Secret.pubNubSubscribeKey.rawValue)
        configuration.uuid = UUID().uuidString
        client = PubNub.clientWithConfiguration(configuration)
        client.addListener(self)
        client.subscribeToChannels([channelName], withPresence: true)
    }
    
    private func setupChatView() {
        chatView.registerCellWithNib(identifier: String(describing: MessageCell.self), bundle: nil)
    }
    
    private func loadLastMessages() {
        addHiistory(start: nil, end: nil, limit: 20)
        if !self.messages.isEmpty {
            self.chatView.scrollsToTop = true
        }
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
                    self.messages.insert(message, at: 0)
                }
                self.loadingMore = false
            } else if status !=  nil {
                print(status!.category)
            } else {
                print("everything is nil whaaat")
            }
        }
    }
    
    func client(_ client: PubNub, didReceiveMessage message: PNMessageResult) {
        if channelName == message.data.channel {
            guard let theMessage = message.data.message as? [String: String] else { return }
            self.messages.insert(Message(message: theMessage["message"]!, username: theMessage["username"]!, uuid: theMessage["uuid"]!), at: 0)
//            tableView.reloadData()
            self.chatView.scrollsToTop = true
        }
        print("Received message in Channel:", message.data.message!)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !loadingMore && !noMoreMessages {
            let indexWant = IndexPath(row: messages.count - 1, section: 0)
            let visible = chatView.indexPathsForVisibleRows
            if visible!.contains(indexWant) {
                loadingMore = true
                addHiistory(start: earliestMessageTime, end: nil, limit: 10)
            }
        }
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
