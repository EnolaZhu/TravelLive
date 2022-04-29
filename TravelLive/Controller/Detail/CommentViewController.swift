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
    var propertyId = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentTextFied.placeholder = "評論"
        commentTextFied.backgroundColor = UIColor.lightGray
        commentView.roundCorners(cornerRadius: 20)
        commentView.backgroundColor = UIColor.white
        setUpButton()
    }
    
    func setUpButton() {
        closeCommentPageButton.setImage(UIImage.asset(.close), for: .normal)
        closeCommentPageButton.addTarget(self, action: #selector(closeCommentPage(_:)), for: .touchUpInside)
        publishButton.setImage(UIImage.asset(.add), for: .normal)
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
            DetailDataProvider.shared.postComment(id: propertyId, reviewerId: userID, message: commentTextFied.text ?? "")
            clickCloseButton?.clickCloseButton()
            self.view.removeFromSuperview()
        }
    }
}
