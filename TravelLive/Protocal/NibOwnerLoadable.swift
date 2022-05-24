//
//  NibOwnerLoadable.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/6.
//

import UIKit

protocol NibOwnerLoadable: AnyObject {
    static var nib: UINib { get }
}

// MARK: - Default implmentation
extension NibOwnerLoadable {
    static var nib: UINib {
        UINib(nibName: String(describing: self), bundle: Bundle(for: self))
    }
}

// MARK: - Supporting methods
extension NibOwnerLoadable where Self: UIView {
    func loadNibContent() {
        guard let views = Self.nib.instantiate(withOwner: self, options: nil) as? [UIView],
            let contentView = views.first else {
                fatalError("Fail to load \(self) nib content")
        }
        self.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            contentView.rightAnchor.constraint(equalTo: rightAnchor),
            contentView.leftAnchor.constraint(equalTo: leftAnchor),
            contentView.topAnchor.constraint(equalTo: topAnchor)
        ])
    }
}
