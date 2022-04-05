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
                image: UIImage.asset(.Icons_map_normal),
                selectedImage: UIImage.asset(.Icons_map_focus)
            )

        case .search:
            return UITabBarItem(
                title: nil,
                image: UIImage.asset(.Icons_search_normal),
                selectedImage: UIImage.asset(.Icons_search_focus)
            )

        case .publish:
            return UITabBarItem(
                title: nil,
                image: UIImage.asset(.Icons_live_normal),
                selectedImage: UIImage.asset(.Icons_live_focus)
            )

        case .shop:
            return UITabBarItem(
                title: nil,
                image: UIImage.asset(.Icons_shop_normal),
                selectedImage: UIImage.asset(.Icons_shop_focus)
            )
            
        case .profile:
            return UITabBarItem(title: nil, image: UIImage.asset(.Icons_profile_normal), selectedImage: UIImage.asset(.Icons_profile_focus))
        }
    }
}

class STTabBarViewController: UITabBarController, UITabBarControllerDelegate {

    private let tabs: [Tab] = [.map, .search, .publish, .shop, .profile]
    var trolleyTabBarItem: UITabBarItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewControllers = tabs.map({ $0.controller() })
        delegate = self
    }

    // MARK: - UITabBarControllerDelegate

//    func tabBarController(
//        _ tabBarController: UITabBarController,
//        shouldSelect viewController: UIViewController
//    ) -> Bool {
//
//        guard let navVC = viewController as? UINavigationController,
//              navVC.viewControllers.first is ProfileViewController
//        else { return true }
//
//        guard KeyChainManager.shared.token != nil else {
//
//            if let authVC = UIStoryboard.auth.instantiateInitialViewController() {
//
//                authVC.modalPresentationStyle = .overCurrentContext
//
//                present(authVC, animated: false, completion: nil)
//            }
//
//            return false
//        }
//
//        return true
//    }
}

