//
//  TabPageViewController.swift
//  PageViewDemo
//
//  Created by Takahiro Tanaka on 2023/02/23.
//  Copyright © 2023 Takahiro Tanaka. All rights reserved.
//

import UIKit

// プロトコルとは、具体的な処理内容は書かず、クラスや構造体が実装するプロパティとメソッドを定義する機能です
protocol TabPageViewControllerMenuItemViewDelegate {
    var parent: TabPageViewController! { set get }
    func didSelect()    // メインアプリが設定ペインのメインビューを表示したことを設定ペインに通知する
    func didDeselect()  // ピン留めの一つが選択消去された時に呼ばれる?
}

class TabPageViewController: UIViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    struct PageInfo {
        var menuItemView: TabPageViewControllerMenuItemView
        var vc: UIViewController
    }
    
    // レイアウトパーツとの紐付け
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var menuBackground: UIView!
    @IBOutlet weak var contentView: UIView!
    // バーボタンアイテムの宣言
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var settingButton: UIButton!

    
    // pageView上で表示するViewControllerを管理する配列
    var pageInfoList: [PageInfo] = []
    var currentPageIndex = 0
    var tagIndex = 0
    var menuItemViewWidth: CGFloat?
    var menuBackgroundDesignView: UIView?
    
    private var pageViewController: UIPageViewController!

    // 画面の読み込みが完了した時に呼ばれるイベント（画面読み込み時のライフサイクル）
    override func viewDidLoad() {
        super.viewDidLoad()
            
//        UINavigationBar.appearance().backgroundColor = .red
//        UINavigationBar.appearance().tintColor = .white
        // ナビゲーションバーの背景色
        self.navigationController?.navigationBar.barTintColor = .red
        // ナビゲーションバーのアイテムの色
        self.navigationController?.navigationBar.tintColor = .white

        // ページ情報
        self.initPageInfo()
               
        if let designView = self.menuBackgroundDesignView {
            // addView 画面遷移ではなく、Viewを重ねるイメージ
            self.menuBackground.addSubview(designView)
        }
        
        // ページビューコントローラ準備
        self.setupPageViewController()
        
        // ページ準備
        self.setupPageList()
        
    }
    
    // 閉じるボタンが押された時の処理
    @IBAction func closeTouchUpInside(_ sender: Any) {
        print("閉じる押された")
        WebDataState.sharedInstance.isClose = true
        self.dismiss(animated: true, completion: nil)
    }

    // 設定ボタンが押された時の処理
    @IBAction func settingTouchUpInside(_ sender: Any) {
        print("設定ボタンが押されました")
    }

    
    // 画面が表示される時に呼ばれるイベント（画面表示時のライフサイクル:画面遷移が発生すると必ず呼ばれるイベント）
    // 表示される度に毎回実行したい処理を書く
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // 画面をレイアウトする必要があるとiOSが認識した時に呼ばれる
    // レイアウトに関する設定だけを書いておくようにする
    override func viewDidLayoutSubviews() {
        self.menuBackground.frame.size.width = self.view.frame.width / CGFloat(self.pageInfoList.count)
        if let designView = self.menuBackgroundDesignView {
            designView.center = self.menuBackground.center
        }
    }
    
    // 画面遷移が完全に完了した時に呼ばれるイベント
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.menuBackground.frame.origin.x = self.pageInfoList[self.currentPageIndex].menuItemView.frame.origin.x
    }
    
    // タブページの情報
    func initPageInfo() {
        pageInfoList = [
            {
                let view    = TextViewMenuItemView()
                let loginVC = LoginContentViewController()
                let body    = UILabel()
                view.title  = "ログイン"
                view.parent = self
                body.sizeToFit()
                body.autoresizingMask = [.flexibleTopMargin, .flexibleRightMargin, .flexibleBottomMargin, .flexibleLeftMargin]
                body.center = loginVC.view.center
                loginVC.view.addSubview(body)
                return TabPageViewController.PageInfo(menuItemView: view, vc: loginVC)
            }(),
            {
                let view       = TextViewMenuItemView()
                let registerVC = RegisterContentViewController()
                let body       = UILabel()
                view.title  = "新規登録"
                view.parent = self
                body.sizeToFit()
                body.autoresizingMask = [.flexibleTopMargin, .flexibleRightMargin, .flexibleBottomMargin, .flexibleLeftMargin]
                body.center = registerVC.view.center
                registerVC.view.addSubview(body)
                return TabPageViewController.PageInfo(menuItemView: view, vc: registerVC)
            }(),
        ]
    }

    // ページビューコントローラ諸々
    private func setupPageViewController() {
        // 生成
        self.pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        
        // 親にセット
        self.pageViewController.view.frame.size = self.contentView.frame.size
        self.addChild(self.pageViewController)
        self.contentView.addSubview(self.pageViewController.view)
        self.pageViewController.didMove(toParent: self)
        
        // デリゲート
        self.pageViewController.delegate   = self
        self.pageViewController.dataSource = self
        
        // ジェスチャー
        self.contentView.gestureRecognizers = self.pageViewController.gestureRecognizers
    }
    
    // ページ諸々
    func setupPageList() {
        // 未選択状態用のタブ下線viewを設定
        let unselectedView = UIView()
        unselectedView.backgroundColor = .lightGray
        unselectedView.center = menuView.center
        self.menuView.addSubview(unselectedView)
        // SwiftコードベースでのAutoLayout設定
        unselectedView.translatesAutoresizingMaskIntoConstraints = false
        unselectedView.bottomAnchor
            .constraint(equalTo: self.menuView.bottomAnchor)
            .isActive = true
        unselectedView.widthAnchor
            .constraint(equalTo: self.menuView.widthAnchor)
            .isActive = true
        unselectedView.heightAnchor
            .constraint(equalToConstant: 2)
            .isActive = true
        
        // 選択状態用の下線viewを設定
        let selectedView = UIView()
        selectedView.backgroundColor = .black
        selectedView.center = menuBackground.center
        self.menuBackground.addSubview(selectedView)
        self.menuView.bringSubviewToFront(menuBackground)
        selectedView.translatesAutoresizingMaskIntoConstraints = false
        selectedView.bottomAnchor
            .constraint(equalTo: self.menuView.bottomAnchor)
            .isActive = true
        selectedView.widthAnchor
            .constraint(equalTo: self.menuView.widthAnchor,
                        multiplier: 1.0 / CGFloat(self.pageInfoList.count))
            .isActive = true
        selectedView.heightAnchor
            .constraint(equalToConstant: 2)
            .isActive = true
        
        // メニュー作る
        var constraintsString = "|"
        var menuItemViewList: [String: UIView] = [:]
        for i in 0..<self.pageInfoList.count {
            let menuItemView = self.pageInfoList[i].menuItemView
            menuItemView.translatesAutoresizingMaskIntoConstraints = false
            self.menuView.addSubview(menuItemView)
            
            // 高さ制約
            self.menuView.addConstraints(NSLayoutConstraint.constraints(
                withVisualFormat : "V:|[view]|",
                options          : [],
                metrics          : nil,
                views            : ["view": menuItemView]
            ))
            
            // 幅制約
            menuItemViewList["view\(i)"] = menuItemView
            constraintsString += "[view\(i)]"
            self.menuView.addConstraint(NSLayoutConstraint(
                item       : menuItemView,
                attribute  : .width,
                relatedBy  : .equal,
                toItem     : self.menuView,
                attribute  : .width,
                multiplier : 1.0 / CGFloat(self.pageInfoList.count),
                constant   : 0
            ))
            
            // タグのセット
            self.pageInfoList[i].vc.view.tag = i + 1
            self.pageInfoList[i].menuItemView.tag = i + 1
        }
        
        // 中身があれば
        if self.pageInfoList.count > 0 {
            
            // 幅制約続き
            constraintsString += "|"
            self.menuView.addConstraints(NSLayoutConstraint.constraints(
                withVisualFormat : constraintsString,
                options          : [],
                metrics          : nil,
                views            : menuItemViewList
            ))
            
            // 最初のページをセット
            self.pageViewController.setViewControllers(
                [self.pageInfoList[self.currentPageIndex].vc],
                direction: .forward,
                animated: false,
                completion: nil)
            self.pageInfoList[self.currentPageIndex].menuItemView.didSelect()
        }
    }
    
    // 左隣のページ取得
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = viewController.view.tag - 1
        
        index -= 1
        if index < 0 {
            // スクロール固定のためnilを返す
            return nil
        }
        return self.pageInfoList[index].vc
    }
    
    // 右隣のページ取得
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = viewController.view.tag - 1
        
        index += 1
        if index > self.pageInfoList.count - 1 {
            // スクロール固定のためnilを返す
            return nil
        }
        return self.pageInfoList[index].vc
    }
    
    // ページ数
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return self.pageInfoList.count
    }
    
    // 遷移アニメーションが完了した時
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        
        if completed {
            // 前のメニューを非選択状態に
            self.pageInfoList[self.currentPageIndex].menuItemView.didDeselect()
            // インデックス更新
            self.currentPageIndex = self.pageViewController.viewControllers!.last!.view.tag - 1
            // 新しいメニューを選択状態に
            self.pageInfoList[self.currentPageIndex].menuItemView.didSelect()

            UIView.animate(
                withDuration: 0.0,
                animations: {self.menuBackground.frame.origin.x = self.pageInfoList[self.currentPageIndex].menuItemView.frame.origin.x})
        }
    }

    //  メニューがタップされたときの処理
    func menuDidSelectByTap(index: Int) {

        guard index - 1 != self.currentPageIndex else {
            return
        }
        // 前のメニューを非選択状態に
        self.pageInfoList[self.currentPageIndex].menuItemView.didDeselect()
        // インデックス更新
        let direction: UIPageViewController.NavigationDirection = index - 1 > self.currentPageIndex ? .forward : .reverse
        self.currentPageIndex = index - 1
        // 画面入れ替え
        self.pageViewController.setViewControllers(
            [self.pageInfoList[self.currentPageIndex].vc],
            direction  : direction,
            animated   : true,
            completion : nil
        )
        // 新しいメニューを選択状態に
        self.pageInfoList[self.currentPageIndex].menuItemView.didSelect()

        // 選択下線移動
        UIView.animate(
            withDuration: 0.2,
            animations: {self.menuBackground.frame.origin.x = self.pageInfoList[self.currentPageIndex].menuItemView.frame.origin.x})
    }

}
