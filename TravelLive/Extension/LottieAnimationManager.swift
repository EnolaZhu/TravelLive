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
    
    func createlottieAnimation(name: String, view: UIView, animationSpeed: CGFloat, isPulling: Bool) {
        let animationView = AnimationView(name: name)
        animationView.animationSpeed = animationSpeed
        if isPulling {
            animationView.frame = CGRect(x: -20, y: -20, width: UIScreen.width, height: UIScreen.height + 50)
            animationView.contentMode = .scaleAspectFill
        } else {
            animationView.frame = CGRect(x: 0, y: 0, width: 400, height: 400)
            animationView.contentMode = .scaleAspectFit
        }
        setAnimation(animationView: animationView, view: view)
    }
    
    func setAnimation(animationView: AnimationView, view: UIView) {
        animationView.center = view.center
        animationView.loopMode = .playOnce
        view.addSubview(animationView)
        animationView.play()
        animationView.play { isCompleted in
            if isCompleted {
                animationView.removeFromSuperview()
            }
        }
    }
    
    // Show lottie animation on button
    func showLoadingAnimation(view: UIView, name: String) {
        let animationView = AnimationView(name: name)
        showLoadingAnimation(animationView: animationView, view: view, name: name, width: 80, height: 80)
    }
    
    func showLoadingAnimation(animationView: AnimationView, view: UIView, name: String) {
        showLoadingAnimation(animationView: animationView, view: view, name: name, width: 200, height: 200)
    }
    
    func showLoadingAnimation(animationView: AnimationView, view: UIView, name: String, width: Int, height: Int) {
        animationView.isHidden = false
        animationView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        animationView.center = view.center
        animationView.contentMode = .scaleAspectFill
        animationView.loopMode = .loop
        animationView.play()
        view.addSubview(animationView)
    }
    
    func stopAnimation(animationView: AnimationView?) {
        animationView?.removeFromSuperview()
    }
}
