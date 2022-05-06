//
//  ViewController.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/4.
//

import UIKit
import Lottie

private enum Tab {
    case map
    case search
    case stream
    case place
    case profile
    
    func controller() -> UIViewController {
        var controller: UIViewController
        
        switch self {
        case .map: controller = UIStoryboard.map.instantiateInitialViewController()!
        case .place: controller = UIStoryboard.shop.instantiateInitialViewController()!
        case .stream: controller = UIStoryboard.pushStreaming.instantiateInitialViewController()!
        case .search: controller = UIStoryboard.search.instantiateInitialViewController()!
        case .profile: controller = UIStoryboard.profile.instantiateInitialViewController()!
        }

        controller.tabBarItem = tabBarItem()
        controller.tabBarItem.imageInsets = UIEdgeInsets(top: -4.0, left: 0.0, bottom: 4.0, right: 0.0)

        return controller
    }

    func tabBarItem() -> UITabBarItem {
        switch self {
        case .map:
            return UITabBarItem(
                title: "地圖",
                image: UIImage.asset(.Icons_map),
                selectedImage: UIImage.asset(.Icons_map)
            )
            
        case .place:
            return UITabBarItem(
                title: "景點",
                image: UIImage.asset(.Icons_attractions),
                selectedImage: UIImage.asset(.Icons_attractions)
            )

        case .stream:
            return UITabBarItem(title: nil, image: nil, selectedImage: nil)

        case .search:
            return UITabBarItem(
                title: "搜尋",
                image: UIImage.asset(.Icons_search),
                selectedImage: UIImage.asset(.Icons_search)
            )
        
        case .profile:
            return UITabBarItem(
                title: "個人",
                image: UIImage.asset(.Icons_profile),
                selectedImage: UIImage.asset(.Icons_profile))
        }
    }
}

class TabBarViewController: UITabBarController, UITabBarControllerDelegate {
    private let tabs: [Tab] = [.map, .place, .stream, .search, .profile]
    var trolleyTabBarItem: UITabBarItem!
    let animationView = AnimationView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        tabBar.tintColor = UIColor.primary
        tabBar.backgroundColor = UIColor.white
        viewControllers = tabs.map({ $0.controller() })
        delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        LottieAnimationManager.shared.showLoadingAnimationOnButton(view: tabBar.subviews[2], name: "Live")
    }
}
