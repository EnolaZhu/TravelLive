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
    var detailPageImage = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        detailTableView.rowHeight = UITableView.automaticDimension
        detailTableView.estimatedRowHeight = 200.0
        detailTableView.delegate = self
        detailTableView.dataSource = self
        setUpTableView()
        detailTableView.separatorStyle = .none
    }
    
    func setUpTableView() {
        
        self.view.addSubview(detailTableView)
        detailTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([detailTableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0), detailTableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0), detailTableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0), detailTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)])
        
        detailTableView.registerCellWithNib(identifier: String(describing: DetailViewImageCell.self), bundle: nil)
        detailTableView.registerCellWithNib(identifier: String(describing: DetailViewCommentCell.self), bundle: nil)
    }
}

extension DetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: DetailViewImageCell.self), for: indexPath)
            guard let imageCell = cell as? DetailViewImageCell else { return cell }
            imageCell.layoutCell(mainImage: detailPageImage)
            return imageCell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: DetailViewCommentCell.self), for: indexPath)
            guard let commentCell = cell as? DetailViewCommentCell else { return cell }
            commentCell.layoutCell(name: "Mike", comment: "So Beauty~")
            return commentCell
        }
    }
}
