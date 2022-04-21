//
//  CommentViewController.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/20.
//

import UIKit

protocol CloseCommentView: AnyObject {
    func clickCloseButton()
}

class CommentViewController: UIViewController {
    
    @IBOutlet weak var commentView: UIView!
    @IBOutlet weak var publishButton: UIButton!
    @IBOutlet weak var closeCommentPageButton: UIButton!
    @IBOutlet weak var commentTextFied: UITextField!
    var clickCloseButton: CloseCommentView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commentView.backgroundColor = UIColor.white
        closeCommentPageButton.addTarget(self, action: #selector(closeCommentPage(_:)), for: .touchUpInside)
        publishButton.addTarget(self, action: #selector(publishComment(_:)), for: .touchUpInside)
    }
    
    @objc func closeCommentPage(_ sender: UIButton) {
        clickCloseButton?.clickCloseButton()
        self.view.removeFromSuperview()
    }
    
    @objc func publishComment(_ sender: UIButton) {
        if commentTextFied.text == "" {
            publishButton.isEnabled = true
        } else {
            DetailDataProvider.shared.postComment(id: "Enola_1650378092481000_0", reviewerId: "Enola", message: commentTextFied.text ?? "")
            clickCloseButton?.clickCloseButton()
            self.view.removeFromSuperview()
        }
    }
}
