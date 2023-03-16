//
//  WebViewController.swift
//  PageViewDemo
//
//  Created by Takahiro Tanaka on 2023/03/04.
//  Copyright © 2023 Takahiro Tanaka. All rights reserved.
//

import UIKit
import SafariServices
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate, WKUIDelegate, SFSafariViewControllerDelegate {
    
    var webView: WKWebView = WKWebView()
    let webConfiguration: WKWebViewConfiguration = WKWebViewConfiguration()
    var progressView: UIProgressView!

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
    @IBOutlet weak var reloadBtn: UIButton!
    @IBOutlet weak var headerProgressView: UIView!
    
    // KVO(Key Value Observing)とはオブジェクトの値の変更の監視
    private var _observers = [NSKeyValueObservation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // ナビゲーションバーの背景色
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 187/255, green: 0/255, blue:27/255, alpha:1.0)
        // ナビゲーションバーのアイテムの色
        self.navigationController?.navigationBar.tintColor = .white
        
        setWebArrangement()
        loadWebView()
        // 読み込み状態インジケータ
        setUpPorgressView()
        
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
        
        // isLoading プロパティを監視して更新できる状態のみ再読み込み可能
        _observers.append(webView.observe(\.isLoading, options: .new) {_, change in
            if let value = change.newValue {
                DispatchQueue.main.async {
                    // isLoadingがtrueの時は無効化
                    self.reloadBtn.isEnabled = !value
                    self.reloadBtn.alpha     = !value ? 1.0 : 0.4
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
    
    // 再読み込みボタン
    @IBAction func tapReload(_ sender: Any) {
        webView.reload()
    }
    
    
    // WKWebViewのセットアップ（アプリ画面にWebViewを配置）
    func setWebArrangement() {
        // Webビューの生成
        webView = WKWebView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height), configuration: webConfiguration)
        webView.navigationDelegate = self   // Delegate1: 画面の読み込み・遷移系
        webView.uiDelegate = self           // Delegate2: jsとの連携系
        
        contentView.addSubview(webView)
        
        // 画面レイアウトの制約
        webView.topAnchor.constraint(equalToSystemSpacingBelow: contentView.topAnchor, multiplier: 0.0).isActive = true
        webView.bottomAnchor.constraint(equalToSystemSpacingBelow: contentView.bottomAnchor, multiplier: 0.0).isActive = true
        webView.leadingAnchor.constraint(equalToSystemSpacingAfter: contentView.leadingAnchor, multiplier: 0.0).isActive = true
        webView.trailingAnchor.constraint(equalToSystemSpacingAfter: contentView.trailingAnchor, multiplier: 0.0).isActive = true
        
    }
    
    // WebViewの読み込み（webページのロード）
    func loadWebView() {
        // URLのnil対策としてif文を使用
        if let url = NSURL(string: "https://www.yahoo.co.jp/") {
            let request = NSMutableURLRequest(url: url as URL)
            // load リクエストでURLを表示
            webView.load(request as URLRequest)
        }
    }
    
    // プログレスバー
    func setUpPorgressView() {
        self.progressView = UIProgressView(frame: CGRect(x: 0, y: headerProgressView.frame.maxY, width: self.view.frame.width, height: 3.0))
        self.progressView.progressViewStyle = .bar
        self.view.addSubview(self.progressView)
        _observers.append(self.webView.observe(\.estimatedProgress, options: .new, changeHandler: {(webView, change) in
            self.progressView.alpha = 1.0
            // estimateProgressが変更された時にプログレスバーの値を変更
            self.progressView.setProgress(Float(change.newValue!), animated: true)
            if self.webView.estimatedProgress >= 1.0 {
                UIView.animate(withDuration: 0.3,
                               delay: 0.3,
                               options: [.curveEaseOut],
                               animations: { [weak self] in
                                self?.progressView.alpha = 0.0
                                
                    }, completion: {_ in
                        self.progressView.setProgress(0.0, animated: false)
                })
            }
        }))
    }
    
    func sendLoginVC(index: Int) {
        let nc: UINavigationController = self.storyboard!.instantiateViewController(withIdentifier: Route.Scene.login.rootIdentifier()) as! UINavigationController
        let targetVC = nc.viewControllers[0] as! TabPageViewController
        targetVC.currentPageIndex = index
        self.present(nc, animated: true, completion: nil)
    }
    
    /** START_Delegate 画面の読み込み・遷移系 **/
    
    // MARK: - 読み込み設定（リクエスト前）
    // リンクタップしてページを読み込む前に呼ばれる
    // AppStoreのリンクだったらストアに飛ばす、Deeplinkだったらアプリに戻る のようなことができる
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        print("リクエスト前")
        /**WebView内の特定のリンクをタップした時の処理などがかける*/
        print("URL ==", navigationAction.request.url?.absoluteString ?? "")
        print("WebView の URL ==", self.webView.url ?? "")
        var isCancel = false
        
        guard let url = navigationAction.request.url else {
            return
        }
        
        if navigationAction.navigationType == .linkActivated {
            if (url.absoluteString.contains("://login.yahoo.co.jp")) {
                print("ログイン画面です")
                isCancel = true
                self.sendLoginVC(index: 0)
            } else if (url.absoluteString.contains("://m.yahoo.co.jp/notification")) {
                print("新規登録画面です")
                isCancel = true
                self.sendLoginVC(index: 1)
            } else if (url.absoluteString.contains("://news.yahoo.co.jp")) {
                isCancel = true
                // SFSafariVCで表示
                let vc = SFSafariViewController(url: url)
                vc.delegate = self
                present(vc, animated: true, completion: nil)
            }
        }
        
        if (isCancel) {
            decisionHandler(.cancel)
        } else {
             // これを設定しないとアプリがクラッシュする
            decisionHandler(.allow) // .allow: 読み込み許可、.cancel: 読み込みキャンセル
        }
                
    }
    
    // MARK: - 読み込み準備開始
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("読み込み準備開始")
        // 遷移先を保存する
        let url = self.webView.url?.absoluteString
        print("読み込み準備開始のURL ==", url ?? "")
    }
    
    // MARK: - 読み込み設定（レスポンス取得後）
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        print("レスポンス取得後")
        
        // これを設定しないとアプリがクラッシュする
        decisionHandler(.allow) // .allow: 読み込み許可、.cancel: 読み込みキャンセル
        // 注意：受け取るレスポンスはページを読み込みタイミングのみで、Webページでの操作後の値などは受け取れない
    }
    
    // MARK: - 読み込み開始
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("読み込み開始")
    }
    
    // MARK: - ユーザー認証（このメソッドを呼ばないと認証してくれない）
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        print("ユーザー認証")
        completionHandler(.useCredential, nil)
    }
    
    // MARK: - 読み込み完了
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("読み込み完了")
        // ここで外部ブラウザを表示してみる
        let url = self.webView.url
        print("読み込み完了のURL ==", url ?? "")
        
    }
    
    // MARK: - 読み込み失敗検知
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("読み込み失敗検知")
    }
    
    // MARK: - 読み込み失敗
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("読み込み失敗")
    }
    
    // MARK: - リダイレクト
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        print("リダイレクト")
    }
    
    /** END_Delegate 画面の読み込み・遷移系 **/
    
    
    /* MARK: - START_SFSafariViewControllerDelegate **/
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        print("Safariとじる")
        dismiss(animated: true)
//        webView.goBack()
    }

}
