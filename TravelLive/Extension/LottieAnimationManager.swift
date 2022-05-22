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
    // swiftlint:disable function_parameter_count
    func createlottieAnimation(name: String, view: UIView, animationSpeed: CGFloat, isRemove: Bool, theX: Int, theY: Int, width: Int, height: Int) {
        createlottieAnimation(name: name, view: view, animationSpeed: animationSpeed, isRemove: isRemove, theX: theX, theY: theY, width: width, height: height, completion: nil)
    }
    
    func createlottieAnimation(name: String, view: UIView, animationSpeed: CGFloat, isRemove: Bool, theX: Int, theY: Int, width: Int, height: Int, completion: (() -> Void)?) {
        let animationView = AnimationView(name: name)
        animationView.animationSpeed = animationSpeed
//            animationView.contentMode = .scaleAspectFill
        animationView.frame = CGRect(x: theX, y: theY, width: width, height: height)
            animationView.contentMode = .scaleAspectFit
        setAnimation(animationView: animationView, view: view, isRemove: isRemove, completion: completion)
    }
    
    private func setAnimation(animationView: AnimationView, view: UIView, isRemove: Bool, completion: (() -> Void)?) {
//        animationView.center = view.center
        animationView.loopMode = .playOnce
        view.addSubview(animationView)
        animationView.play()
        animationView.play { isCompleted in
            if isCompleted {
                if isRemove {
                    completion?()
                } else {
                    animationView.removeFromSuperview()
                }
            }
        }
    }
    
    // Show lottie animation on button
    func showLoadingAnimation(view: UIView, name: String) {
        let animationView = AnimationView(name: name)
        showLoadingAnimation(animationView: animationView, view: view, name: name, width: 90, height: 90)
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
