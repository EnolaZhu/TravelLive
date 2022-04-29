//
//  LottieAnimationManager.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/29.
//

import UIKit
import Lottie

class LottieAnimationManager {
    static let shared = LottieAnimationManager()
    
    func setUplottieAnimation(name: String, excitTime: Int, view: UIView, ifPulling: Bool) {
        let animationView = AnimationView(name: name)
        
        if ifPulling{
            animationView.frame = CGRect(x: -20, y: -20, width: UIScreen.width, height: UIScreen.height + 50)
            animationView.contentMode = .scaleAspectFill
        } else {
            animationView.frame = CGRect(x: 0, y: 0, width: 400, height: 400)
            animationView.contentMode = .scaleAspectFit
        }
        animationView.center = view.center
        
        animationView.loopMode = .playOnce
        animationView.animationSpeed = 4
        view.addSubview(animationView)
        animationView.play()
        animationView.play { isCompleted in
            if isCompleted {
                animationView.removeFromSuperview()
            }
        }
    }
}
