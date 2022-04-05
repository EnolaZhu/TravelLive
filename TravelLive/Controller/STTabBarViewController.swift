//
//  ViewController.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/4.
//

import UIKit

private enum Tab {
    case map
    case search
    case publish
    case shop
    case profile
    
    func controller() -> UIViewController {
        var controller: UIViewController
        
        switch self {
        case .map: controller = UIStoryboard.map.instantiateInitialViewController()!
        case .search: controller = UIStoryboard.search.instantiateInitialViewController()!
        case .publish: controller = UIStoryboard.pushStreaming.instantiateInitialViewController()!
        case .shop: controller = UIStoryboard.shop.instantiateInitialViewController()!
        case .profile: controller = UIStoryboard.profile.instantiateInitialViewController()!
        }

        controller.tabBarItem = tabBarItem()
        controller.tabBarItem.imageInsets = UIEdgeInsets(top: 6.0, left: 0.0, bottom: -6.0, right: 0.0)

        return controller
    }

    func tabBarItem() -> UITabBarItem {
        switch self {
        case .map:
            return UITabBarItem(
                title: nil,
                image: UIImage.asset(.Icons_map),
                selectedImage: UIImage.asset(.Icons_map)
            )

        case .search:
            return UITabBarItem(
                title: nil,
                image: UIImage.asset(.Icons_search),
                selectedImage: UIImage.asset(.Icons_search)
            )

        case .publish:
            return UITabBarItem(
                title: nil,
                image: UIImage.asset(.Icons_live),
                selectedImage: UIImage.asset(.Icons_live)
            )

        case .shop:
            return UITabBarItem(
                title: nil,
                image: UIImage.asset(.Icons_shop),
                selectedImage: UIImage.asset(.Icons_shop)
            )
            
        case .profile:
            return UITabBarItem(
                title: nil,
                image: UIImage.asset(.Icons_profile),
                selectedImage: UIImage.asset(.Icons_profile))
        }
    }
}

class STTabBarViewController: UITabBarController, UITabBarControllerDelegate {
    private let tabs: [Tab] = [.map, .search, .publish, .shop, .profile]
    var trolleyTabBarItem: UITabBarItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.tintColor = UIColor.primary
        tabBar.backgroundColor = UIColor.lightGray
        viewControllers = tabs.map({ $0.controller() })
        delegate = self
    }
}
