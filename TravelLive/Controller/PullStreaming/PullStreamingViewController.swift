//
//  PullStreamingViewController.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/11.
//

import UIKit
import IJKMediaFramework

class PullStreamingViewController: UIViewController {
    var player: IJKFFMoviePlayerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let options = IJKFFOptions.byDefault()
        let url = NSURL(string: "http://cdn-live1.qvc.jp/iPhone/800/800.m3u8")
        let player = IJKFFMoviePlayerController(contentURL: url as URL?, with: options)
               
               // 播放頁面寬高自適應
        let autoresize = UIView.AutoresizingMask.flexibleWidth.rawValue | UIView.AutoresizingMask.flexibleHeight.rawValue
        player?.view.autoresizingMask = UIView.AutoresizingMask(rawValue: autoresize)
               player?.view.frame = self.view.bounds
               
               // 縮放模式
               player?.scalingMode = .aspectFit
               // 啟動後自動播放
               player?.shouldAutoplay = true
               
               self.view.autoresizesSubviews = true
               self.view.addSubview((player?.view)!)
               self.player = player
    }
    override func viewWillAppear(_ animated: Bool) {
            // 開始播放
            self.player.prepareToPlay()
        }
    override func viewWillDisappear(_ animated: Bool) {
           // 關閉播放器
           self.player.shutdown()
       }
       
       override func didReceiveMemoryWarning() {
           super.didReceiveMemoryWarning()
       }
}
