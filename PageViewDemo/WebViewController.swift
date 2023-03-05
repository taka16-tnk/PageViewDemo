//
//  WebViewController.swift
//  PageViewDemo
//
//  Created by Takahiro Tanaka on 2023/03/04.
//  Copyright © 2023 Takahiro Tanaka. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {
    
    var webView: WKWebView = WKWebView()
    let webConfiguration: WKWebViewConfiguration = WKWebViewConfiguration()

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var goBackBtn: UIButton! {
        didSet {
            goBackBtn.isEnabled = false
            goBackBtn.alpha     = 0.4
        }
    }
    @IBOutlet weak var goForwardBtn: UIButton! {
        didSet {
            goForwardBtn.isEnabled = false
            goForwardBtn.alpha     = 0.4
        }
    }
    
    // KVO(Key Value Observing)とはオブジェクトの値の変更の監視
    private var _observers = [NSKeyValueObservation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setWebArrangement()
        loadWebView()
        
        // 戻る・進むボタンを有効化できる状態になるまで無効化にしておく
        _observers.append(webView.observe(\.canGoBack, options: .new){ _, change in
            if let value = change.newValue {
                 DispatchQueue.main.async {
                    self.goBackBtn.isEnabled = value
                    self.goBackBtn.alpha     = value ? 1.0 : 0.4
                }
            }
        })
        _observers.append(webView.observe(\.canGoForward, options: .new){ _, change in
            if let value = change.newValue {
                DispatchQueue.main.async {
                    self.goForwardBtn.isEnabled = value
                    self.goForwardBtn.alpha     = value ? 1.0 : 0.4
                }
            }
        })
        
    }
    // 戻るボタン タップ
    @IBAction func tapGoBack(_ sender: Any) {
        webView.goBack()
    }
    
    // 進むボタン タップ
    @IBAction func tapGoForward(_ sender: Any) {
        webView.goForward()
    }
    
    // アプリ画面にWebViewを配置
    func setWebArrangement() {
        // Webビューの生成
        webView = WKWebView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height), configuration: webConfiguration)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        
        contentView.addSubview(webView)
        
        // 画面レイアウトの制約
        webView.topAnchor.constraint(equalToSystemSpacingBelow: contentView.topAnchor, multiplier: 0.0).isActive = true
        webView.bottomAnchor.constraint(equalToSystemSpacingBelow: contentView.bottomAnchor, multiplier: 0.0).isActive = true
        webView.leadingAnchor.constraint(equalToSystemSpacingAfter: contentView.leadingAnchor, multiplier: 0.0).isActive = true
        webView.trailingAnchor.constraint(equalToSystemSpacingAfter: contentView.trailingAnchor, multiplier: 0.0).isActive = true
        
    }
    
    // WebViewの読み込み
    func loadWebView() {
        // URLのnil対策としてif文を使用
        if let url = NSURL(string: "https://www.yahoo.co.jp/") {
            let request = NSURLRequest(url: url as URL)
            // load リクエストでURLを表示
            webView.load(request as URLRequest)
        }
    }
    
//    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//        DispatchQueue.main.async {
//            self.goBackBtn.isEnabled = webView.canGoBack
//            self.goBackBtn.alpha     = webView.canGoBack ? 1.0 : 0.4
//            self.goForwardBtn.isEnabled = webView.canGoForward
//            self.goForwardBtn.alpha = webView.canGoForward ? 1.0 :4.0
//        }
//    }
    

}
