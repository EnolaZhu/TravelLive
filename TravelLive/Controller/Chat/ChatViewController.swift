//
//  ChatViewController.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/8.
//

import UIKit

class ChatViewController: UIViewController, UITableViewDelegate {
    @IBOutlet weak var chatView: UITableView! {
        didSet {
            chatView.delegate = self
            chatView.dataSource = self
            chatView.backgroundColor = UIColor.clear
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupChatView()
    }
    
    private func setupChatView() {
        chatView.registerCellWithNib(identifier: String(describing: MessageCell.self), bundle: nil)
    }
}
extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MessageCell.self), for: indexPath)
        guard let messageCell = cell as? MessageCell else { return cell }
        messageCell.usernameLabel.text = "Enola"
        messageCell.messageLabel.text = "hello world!"
        return messageCell
    }
    
    
}
