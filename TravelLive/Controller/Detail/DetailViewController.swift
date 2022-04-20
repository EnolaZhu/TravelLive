//
//  DetailViewController.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/19.
//

import UIKit
import SwiftUI

class DetailViewController: BaseViewController {
    let detailTableView = UITableView()
    let reportMaskView = UIView()
    let commentVC = CommentViewController()
    var allCommentData: CommentObject?
    var detailPageImage = UIImage()
    var avatarImage = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        detailTableView.rowHeight = UITableView.automaticDimension
        detailTableView.estimatedRowHeight = 200.0
        detailTableView.delegate = self
        detailTableView.dataSource = self
        setUpTableView()
        setUpMaskView()
        detailTableView.separatorStyle = .none
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchComment(ownerId: "Enola_1650378092481000_0")
        tabBarController?.tabBar.isHidden = true
    }
    
    private func setUpTableView() {
        self.view.addSubview(detailTableView)
        detailTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([detailTableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0), detailTableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0), detailTableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0), detailTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)])
        
        detailTableView.registerCellWithNib(identifier: String(describing: DetailViewImageCell.self), bundle: nil)
        detailTableView.registerCellWithNib(identifier: String(describing: DetailViewCommentCell.self), bundle: nil)
    }
    
    private func fetchComment(ownerId: String) {
        DetailDataProvider.shared.fetchCommentData(query: ownerId) { [weak self] result in
            switch result {
            case .success(let data):
                print(data)
                self?.allCommentData = data
                guard let allCommentData = self?.allCommentData else { return }
                self?.detailTableView.reloadData()
                print("\(allCommentData)")
            case .failure(let error):
                print(error)
            }
        }
    }
}

extension DetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1 + (allCommentData?.data.count ?? 0)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: DetailViewImageCell.self), for: indexPath)
            guard let imageCell = cell as? DetailViewImageCell else { return cell }
            imageCell.reportButton.addTarget(self, action: #selector(showReportPage(_:)), for: .touchUpInside)
            imageCell.commentButton.addTarget(self, action: #selector(showCommentPage(_:)), for: .touchUpInside)
            imageCell.layoutCell(mainImage: detailPageImage)
            return imageCell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: DetailViewCommentCell.self), for: indexPath)
            guard let commentCell = cell as? DetailViewCommentCell else { return cell }
            
            if allCommentData == nil {
                return UITableViewCell()
            } else {
                ImageManager.shared.fetchStorageImage(imageUrl: allCommentData?.data[indexPath.row - 1].avatar ?? "") { [weak self] image in
                    self?.avatarImage = image
                }
                commentCell.layoutCell(name: allCommentData?.data[indexPath.row - 1].reviewerId ?? "", comment: allCommentData?.data[indexPath.row - 1].message ?? "", avatar: avatarImage)
            }
            return commentCell
        }
    }
    
    @objc func showReportPage(_ sender: UIButton) {
        let reportVC = ReportViewController()
        reportVC.clickCloseButton = self
        
        reportVC.view.frame = CGRect(x: 0, y: UIScreen.height, width: UIScreen.width, height: 202)
        
        view.addSubview(reportMaskView)
        // Animation
        UIView.animate(withDuration: 1, delay: 0.01, options: .curveEaseInOut, animations: { [self] in
            reportVC.view.frame = CGRect(x: 0, y: CGFloat(UIScreen.height - CGFloat(250.0)), width: UIScreen.width, height: 250.0)
        }, completion: { _ in print("report page show")})
        view.addSubview(reportVC.view)
        addChild(reportVC)
    }
    
    @objc func showCommentPage(_ sender: UIButton) {
        view.addSubview(reportMaskView)
        commentVC.clickCloseButton = self
        self.view.addSubview(commentVC.view)
        self.addChild(commentVC)
    }
    
    func setUpMaskView() {
        reportMaskView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
        reportMaskView.frame = CGRect(x: 0, y: 0, width: UIScreen.width, height: UIScreen.height)
    }
}

extension DetailViewController: CloseMaskView, CloseCommentView {
    func clickCloseButton() {
        reportMaskView.removeFromSuperview()
    }
    
    func pressCloseButton() {
        reportMaskView.removeFromSuperview()
    }
}
