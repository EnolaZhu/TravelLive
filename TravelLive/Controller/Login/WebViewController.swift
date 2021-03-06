//
//  WebViewController.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/5/8.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    private var mWebView: WKWebView?
    var url = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadURL(urlString: url)
        navigationController?.navigationBar.tintColor = UIColor.primary
    }
    
    private func loadURL(urlString: String) {
        let url = URL(string: urlString)
        if let url = url {
            let request = URLRequest(url: url)
            
            // init and load request in webview
            mWebView = WKWebView(frame: self.view.frame)
            if let mWebView = mWebView {
                mWebView.navigationDelegate = self
                mWebView.load(request)
                self.view.addSubview(mWebView)
                self.view.sendSubviewToBack(mWebView)
            }
        }
    }
}


extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        view.makeToast("出現錯誤", duration: 1.0, position: .center)
    }
}
