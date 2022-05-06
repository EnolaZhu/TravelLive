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
    var loadingAnimationView = AnimationView()
    
    func setUplottieAnimation(name: String, excitTime: Int, view: UIView, ifPulling: Bool) {
        let animationView = AnimationView(name: name)
        
        if ifPulling {
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
    
     // Show lottie animation on button
    func showLoadingAnimationOnButton(view: UIView, name: String) {
        let animationView = AnimationView(name: name)
        animationView.isHidden = false
        animationView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        animationView.center = view.center
        animationView.contentMode = .scaleAspectFill
        animationView.loopMode = .loop
        animationView.play()
        view.addSubview(animationView)
    }
    
    func showLoadingAnimation(animationView: AnimationView, view: UIView, name: String) {
        loadingAnimationView = animationView
        animationView.isHidden = false
        animationView.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        animationView.center = view.center
        animationView.contentMode = .scaleAspectFill
        animationView.loopMode = .loop
        animationView.play()
        view.addSubview(animationView)
    }
    
    func stopAnimation() {
        loadingAnimationView.removeFromSuperview()
    }
}
